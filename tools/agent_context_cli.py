#!/usr/bin/env python3
"""v0.3 agent-context init/sync lifecycle tooling."""

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


TOOL_NAME = "agent-context"
TOOL_VERSION = "0.3"
SCHEMA_VERSION = "0.3"
LOCK_PATH = "agent-context.lock.json"
PROJECT_EXTENSION_DEFAULT = "docs/project"
CHECKSUM_RE = re.compile(r"^sha256:[0-9a-f]{64}$")
COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")

ENTRYPOINT_MAPPINGS = {
    "claude": [("entrypoints/claude/CLAUDE.md", "CLAUDE.md")],
    "codex": [("entrypoints/codex/config.example.toml", ".codex/config.example.toml")],
    "gemini": [("entrypoints/gemini/GEMINI.md", "GEMINI.md")],
    "github-copilot": [
        ("entrypoints/github-copilot/copilot-instructions.md", ".github/copilot-instructions.md")
    ],
}

SURFACE_MAPPINGS = {
    "github": [
        ("surfaces/github/pull_request_template.md", ".github/pull_request_template.md"),
        (
            "surfaces/github/ISSUE_TEMPLATE/parent-program.yml",
            ".github/ISSUE_TEMPLATE/parent-program.yml",
        ),
        (
            "surfaces/github/ISSUE_TEMPLATE/child-change.yml",
            ".github/ISSUE_TEMPLATE/child-change.yml",
        ),
    ],
}


class SyncError(Exception):
    pass


@dataclass
class SourceSpec:
    path: str
    source_path: str
    source_abs: Path
    group_kind: str
    group_name: Optional[str]
    checksum: str
    mode: int


@dataclass
class WriteTask:
    op: str
    path: str
    source_abs: Optional[Path] = None
    content: Optional[bytes] = None
    mode: int = 0o644


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


def project_extension_path_refusal(path):
    if path == "docs/project" or path.startswith("docs/project/"):
        return None
    return "project extension path must be docs/project or below"


def safe_join(root, rel_path):
    rel = normalize_repo_path(rel_path)
    resolved_root = root.resolve()
    candidate = root.joinpath(*rel.split("/"))
    resolved_candidate = candidate.resolve(strict=False)
    common = os.path.commonpath([str(resolved_root), str(resolved_candidate)])
    if common != str(resolved_root):
        raise SyncError(f"{rel}: path escapes target root")
    return candidate


def file_kind(path):
    if path.is_symlink():
        return "symlink"
    if path.is_dir():
        return "directory"
    if path.exists():
        return "file"
    return "missing"


def path_has_symlink(root, rel_path):
    current = root
    for part in normalize_repo_path(rel_path).split("/"):
        current = current / part
        if current.is_symlink():
            return True
        if not current.exists():
            return False
    return False


def parent_path_issue(root, rel_path):
    current = root
    built = []
    for part in normalize_repo_path(rel_path).split("/")[:-1]:
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


def git_output(source_root, args):
    return subprocess.check_output(
        ["git", "-C", str(source_root), *args],
        stderr=subprocess.DEVNULL,
        text=True,
    ).strip()


