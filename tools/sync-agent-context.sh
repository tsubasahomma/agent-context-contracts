#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
default_source="$(cd -- "${script_dir}/.." && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  printf 'sync-agent-context: python3 is required\n' >&2
  exit 127
fi

export AGENT_CONTEXT_SYNC_DEFAULT_SOURCE="${default_source}"

python3 - "$@" <<'PY'
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


TOOL_NAME = "sync-agent-context"
TOOL_VERSION = "0.1.0"
SCHEMA_VERSION = "0.1"
DEFAULT_PACKAGE_VERSION = "0.1.0"
LOCK_PATH = "agent-context.lock.json"

ADAPTER_MAPPINGS = {
    "github": [
        (
            "adapters/github/files/.github/copilot-instructions.md",
            ".github/copilot-instructions.md",
        ),
        (
            "adapters/github/files/.github/pull_request_template.md",
            ".github/pull_request_template.md",
        ),
        (
            "adapters/github/files/.github/ISSUE_TEMPLATE/parent-program.yml",
            ".github/ISSUE_TEMPLATE/parent-program.yml",
        ),
        (
            "adapters/github/files/.github/ISSUE_TEMPLATE/child-change.yml",
            ".github/ISSUE_TEMPLATE/child-change.yml",
        ),
    ],
    "codex": [
        (
            "adapters/codex/files/.codex/config.example.toml",
            ".codex/config.example.toml",
        ),
    ],
    "claude": [
        ("adapters/claude/files/CLAUDE.md", "CLAUDE.md"),
    ],
    "gemini": [
        ("adapters/gemini/files/GEMINI.md", "GEMINI.md"),
    ],
    "repomix": [
        (
            "adapters/repomix/files/repomix-instructions.md",
            "repomix-instructions.md",
        ),
    ],
}

PACKAGE_ROOT_FILES = ["AGENTS.md"]
PACKAGE_DIRS = ["docs/agent-context"]
PACKAGE_TOOL_FILES = ["tools/lint-portability.sh", "tools/sync-agent-context.sh"]

CHECKSUM_RE = re.compile(r"^sha256:[0-9a-f]{64}$")


class SyncError(Exception):
    pass


class SourceSpec:
    def __init__(self, path, source_path, ownership, source_adapter=None):
        self.path = path
        self.source_path = source_path
        self.ownership = ownership
        self.source_adapter = source_adapter
        self.checksum = sha256_file(source_path)
        self.mode = source_path.stat().st_mode & 0o777


class WriteTask:
    def __init__(self, path, source_path=None, content=None, mode=0o644):
        self.path = path
        self.source_path = source_path
        self.content = content
        self.mode = mode


def eprint(message):
    print(message, file=sys.stderr)


def normalize_repo_path(raw):
    if not isinstance(raw, str):
        raise ValueError("path must be a string")
    value = raw.replace("\\", "/")
    while value.startswith("./"):
        value = value[2:]
    if value == "" or value == ".":
        raise ValueError("path must not be empty or current directory")
    if value.startswith("/") or re.match(r"^[A-Za-z]:/", value):
        raise ValueError("path must be repository-relative")
    if value.endswith("/"):
        raise ValueError("path must not end with a slash")
    parts = value.split("/")
    if any(part in ("", ".", "..") for part in parts):
        raise ValueError("path contains an unsafe segment")
    return "/".join(parts)


def safe_join(target_root, rel_path):
    rel = normalize_repo_path(rel_path)
    root = target_root.resolve()
    candidate = target_root.joinpath(*rel.split("/"))
    resolved = candidate.resolve(strict=False)
    try:
        common = os.path.commonpath([str(root), str(resolved)])
    except ValueError as exc:
        raise SyncError(f"{rel}: path escapes target root") from exc
    if common != str(root):
        raise SyncError(f"{rel}: path escapes target root")
    return candidate


def path_has_symlink(target_root, rel_path):
    current = target_root
    for part in normalize_repo_path(rel_path).split("/"):
        current = current / part
        if current.is_symlink():
            return True
        if not current.exists():
            return False
    return False