def resolve_source(source_root, args):
    refusals = []
    local_development = None
    repository = args.repository
    if not repository:
        try:
            repository = git_output(source_root, ["remote", "get-url", "origin"])
        except (OSError, subprocess.CalledProcessError):
            repository = "local-source"
    channel = args.channel
    head_commit = None
    try:
        head_commit = git_output(source_root, ["rev-parse", "HEAD"])
    except (OSError, subprocess.CalledProcessError):
        pass
    if channel:
        try:
            resolved_commit = git_output(source_root, ["rev-parse", "--verify", f"{channel}^{{commit}}"])
        except (OSError, subprocess.CalledProcessError):
            resolved_commit = None
    else:
        try:
            branch = git_output(source_root, ["rev-parse", "--abbrev-ref", "HEAD"])
            channel = branch if branch and branch != "HEAD" else "detached-head"
        except (OSError, subprocess.CalledProcessError):
            channel = "unresolved-local"
        resolved_commit = head_commit
    if not resolved_commit or not COMMIT_RE.match(resolved_commit):
        if args.local_development:
            resolved_commit = "0" * 40
            local_development = {
                "enabled": True,
                "unresolved_source": True,
                "dirty_source": True,
                "warning": "local-development mode applied from an unresolved source",
            }
        else:
            refusals.append(
                {
                    "path": "source",
                    "reason": "source channel cannot be resolved to a full commit SHA",
                }
            )
    else:
        if head_commit and COMMIT_RE.match(head_commit) and head_commit != resolved_commit:
            refusals.append(
                {
                    "path": "source",
                    "reason": (
                        "source checkout HEAD does not match requested source channel "
                        f"{channel}; resolved {resolved_commit}, current {head_commit}"
                    ),
                }
            )
        try:
            dirty = git_output(source_root, ["status", "--porcelain"])
        except (OSError, subprocess.CalledProcessError):
            dirty = None
        if dirty:
            if args.local_development:
                local_development = {
                    "enabled": True,
                    "unresolved_source": False,
                    "dirty_source": True,
                    "warning": "local-development mode applied from a dirty source checkout",
                }
            else:
                refusals.append(
                    {
                        "path": "source",
                        "reason": "source package is dirty; apply requires a clean resolved source",
                    }
                )
    return {
        "repository": repository,
        "channel": channel,
        "resolved_commit": resolved_commit or "",
    }, local_development, refusals


def validate_normalized_field(entry, field, prefix, errors):
    try:
        value = normalize_repo_path(entry.get(field))
    except ValueError as exc:
        errors.append(f"{prefix}.{field} is unsafe: {exc}")
        return None
    if entry.get(field) != value:
        errors.append(f"{prefix}.{field} must already be normalized")
    return value


def validate_selected_groups(items, supported, kind, errors):
    if not isinstance(items, list):
        errors.append(f"selected_{kind}s must be an array")
        return set()
    seen = set()
    for index, item in enumerate(items):
        prefix = f"selected_{kind}s[{index}]"
        if not isinstance(item, dict):
            errors.append(f"{prefix} must be an object")
            continue
        name = item.get("name")
        if name not in supported:
            errors.append(f"{prefix}.name is unsupported")
        elif name in seen:
            errors.append(f"selected_{kind}s contains duplicate {name!r}")
        else:
            seen.add(name)
        expected_source = f"{kind}s/{name}" if name in supported else None
        if item.get("source_path") != expected_source:
            errors.append(f"{prefix}.source_path must be {expected_source!r}")
        if kind == "surface" and not isinstance(item.get("detached", False), bool):
            errors.append(f"{prefix}.detached must be a boolean when present")
    return seen


def validate_lock(data):
    errors = []
    if not isinstance(data, dict):
        return ["lock root must be a JSON object"]
    if data.get("schema_version") != SCHEMA_VERSION:
        errors.append(
            f"unsupported schema_version {data.get('schema_version')!r}; expected {SCHEMA_VERSION}"
        )
    source = data.get("source")
    if not isinstance(source, dict):
        errors.append("source must be an object")
    else:
        for field in ("repository", "channel"):
            if not isinstance(source.get(field), str) or not source.get(field):
                errors.append(f"source.{field} must be a non-empty string")
        resolved = source.get("resolved_commit")
        if not isinstance(resolved, str) or not COMMIT_RE.match(resolved):
            errors.append("source.resolved_commit must be a full commit SHA")
    project_path = data.get("project_extension_path")
    if not isinstance(project_path, str) or not project_path:
        errors.append("project_extension_path must be a non-empty string")
    else:
        try:
            normalized = normalize_repo_path(project_path)
            if project_path != normalized:
                errors.append("project_extension_path must already be normalized")
            refusal = project_extension_path_refusal(normalized)
            if refusal:
                errors.append(f"project_extension_path {refusal}")
        except ValueError as exc:
            errors.append(f"project_extension_path is unsafe: {exc}")
    selected_entrypoints = validate_selected_groups(
        data.get("selected_entrypoints"), ENTRYPOINT_MAPPINGS, "entrypoint", errors
    )
    selected_surfaces = validate_selected_groups(
        data.get("selected_surfaces"), SURFACE_MAPPINGS, "surface", errors
    )
    detached_surfaces = {
        item.get("name")
        for item in data.get("selected_surfaces", [])
        if isinstance(item, dict) and item.get("detached") is True
    }
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
            path = validate_normalized_field(entry, "path", prefix, errors)
            source_path = validate_normalized_field(entry, "source_path", prefix, errors)
            if path:
                if path in seen_paths:
                    errors.append(f"{prefix}.path duplicates {path}")
                seen_paths.add(path)
                if path == LOCK_PATH:
                    errors.append(f"{prefix}.path must not manage {LOCK_PATH}")
                if path == "docs/project" or path.startswith("docs/project/"):
                    errors.append(f"{prefix}.path must not manage project extension files")
                if path == "tools" or path.startswith("tools/"):
                    errors.append(f"{prefix}.path must not manage source-package tooling")
            if source_path and (source_path == "tools" or source_path.startswith("tools/")):
                errors.append(f"{prefix}.source_path must not point at source-package tooling")
            if entry.get("ownership") != "package-managed":
                errors.append(f"{prefix}.ownership is unsupported")
            group = entry.get("group")
            if not isinstance(group, dict):
                errors.append(f"{prefix}.group must be an object")
            else:
                kind = group.get("kind")
                name = group.get("name")
                if kind not in ("portable-core", "entrypoint", "surface"):
                    errors.append(f"{prefix}.group.kind is unsupported")
                elif kind == "portable-core":
                    if name is not None:
                        errors.append(f"{prefix}.group.name must be null for portable core")
                    if source_path and not (
                        source_path == "AGENTS.md" or source_path.startswith("docs/agent-context/")
                    ):
                        errors.append(f"{prefix}.source_path is not portable core")
                elif kind == "entrypoint":
                    if name not in selected_entrypoints:
                        errors.append(f"{prefix}.group.name is not a selected entrypoint")
                    if source_path and name in ENTRYPOINT_MAPPINGS and not source_path.startswith(
                        f"entrypoints/{name}/"
                    ):
                        errors.append(f"{prefix}.source_path does not match selected entrypoint")
                elif kind == "surface":
                    if name not in selected_surfaces:
                        errors.append(f"{prefix}.group.name is not a selected surface")
                    if name in detached_surfaces:
                        errors.append(f"{prefix}.group.name is detached and must not be managed")
                    if source_path and name in SURFACE_MAPPINGS and not source_path.startswith(
                        f"surfaces/{name}/"
                    ):
                        errors.append(f"{prefix}.source_path does not match selected surface")
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
    created_by = data.get("created_by")
    if not isinstance(created_by, dict):
        errors.append("created_by must be an object")
    else:
        if not isinstance(created_by.get("tool"), str) or not created_by.get("tool"):
            errors.append("created_by.tool must be a non-empty string")
        if not isinstance(created_by.get("version"), str) or not created_by.get("version"):
            errors.append("created_by.version must be a non-empty string")
    return errors


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


def add_spec(specs, spec):
    if spec.path in specs:
        raise SyncError(f"{spec.path}: duplicate source destination")
    specs[spec.path] = spec


def make_spec(source_root, source_rel, dest_rel, group_kind, group_name):
    source_path = source_root / source_rel
    return SourceSpec(
        path=normalize_repo_path(dest_rel),
        source_path=normalize_repo_path(source_rel),
        source_abs=source_path,
        group_kind=group_kind,
        group_name=group_name,
        checksum=sha256_file(source_path),
        mode=source_path.stat().st_mode & 0o777,
    )