def parent_path_issue(target_root, rel_path):
    current = target_root
    built = []
    parts = normalize_repo_path(rel_path).split("/")
    for part in parts[:-1]:
        built.append(part)
        current = current / part
        if current.is_symlink():
            return f"parent component {'/'.join(built)} is a symlink"
        if current.exists() and not current.is_dir():
            return f"parent component {'/'.join(built)} is {file_kind(current)}, not directory"
        if not current.exists():
            return None
    return None


def sha256_file(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return "sha256:" + digest.hexdigest()


def read_lock(target_root):
    path = target_root / LOCK_PATH
    if not path.exists() and not path.is_symlink():
        return None, None, []
    if path.is_symlink():
        return None, None, [f"{LOCK_PATH}: lock file must not be a symlink"]
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        return None, None, [f"{LOCK_PATH}: unreadable lock file: {exc}"]
    try:
        data = json.loads(text)
    except json.JSONDecodeError as exc:
        return None, text, [f"{LOCK_PATH}: malformed JSON: {exc}"]
    return data, text, validate_lock(data)


def validate_lock(data):
    errors = []
    if not isinstance(data, dict):
        return ["lock root must be a JSON object"]
    if data.get("schema_version") != SCHEMA_VERSION:
        errors.append(
            f"unsupported schema_version {data.get('schema_version')!r}; expected {SCHEMA_VERSION}"
        )
    for key in ("package_version", "source_ref", "project_extension_path"):
        if not isinstance(data.get(key), str) or not data.get(key):
            errors.append(f"{key} must be a non-empty string")
    if isinstance(data.get("project_extension_path"), str):
        try:
            normalized_project_path = normalize_repo_path(data["project_extension_path"])
            if data["project_extension_path"] != normalized_project_path:
                errors.append("project_extension_path must already be normalized")
        except ValueError as exc:
            errors.append(f"project_extension_path is unsafe: {exc}")

    installed = data.get("installed_adapters")
    installed_names = set()
    if not isinstance(installed, list):
        errors.append("installed_adapters must be an array")
    else:
        for index, item in enumerate(installed):
            if not isinstance(item, dict):
                errors.append(f"installed_adapters[{index}] must be an object")
                continue
            name = item.get("name")
            if name not in ADAPTER_MAPPINGS:
                errors.append(f"installed_adapters[{index}].name is unsupported")
            elif name in installed_names:
                errors.append(f"installed_adapters contains duplicate {name!r}")
            else:
                installed_names.add(name)
            if not isinstance(item.get("source_ref"), str) or not item.get("source_ref"):
                errors.append(f"installed_adapters[{index}].source_ref must be a non-empty string")

    managed = data.get("managed_files")
    seen_paths = set()
    if not isinstance(managed, list):
        errors.append("managed_files must be an array")
    else:
        for index, entry in enumerate(managed):
            prefix = f"managed_files[{index}]"
            if not isinstance(entry, dict):
                errors.append(f"{prefix} must be an object")
                continue
            path = entry.get("path")
            try:
                path = normalize_repo_path(path)
            except ValueError as exc:
                errors.append(f"{prefix}.path is unsafe: {exc}")
                path = None
            else:
                if entry.get("path") != path:
                    errors.append(f"{prefix}.path must already be normalized")
            if path == LOCK_PATH:
                errors.append(f"{prefix}.path must not manage {LOCK_PATH}")
            if path == "docs/project" or (path and path.startswith("docs/project/")):
                errors.append(f"{prefix}.path must not manage project extension files")
            if path:
                if path in seen_paths:
                    errors.append(f"{prefix}.path duplicates {path}")
                seen_paths.add(path)

            ownership = entry.get("ownership")
            if ownership not in ("package-managed", "adapter-installed"):
                errors.append(f"{prefix}.ownership is unsupported")

            checksum = entry.get("checksum")
            if not isinstance(checksum, dict):
                errors.append(f"{prefix}.checksum must be an object")
            else:
                if checksum.get("algorithm") != "sha256":
                    errors.append(f"{prefix}.checksum.algorithm is unsupported")
                for field in ("previous", "target"):
                    value = checksum.get(field)
                    if not isinstance(value, str) or not CHECKSUM_RE.match(value):
                        errors.append(f"{prefix}.checksum.{field} must be a sha256 digest")

            source_adapter = entry.get("source_adapter")
            if ownership == "package-managed":
                if source_adapter is not None:
                    errors.append(f"{prefix}.source_adapter must be null for package-managed files")
            elif ownership == "adapter-installed":
                if source_adapter not in ADAPTER_MAPPINGS:
                    errors.append(f"{prefix}.source_adapter is unsupported")
                elif source_adapter not in installed_names:
                    errors.append(
                        f"{prefix}.source_adapter {source_adapter!r} is not recorded in installed_adapters"
                    )

    created_by = data.get("created_by")
    if not isinstance(created_by, dict):
        errors.append("created_by must be an object")
    else:
        if not isinstance(created_by.get("tool"), str) or not created_by.get("tool"):
            errors.append("created_by.tool must be a non-empty string")
        if not isinstance(created_by.get("version"), str) or not created_by.get("version"):
            errors.append("created_by.version must be a non-empty string")

    return errors


def collect_package_specs(source_root):
    specs = {}
    for rel in PACKAGE_ROOT_FILES:
        source_path = source_root / rel
        if source_path.is_file() and not source_path.is_symlink():
            add_spec(specs, SourceSpec(rel, source_path, "package-managed"))

    for rel_dir in PACKAGE_DIRS:
        source_dir = source_root / rel_dir
        if not source_dir.is_dir():
            continue
        for path in sorted(source_dir.rglob("*")):
            if path.is_file() and not path.is_symlink():
                rel = path.relative_to(source_root).as_posix()
                add_spec(specs, SourceSpec(rel, path, "package-managed"))

    for rel in PACKAGE_TOOL_FILES:
        source_path = source_root / rel
        if source_path.is_file() and not source_path.is_symlink():
            add_spec(specs, SourceSpec(rel, source_path, "package-managed"))

    return specs


def add_spec(specs, spec):
    if spec.path in specs:
        raise SyncError(f"{spec.path}: duplicate source destination")
    specs[spec.path] = spec


def collect_selected_adapter_specs(source_root, selected_adapters):
    specs = {}
    refusals = []
    for adapter in sorted(selected_adapters):
        for source_rel, dest_rel in ADAPTER_MAPPINGS[adapter]:
            dest = normalize_repo_path(dest_rel)
            source_path = source_root / source_rel
            if not source_path.exists():
                refusals.append(
                    {
                        "path": dest,
                        "reason": f"selected adapter {adapter} source payload is missing: {source_rel}",
                    }
                )
                continue
            if not source_path.is_file() or source_path.is_symlink():
                refusals.append(
                    {
                        "path": dest,
                        "reason": f"selected adapter {adapter} source payload is not a regular file: {source_rel}",
                    }
                )
                continue
            add_spec(specs, SourceSpec(dest, source_path, "adapter-installed", adapter))
    return specs, refusals


def collect_project_templates(source_root, project_extension_path):
    template_root = source_root / "templates/project-extension"
    templates = []
    if not template_root.is_dir():
        return templates
    for path in sorted(template_root.rglob("*")):
        if path.is_file() and not path.is_symlink():
            rel = path.relative_to(template_root).as_posix()
            dest = normalize_repo_path(f"{project_extension_path}/{rel}")
            templates.append((dest, path, path.stat().st_mode & 0o777))
    return templates


def detect_source_ref(source_root):
    try:
        sha = subprocess.check_output(
            ["git", "-C", str(source_root), "rev-parse", "HEAD"],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        dirty = subprocess.check_output(
            ["git", "-C", str(source_root), "status", "--porcelain"],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        return "git:" + sha + ("-dirty" if dirty else "")
    except (OSError, subprocess.CalledProcessError):
        return "local-source"


def lock_maps(lock_data):
    if not lock_data:
        return {}, {}
    entries = {}
    for entry in lock_data.get("managed_files", []):
        normalized = normalize_repo_path(entry["path"])
        copied = dict(entry)
        copied["path"] = normalized
        entries[normalized] = copied
    adapters = {}
    for item in lock_data.get("installed_adapters", []):
        adapters[item["name"]] = item.get("source_ref", "unknown-source")
    return entries, adapters


def entry_checksum_previous(entry):
    return entry["checksum"]["previous"]


def make_lock_entry(spec):
    return {
        "path": spec.path,
        "ownership": spec.ownership,
        "checksum": {
            "algorithm": "sha256",
            "previous": spec.checksum,
            "target": spec.checksum,
        },
        "source_adapter": spec.source_adapter,
    }


def make_lock(package_version, source_ref, project_extension_path, entries, installed_adapters):
    return {
        "schema_version": SCHEMA_VERSION,
        "package_version": package_version,
        "source_ref": source_ref,
        "project_extension_path": project_extension_path,
        "managed_files": sorted(entries, key=lambda item: item["path"]),
        "installed_adapters": [
            {"name": name, "source_ref": installed_adapters[name]}
            for name in sorted(installed_adapters)
        ],
        "created_by": {
            "tool": TOOL_NAME,
            "version": TOOL_VERSION,
        },
    }


def format_json(data):
    return json.dumps(data, indent=2, sort_keys=False) + "\n"


def file_kind(path):
    if path.is_symlink():
        return "symlink"
    if path.is_dir():
        return "directory"
    if path.exists():
        return "file"
    return "missing"


def plan_sync(args):
    source_root = Path(args.source).expanduser().resolve()
    target_root = Path(args.target).expanduser().resolve()
    if not source_root.is_dir():
        raise SyncError(f"source path is not a directory: {source_root}")
    if not target_root.is_dir():
        raise SyncError(f"target path is not a directory: {target_root}")

    project_extension_path = normalize_repo_path(args.project_extension_path)
    selected_adapters = set(args.selected_adapters)
    source_ref = args.source_ref or detect_source_ref(source_root)

    lock_data, lock_text, lock_errors = read_lock(target_root)
    actions = []
    refusals = []
    file_writes = []

    if lock_errors:
        for error in lock_errors:
            refusals.append({"path": LOCK_PATH, "reason": error})
        return {
            "source_root": source_root,
            "target_root": target_root,
            "project_extension_path": project_extension_path,
            "selected_adapters": selected_adapters,
            "source_ref": source_ref,
            "actions": actions,
            "refusals": refusals,
            "file_writes": file_writes,
            "lock_action": "blocked",
            "lock_content": None,
            "lock_text": lock_text,
        }

    existing_entries, existing_adapters = lock_maps(lock_data)
    package_specs = collect_package_specs(source_root)
    adapter_specs, adapter_refusals = collect_selected_adapter_specs(
        source_root, selected_adapters
    )
    refusals.extend(adapter_refusals)

    desired_specs = {}
    for spec in list(package_specs.values()) + list(adapter_specs.values()):
        if spec.path in desired_specs:
            refusals.append(
                {"path": spec.path, "reason": "duplicate planned destination path"}
            )
        else:
            desired_specs[spec.path] = spec

    for adapter in sorted(ADAPTER_MAPPINGS):
        if adapter in selected_adapters:
            actions.append(("ADAPTER", adapter, "selected"))
        else:
            actions.append(("SKIP", f"adapter:{adapter}", "adapter not selected"))

    new_entries_by_path = {}
    for path, entry in existing_entries.items():
        if path not in desired_specs:
            try:
                destination = safe_join(target_root, path)
            except (ValueError, SyncError) as exc:
                refusals.append({"path": path, "reason": str(exc)})
                continue
            parent_issue = parent_path_issue(target_root, path)
            if parent_issue:
                refusals.append({"path": path, "reason": parent_issue})
                continue
            if path_has_symlink(target_root, path):
                refusals.append(
                    {"path": path, "reason": "preserved managed path or parent contains a symlink"}
                )
                continue
            kind = file_kind(destination)
            if kind != "file":
                refusals.append(
                    {"path": path, "reason": f"preserved managed destination is {kind}, not file"}
                )
                continue
            current_checksum = sha256_file(destination)
            expected_checksum = entry_checksum_previous(entry)
            if current_checksum != expected_checksum:
                refusals.append(
                    {
                        "path": path,
                        "reason": (
                            "modified preserved managed file; expected "
                            f"{expected_checksum}, current {current_checksum}"
                        ),
                    }
                )
                continue
            reason = "source path removed or adapter not selected; preserving destination by default"
            actions.append(("PRESERVE", path, reason))
            new_entries_by_path[path] = entry

    for path in sorted(desired_specs):
        spec = desired_specs[path]
        try:
            destination = safe_join(target_root, path)
        except (ValueError, SyncError) as exc:
            refusals.append({"path": path, "reason": str(exc)})
            continue

        parent_issue = parent_path_issue(target_root, path)
        if parent_issue:
            refusals.append({"path": path, "reason": parent_issue})
            continue

        if path_has_symlink(target_root, path):
            refusals.append(
                {"path": path, "reason": "destination path or parent contains a symlink"}
            )
            continue

        existing = existing_entries.get(path)
        kind = file_kind(destination)
        if existing:
            if existing.get("ownership") != spec.ownership:
                refusals.append(
                    {
                        "path": path,
                        "reason": "lock ownership does not match planned source ownership",
                    }
                )
                continue
            if existing.get("source_adapter") != spec.source_adapter:
                refusals.append(
                    {
                        "path": path,
                        "reason": "lock source_adapter does not match planned adapter selection",
                    }
                )
                continue
            if kind != "file":
                refusals.append(
                    {"path": path, "reason": f"managed destination is {kind}, not file"}
                )
                continue
            current_checksum = sha256_file(destination)
            expected_checksum = entry_checksum_previous(existing)
            if current_checksum != expected_checksum:
                refusals.append(
                    {
                        "path": path,
                        "reason": (
                            "modified managed file; expected "
                            f"{expected_checksum}, current {current_checksum}"
                        ),
                    }
                )
                continue
            if current_checksum == spec.checksum:
                actions.append(("SKIP", path, f"unchanged {spec.ownership}"))
            else:
                actions.append(
                    (
                        "UPDATE",
                        path,
                        f"{spec.ownership}; {current_checksum} -> {spec.checksum}",
                    )
                )
                file_writes.append(WriteTask(path, source_path=spec.source_path, mode=spec.mode))
        else:
            if kind != "missing":
                refusals.append(
                    {
                        "path": path,
                        "reason": f"unowned destination collision ({kind}); refusing overwrite",
                    }
                )
                continue
            actions.append(("CREATE", path, spec.ownership))
            file_writes.append(WriteTask(path, source_path=spec.source_path, mode=spec.mode))

        new_entries_by_path[path] = make_lock_entry(spec)

    if args.seed_project:
        for path, source_path, mode in collect_project_templates(
            source_root, project_extension_path
        ):
            try:
                destination = safe_join(target_root, path)
            except (ValueError, SyncError) as exc:
                refusals.append({"path": path, "reason": str(exc)})
                continue
            parent_issue = parent_path_issue(target_root, path)
            if parent_issue:
                refusals.append({"path": path, "reason": parent_issue})
                continue
            if path_has_symlink(target_root, path):
                refusals.append(
                    {
                        "path": path,
                        "reason": "project extension path or parent contains a symlink",
                    }
                )
                continue
            if destination.exists() or destination.is_symlink():
                actions.append(("PRESERVE", path, "project extension exists; consumer-owned"))
            else:
                actions.append(("SEED", path, "project extension missing"))
                file_writes.append(WriteTask(path, source_path=source_path, mode=mode))
    else:
        actions.append(("SKIP", project_extension_path, "project extension seeding not requested"))

    installed_adapters = dict(existing_adapters)
    for adapter in selected_adapters:
        installed_adapters[adapter] = source_ref

    if refusals:
        lock_action = "blocked"
        lock_content = None
    else:
        lock_data_new = make_lock(
            args.package_version,
            source_ref,
            project_extension_path,
            list(new_entries_by_path.values()),
            installed_adapters,
        )
        lock_content = format_json(lock_data_new).encode("utf-8")
        if lock_text is None:
            lock_action = "create"
        elif lock_text.encode("utf-8") == lock_content:
            lock_action = "unchanged"
        else:
            lock_action = "update"
            file_writes.append(WriteTask(LOCK_PATH, content=lock_content, mode=0o644))

        if lock_action == "create":
            file_writes.append(WriteTask(LOCK_PATH, content=lock_content, mode=0o644))

    return {
        "source_root": source_root,
        "target_root": target_root,
        "project_extension_path": project_extension_path,
        "selected_adapters": selected_adapters,
        "source_ref": source_ref,
        "actions": actions,
        "refusals": refusals,
        "file_writes": file_writes,
        "lock_action": lock_action,
        "lock_content": lock_content,
        "lock_text": lock_text,
    }


def print_plan(plan, apply_mode):
    print(f"Mode: {'apply' if apply_mode else 'dry-run'}")
    print(f"Source ref: {plan['source_ref']}")
    adapters = ", ".join(sorted(plan["selected_adapters"])) or "(none)"
    print(f"Selected adapters: {adapters}")
    print(f"Project extension path: {plan['project_extension_path']}")

    for action, path, detail in plan["actions"]:
        if action == "ADAPTER":
            print(f"ADAPTER {path} ({detail})")
        elif path.startswith("adapter:"):
            print(f"{action} {path[len('adapter:') :]} ({detail})")
        else:
            print(f"{action} {path} ({detail})")

    for refusal in plan["refusals"]:
        print(f"REFUSE {refusal['path']} ({refusal['reason']})")

    lock_action = plan["lock_action"]
    if lock_action == "blocked":
        print(f"LOCK blocked {LOCK_PATH} (refusals must be resolved first)")
    elif lock_action == "create":
        print(f"LOCK create {LOCK_PATH}")
    elif lock_action == "update":
        print(f"LOCK update {LOCK_PATH}")
    else:
        print(f"LOCK unchanged {LOCK_PATH}")

    print(
        "Summary: "
        f"{len([a for a in plan['actions'] if a[0] in ('CREATE', 'UPDATE', 'SEED')])} planned file writes, "
        f"{len(plan['refusals'])} refusals"
    )


def ensure_parent(destination, target_root, created_dirs):
    missing = []
    parent = destination.parent
    root = target_root.resolve()
    while not parent.exists():
        missing.append(parent)
        parent = parent.parent
    parent_resolved = parent.resolve()
    if os.path.commonpath([str(root), str(parent_resolved)]) != str(root):
        raise SyncError(f"{destination}: parent escapes target root")
    for directory in reversed(missing):
        directory.mkdir()
        created_dirs.append(directory)


def write_one(task, target_root, backup_root, rollback_records, created_dirs):
    destination = safe_join(target_root, task.path)
    ensure_parent(destination, target_root, created_dirs)

    backup_path = None
    existed = destination.exists() or destination.is_symlink()
    if existed:
        backup_path = backup_root / f"backup-{len(rollback_records)}"
        shutil.copy2(destination, backup_path)
    rollback_records.append((task.path, existed, backup_path))

    temp_path = destination.parent / f".{destination.name}.agent-context-sync-tmp"
    try:
        if task.source_path is not None:
            shutil.copy2(task.source_path, temp_path)
        else:
            temp_path.write_bytes(task.content)
        os.chmod(temp_path, task.mode)
        os.replace(temp_path, destination)
        os.chmod(destination, task.mode)
    finally:
        if temp_path.exists() or temp_path.is_symlink():
            temp_path.unlink()


def rollback(target_root, rollback_records, created_dirs):
    errors = []
    for rel_path, existed, backup_path in reversed(rollback_records):
        destination = safe_join(target_root, rel_path)
        try:
            if existed:
                ensure_parent(destination, target_root, [])
                shutil.copy2(backup_path, destination)
            elif destination.exists() or destination.is_symlink():
                destination.unlink()
        except OSError as exc:
            errors.append(f"{rel_path}: {exc}")

    for directory in sorted(created_dirs, key=lambda item: len(item.parts), reverse=True):
        try:
            directory.rmdir()
        except OSError:
            pass
    return errors


def apply_plan(plan):
    writes = plan["file_writes"]
    target_root = plan["target_root"]
    rollback_records = []
    created_dirs = []
    completed = 0
    fail_after = None
    if os.environ.get("AGENT_CONTEXT_SYNC_TEST_MODE") == "1":
        value = os.environ.get("AGENT_CONTEXT_SYNC_FAIL_AFTER_WRITES")
        if value:
            try:
                fail_after = int(value)
            except ValueError as exc:
                raise SyncError("AGENT_CONTEXT_SYNC_FAIL_AFTER_WRITES must be an integer") from exc

    with tempfile.TemporaryDirectory(prefix=".agent-context-sync-", dir=str(target_root)) as tmp:
        backup_root = Path(tmp)
        try:
            for task in writes:
                if fail_after is not None and completed >= fail_after:
                    raise SyncError(
                        "test failure injection after "
                        f"{completed} successful write(s)"
                    )
                write_one(task, target_root, backup_root, rollback_records, created_dirs)
                completed += 1
        except Exception as exc:
            errors = rollback(target_root, rollback_records, created_dirs)
            print(f"APPLY failed: {exc}", file=sys.stderr)
            if errors:
                print("ROLLBACK incomplete:", file=sys.stderr)
                for error in errors:
                    print(f"  {error}", file=sys.stderr)
            else:
                print("ROLLBACK complete; destination files restored", file=sys.stderr)
            return 1

    return 0


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description=(
            "Safely sync a vendored agent-context snapshot into a consumer target. "
            "Dry-run is the default and performs no writes."
        )
    )
    parser.add_argument(
        "--source",
        default=os.environ["AGENT_CONTEXT_SYNC_DEFAULT_SOURCE"],
        help="source package path (default: package containing this script)",
    )
    parser.add_argument(
        "--target",
        default=os.getcwd(),
        help="consumer repository target path (default: current directory)",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="write planned changes; without this flag the tool is read-only",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="force dry-run mode (the default)",
    )
    parser.add_argument(
        "--adapter",
        action="append",
        default=[],
        help="explicitly selected adapter; may be repeated or comma-separated",
    )
    parser.add_argument(
        "--adapters",
        action="append",
        default=[],
        help="comma-separated selected adapters",
    )
    parser.add_argument(
        "--seed-project",
        action="store_true",
        help="seed missing project extension files from templates",
    )
    parser.add_argument(
        "--project-extension-path",
        default="docs/project",
        help="consumer-owned project extension path (default: docs/project)",
    )
    parser.add_argument(
        "--package-version",
        default=DEFAULT_PACKAGE_VERSION,
        help="package version to record in the lock file",
    )
    parser.add_argument(
        "--source-ref",
        default=None,
        help="source reference to record in the lock file (default: detected git ref)",
    )
    args = parser.parse_args(argv)
    if args.dry_run:
        args.apply = False

    selected = []
    for value in args.adapter + args.adapters:
        for item in value.split(","):
            name = item.strip()
            if name:
                selected.append(name)
    unknown = sorted(set(selected) - set(ADAPTER_MAPPINGS))
    if unknown:
        parser.error(f"unsupported adapter(s): {', '.join(unknown)}")
    args.selected_adapters = sorted(set(selected))
    return args


def main(argv):
    try:
        args = parse_args(argv)
        plan = plan_sync(args)
        print_plan(plan, args.apply)
        if args.apply:
            if plan["refusals"]:
                eprint("Apply refused; no files were changed")
                return 1
            return apply_plan(plan)
        return 0
    except (SyncError, ValueError) as exc:
        eprint(f"sync-agent-context: {exc}")
        return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
PY