def collect_core_specs(source_root):
    specs = {}
    agents = source_root / "AGENTS.md"
    if agents.is_file() and not agents.is_symlink():
        add_spec(specs, make_spec(source_root, "AGENTS.md", "AGENTS.md", "portable-core", None))
    docs_root = source_root / "docs/agent-context"
    if docs_root.is_dir() and not docs_root.is_symlink():
        for path in sorted(docs_root.rglob("*")):
            if path.is_file() and not path.is_symlink():
                rel = path.relative_to(source_root).as_posix()
                add_spec(specs, make_spec(source_root, rel, rel, "portable-core", None))
    return specs


def collect_group_specs(source_root, selected, mappings, group_kind):
    specs = {}
    refusals = []
    for name in sorted(selected):
        if name not in mappings:
            refusals.append({"path": group_kind, "reason": f"unsupported {group_kind} {name!r}"})
            continue
        for source_rel, dest_rel in mappings[name]:
            source_path = source_root / source_rel
            if not source_path.exists():
                continue
            if not source_path.is_file() or source_path.is_symlink():
                refusals.append(
                    {
                        "path": normalize_repo_path(dest_rel),
                        "reason": f"selected {group_kind} {name} source payload is not a regular file: {source_rel}",
                    }
                )
                continue
            add_spec(specs, make_spec(source_root, source_rel, dest_rel, group_kind, name))
    return specs, refusals


def collect_project_scaffolds(source_root, project_extension_path):
    scaffold_root = source_root / "scaffolds/project"
    scaffolds = []
    if not scaffold_root.is_dir() or scaffold_root.is_symlink():
        return scaffolds
    for path in sorted(scaffold_root.rglob("*")):
        if path.is_file() and not path.is_symlink():
            rel = path.relative_to(scaffold_root).as_posix()
            dest = normalize_repo_path(f"{project_extension_path}/{rel}")
            scaffolds.append((dest, path, path.stat().st_mode & 0o777))
    return scaffolds


def lock_entries(lock_data):
    if not lock_data:
        return {}
    return {normalize_repo_path(entry["path"]): entry for entry in lock_data["managed_files"]}


def selected_from_lock(lock_data):
    entrypoints = {item["name"] for item in lock_data["selected_entrypoints"]}
    surfaces = {
        item["name"]
        for item in lock_data["selected_surfaces"]
        if item.get("detached") is not True
    }
    return entrypoints, surfaces


def all_surface_records(active_names, existing_records=None, detach_names=None):
    records = {}
    if existing_records:
        for item in existing_records:
            if isinstance(item, dict) and item.get("name") in SURFACE_MAPPINGS:
                records[item["name"]] = {
                    "name": item["name"],
                    "source_path": f"surfaces/{item['name']}",
                    "detached": item.get("detached") is True,
                }
    for name in active_names:
        records[name] = {"name": name, "source_path": f"surfaces/{name}", "detached": False}
    for name in detach_names or []:
        if name in records:
            records[name]["detached"] = True
        else:
            records[name] = {"name": name, "source_path": f"surfaces/{name}", "detached": True}
    return [records[name] for name in sorted(records)]


def selected_entrypoint_records(names):
    return [{"name": name, "source_path": f"entrypoints/{name}"} for name in sorted(names)]


def make_lock_entry(spec):
    return {
        "path": spec.path,
        "source_path": spec.source_path,
        "ownership": "package-managed",
        "group": {"kind": spec.group_kind, "name": spec.group_name},
        "checksum": {
            "algorithm": "sha256",
            "previous": spec.checksum,
            "target": spec.checksum,
        },
    }


def make_lock(
    source,
    project_extension_path,
    entrypoint_names,
    surface_names,
    entries,
    local_development=None,
    existing_surface_records=None,
    detach_surfaces=None,
):
    lock = {
        "schema_version": SCHEMA_VERSION,
        "source": source,
        "project_extension_path": project_extension_path,
        "selected_entrypoints": selected_entrypoint_records(entrypoint_names),
        "selected_surfaces": all_surface_records(
            surface_names,
            existing_surface_records,
            detach_surfaces,
        ),
        "managed_files": sorted(entries, key=lambda item: item["path"]),
        "created_by": {"tool": TOOL_NAME, "version": TOOL_VERSION},
    }
    if local_development:
        lock["local_development"] = local_development
    return lock


def format_json(data):
    return json.dumps(data, indent=2, sort_keys=False) + "\n"


def entry_previous(entry):
    return entry["checksum"]["previous"]


def entry_group(entry):
    group = entry.get("group") or {}
    return group.get("kind"), group.get("name")


def same_managed_identity(entry, spec):
    kind, name = entry_group(entry)
    return (
        entry.get("ownership") == "package-managed"
        and entry.get("source_path") == spec.source_path
        and kind == spec.group_kind
        and name == spec.group_name
    )


def plan_operation(args):
    source_root = Path(args.source).expanduser().resolve()
    target_root = Path(args.target).expanduser().resolve()
    if not source_root.is_dir():
        raise SyncError(f"source path is not a directory: {source_root}")
    if not target_root.is_dir():
        raise SyncError(f"target path is not a directory: {target_root}")
    project_extension_path = normalize_repo_path(args.project_extension_path)
    actions = []
    refusals = []
    writes = []
    project_refusal = project_extension_path_refusal(project_extension_path)
    if project_refusal:
        refusals.append({"path": project_extension_path, "reason": project_refusal})
    source, local_development, source_refusals = resolve_source(source_root, args)
    if args.apply:
        refusals.extend(source_refusals)
    elif source_refusals:
        actions.append(("WARN", "source", "; ".join(item["reason"] for item in source_refusals)))
    lock_data, lock_text, lock_errors = read_lock(target_root)
    if lock_errors:
        for error in lock_errors:
            refusals.append({"path": LOCK_PATH, "reason": error})
        lock_data = None
    if args.command == "init":
        if lock_data is not None:
            refusals.append({"path": LOCK_PATH, "reason": "init requires no existing lock; use sync"})
        selected_entrypoints = set(args.entrypoints or [])
        selected_surfaces = set(args.surfaces or [])
        detach_surfaces = set()
        existing_entries = {}
        existing_surface_records = None
    else:
        if lock_data is None:
            if not lock_errors:
                refusals.append({"path": LOCK_PATH, "reason": "sync requires an existing v0.3 lock; run init first"})
            selected_entrypoints = set()
            selected_surfaces = set()
            detach_surfaces = set(args.detach_surfaces or [])
            existing_entries = {}
            existing_surface_records = None
        else:
            selected_entrypoints, selected_surfaces = selected_from_lock(lock_data)
            detach_surfaces = set(args.detach_surfaces or [])
            existing_entries = lock_entries(lock_data)
            existing_surface_records = lock_data.get("selected_surfaces", [])
            project_extension_path = lock_data.get("project_extension_path", project_extension_path)
            selected_surface_names = {
                item.get("name")
                for item in existing_surface_records
                if isinstance(item, dict)
            }
            for name in sorted(detach_surfaces):
                if name not in selected_surface_names:
                    refusals.append({"path": f"surfaces/{name}", "reason": "surface is not selected in the lock"})
                elif name not in selected_surfaces:
                    actions.append(("SKIP", f"surfaces/{name}", "surface is already detached"))
            active_detach_surfaces = detach_surfaces.intersection(selected_surfaces)
            selected_surfaces.difference_update(detach_surfaces)
    if args.command == "init" or lock_data is None:
        active_detach_surfaces = set()
    for name in sorted(selected_entrypoints):
        actions.append(("ENTRYPOINT", name, "selected"))
    for name in sorted(selected_surfaces):
        actions.append(("SURFACE", name, "selected"))
    for name in sorted(active_detach_surfaces):
        actions.append(("DETACH", f"surfaces/{name}", "surface files become consumer-owned; lock management removed"))
    desired_specs = {}
    try:
        for spec in collect_core_specs(source_root).values():
            add_spec(desired_specs, spec)
        entry_specs, entry_refusals = collect_group_specs(
            source_root, selected_entrypoints, ENTRYPOINT_MAPPINGS, "entrypoint"
        )
        surface_specs, surface_refusals = collect_group_specs(
            source_root, selected_surfaces, SURFACE_MAPPINGS, "surface"
        )
        refusals.extend(entry_refusals)
        refusals.extend(surface_refusals)
        for spec in list(entry_specs.values()) + list(surface_specs.values()):
            add_spec(desired_specs, spec)
    except SyncError as exc:
        refusals.append({"path": "source", "reason": str(exc)})
    new_entries = {}
    for path, entry in sorted(existing_entries.items()):
        if path in desired_specs:
            continue
        kind_name = entry_group(entry)
        if kind_name[0] == "surface" and kind_name[1] in active_detach_surfaces:
            actions.append(("DETACH", path, f"preserve destination; remove managed ownership for surface {kind_name[1]}"))
            continue
        try:
            destination = safe_join(target_root, path)
            parent_issue = parent_path_issue(target_root, path)
        except (ValueError, SyncError) as exc:
            refusals.append({"path": path, "reason": str(exc)})
            continue
        if parent_issue:
            refusals.append({"path": path, "reason": parent_issue})
            continue
        if path_has_symlink(target_root, path):
            refusals.append({"path": path, "reason": "managed path or parent contains a symlink"})
            continue
        kind = file_kind(destination)
        if kind != "file":
            refusals.append({"path": path, "reason": f"managed destination is {kind}, not file"})
            continue
        current_checksum = sha256_file(destination)
        expected_checksum = entry_previous(entry)
        if current_checksum != expected_checksum:
            refusals.append(
                {
                    "path": path,
                    "reason": (
                        "dirty managed file for source removal; expected "
                        f"{expected_checksum}, current {current_checksum}"
                    ),
                }
            )
            continue
        actions.append(("DELETE", path, "managed source path no longer exists in resolved source"))
        writes.append(WriteTask("delete", path))
    for path in sorted(desired_specs):
        spec = desired_specs[path]
        try:
            destination = safe_join(target_root, path)
            parent_issue = parent_path_issue(target_root, path)
        except (ValueError, SyncError) as exc:
            refusals.append({"path": path, "reason": str(exc)})
            continue
        if parent_issue:
            refusals.append({"path": path, "reason": parent_issue})
            continue
        if path_has_symlink(target_root, path):
            refusals.append({"path": path, "reason": "destination path or parent contains a symlink"})
            continue
        existing = existing_entries.get(path)
        kind = file_kind(destination)
        if existing:
            if not same_managed_identity(existing, spec):
                refusals.append({"path": path, "reason": "lock managed identity does not match planned source"})
                continue
            if kind != "file":
                refusals.append({"path": path, "reason": f"managed destination is {kind}, not file"})
                continue
            current_checksum = sha256_file(destination)
            expected_checksum = entry_previous(existing)
            if current_checksum != expected_checksum:
                refusals.append(
                    {
                        "path": path,
                        "reason": (
                            "dirty managed file; expected "
                            f"{expected_checksum}, current {current_checksum}"
                        ),
                    }
                )
                continue
            if current_checksum == spec.checksum:
                actions.append(("SKIP", path, f"unchanged {spec.group_kind}"))
            else:
                actions.append(("UPDATE", path, f"{spec.group_kind}; {current_checksum} -> {spec.checksum}"))
                writes.append(WriteTask("write", path, source_abs=spec.source_abs, mode=spec.mode))
        else:
            if kind != "missing":
                refusals.append({"path": path, "reason": f"unowned destination collision ({kind}); refusing overwrite"})
                continue
            actions.append(("CREATE", path, spec.group_kind))
            writes.append(WriteTask("write", path, source_abs=spec.source_abs, mode=spec.mode))
        new_entries[path] = make_lock_entry(spec)
    if args.command == "init" and args.materialize_project:
        seed_paths = set()
        for path, source_path, mode in collect_project_scaffolds(source_root, project_extension_path):
            if path in seed_paths:
                refusals.append({"path": path, "reason": "duplicate project scaffold destination"})
                continue
            seed_paths.add(path)
            if path in desired_specs:
                refusals.append({"path": path, "reason": "project scaffold overlaps a managed destination"})
                continue
            try:
                destination = safe_join(target_root, path)
                parent_issue = parent_path_issue(target_root, path)
            except (ValueError, SyncError) as exc:
                refusals.append({"path": path, "reason": str(exc)})
                continue
            if parent_issue:
                refusals.append({"path": path, "reason": parent_issue})
                continue
            if path_has_symlink(target_root, path):
                refusals.append({"path": path, "reason": "project extension path or parent contains a symlink"})
                continue
            if destination.exists() or destination.is_symlink():
                actions.append(("PRESERVE", path, "project extension exists; consumer-owned"))
            else:
                actions.append(("MATERIALIZE", path, "project scaffold; consumer-owned after creation"))
                writes.append(WriteTask("write", path, source_abs=source_path, mode=mode))
    elif args.command == "init":
        actions.append(("SKIP", project_extension_path, "project scaffold materialization not requested"))
    else:
        for path, source_path, _mode in collect_project_scaffolds(source_root, project_extension_path):
            try:
                destination = safe_join(target_root, path)
            except (ValueError, SyncError) as exc:
                actions.append(("ADVISE", path, f"project scaffold advisory skipped: {exc}"))
                continue
            kind = file_kind(destination)
            if kind == "missing":
                actions.append(("ADVISE", path, "project scaffold exists in source but destination is missing; sync will not materialize"))
            elif kind != "file":
                actions.append(("ADVISE", path, f"project scaffold destination is {kind}; sync will not modify"))
            elif sha256_file(destination) != sha256_file(source_path):
                actions.append(("ADVISE", path, "project scaffold differs from consumer-owned destination; sync will not modify"))
        actions.append(("SKIP", project_extension_path, "project extension is consumer-owned"))
    if active_detach_surfaces and writes:
        planned = ", ".join(task.path for task in writes)
        refusals.append(
            {
                "path": "detach",
                "reason": (
                    "surface detach is metadata-only; run sync without detach first "
                    f"to apply planned file changes: {planned}"
                ),
            }
        )
    lock_action = "blocked"
    if not refusals:
        lock_new = make_lock(
            source,
            project_extension_path,
            selected_entrypoints,
            selected_surfaces,
            list(new_entries.values()),
            local_development,
            existing_surface_records,
            detach_surfaces,
        )
        lock_content = format_json(lock_new).encode("utf-8")
        if lock_text is None:
            lock_action = "create"
            writes.append(WriteTask("write", LOCK_PATH, content=lock_content, mode=0o644))
        elif lock_text.encode("utf-8") == lock_content:
            lock_action = "unchanged"
        else:
            lock_action = "update"
            writes.append(WriteTask("write", LOCK_PATH, content=lock_content, mode=0o644))
    return {
        "command": args.command,
        "source": source,
        "local_development": local_development,
        "project_extension_path": project_extension_path,
        "selected_entrypoints": selected_entrypoints,
        "selected_surfaces": selected_surfaces,
        "detach_surfaces": detach_surfaces,
        "actions": actions,
        "refusals": refusals,
        "writes": writes,
        "lock_action": lock_action,
        "target_root": target_root,
    }


def print_plan(plan, apply_mode):
    print(f"Command: agent-context {plan['command']}")
    print(f"Mode: {'apply' if apply_mode else 'dry-run'}")
    print(f"Source repository: {plan['source']['repository']}")
    print(f"Source channel: {plan['source']['channel']}")
    print(f"Resolved commit: {plan['source']['resolved_commit'] or '(unresolved)'}")
    if plan["local_development"]:
        print(f"LOCAL-DEVELOPMENT {plan['local_development']['warning']}")
    entrypoints = ", ".join(sorted(plan["selected_entrypoints"])) or "(none)"
    surfaces = ", ".join(sorted(plan["selected_surfaces"])) or "(none)"
    detached = ", ".join(sorted(plan["detach_surfaces"])) or "(none)"
    print(f"Selected entrypoints: {entrypoints}")
    print(f"Selected surfaces: {surfaces}")
    print(f"Detach surfaces: {detached}")
    print(f"Project extension path: {plan['project_extension_path']}")
    for action, path, detail in plan["actions"]:
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
    write_actions = [a for a in plan["actions"] if a[0] in ("CREATE", "UPDATE", "DELETE", "MATERIALIZE")]
    print(
        "Summary: "
        f"{len(write_actions)} planned file changes, "
        f"{len(plan['refusals'])} refusals, lock {lock_action}"
    )


def snapshot_path(path):
    if path.exists() or path.is_symlink():
        if path.is_file() and not path.is_symlink():
            return {
                "exists": True,
                "is_file": True,
                "content": path.read_bytes(),
                "mode": path.stat().st_mode & 0o777,
            }
        return {"exists": True, "is_file": False}
    return {"exists": False}


def restore_path(path, snapshot):
    if path.exists() or path.is_symlink():
        if path.is_dir() and not path.is_symlink():
            shutil.rmtree(path)
        else:
            path.unlink()
    if snapshot["exists"] and snapshot.get("is_file"):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(snapshot["content"])
        os.chmod(path, snapshot["mode"])


def apply_writes(target_root, writes):
    snapshots = []
    completed = 0
    fail_after = int(os.environ.get("AGENT_CONTEXT_SYNC_FAIL_AFTER_WRITES", "0") or "0")
    try:
        for task in writes:
            destination = safe_join(target_root, task.path)
            snapshots.append((destination, snapshot_path(destination)))
            if task.op == "delete":
                destination.unlink()
            elif task.op == "write":
                destination.parent.mkdir(parents=True, exist_ok=True)
                if task.source_abs is not None:
                    shutil.copyfile(task.source_abs, destination)
                else:
                    destination.write_bytes(task.content or b"")
                os.chmod(destination, task.mode)
            else:
                raise SyncError(f"unsupported write operation {task.op!r}")
            completed += 1
            if fail_after and completed >= fail_after:
                raise SyncError("test-injected apply failure after planned write")
    except Exception:
        for path, snapshot in reversed(snapshots):
            restore_path(path, snapshot)
        print("ROLLBACK complete")
        raise


def build_parser():
    parser = argparse.ArgumentParser(
        prog="agent-context",
        description="v0.3 curl-first init/sync tooling for agent context contracts.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    def add_common(sub):
        sub.add_argument("--source", default=os.environ.get("AGENT_CONTEXT_DEFAULT_SOURCE", "."))
        sub.add_argument("--target", default=".")
        sub.add_argument("--apply", action="store_true", help="write changes; default is dry-run")
        sub.add_argument("--repository", help="source.repository value for the lock")
        sub.add_argument("--channel", help="source.channel value for the lock")
        sub.add_argument("--project-extension-path", default=PROJECT_EXTENSION_DEFAULT)
        sub.add_argument(
            "--local-development",
            action="store_true",
            help="explicitly allow dirty or unresolved local-development source metadata",
        )

    init = subparsers.add_parser("init", help="perform initial adoption")
    add_common(init)
    init.add_argument("--entrypoint", dest="entrypoints", action="append", choices=sorted(ENTRYPOINT_MAPPINGS))
    init.add_argument("--surface", dest="surfaces", action="append", choices=sorted(SURFACE_MAPPINGS))
    init.add_argument(
        "--materialize-project",
        action="store_true",
        help="create missing docs/project/** files from scaffolds/project/**",
    )
    sync = subparsers.add_parser("sync", help="update package-managed content from the lock-selected source")
    add_common(sync)
    sync.add_argument(
        "--detach-surface",
        dest="detach_surfaces",
        action="append",
        choices=sorted(SURFACE_MAPPINGS),
        help="make a selected collaboration surface consumer-owned by removing managed lock entries",
    )
    sync.set_defaults(entrypoints=None, surfaces=None, materialize_project=False)
    return parser


def main(argv):
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        plan = plan_operation(args)
        print_plan(plan, args.apply)
        if plan["refusals"]:
            return 1
        if args.apply:
            apply_writes(plan["target_root"], plan["writes"])
        return 0
    except (OSError, ValueError, SyncError) as exc:
        print(f"agent-context: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
