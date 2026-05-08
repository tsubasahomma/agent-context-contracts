#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
agent_tool="${repo_root}/tools/agent-context.sh"
sync_shim="${repo_root}/tools/sync-agent-context.sh"

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

pass_count=0

log() {
  printf 'sync-fixture: %s\n' "$*"
}

pass() {
  pass_count=$((pass_count + 1))
  log "PASS $*"
}

fail() {
  log "FAIL $*"
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "expected file: $1"
}

assert_no_path() {
  [ ! -e "$1" ] || fail "expected path to be absent: $1"
}

assert_contains() {
  file=$1
  needle=$2
  if ! grep -Fq -- "$needle" "$file"; then
    printf -- '--- %s ---\n' "$file" >&2
    sed -n '1,220p' "$file" >&2
    fail "expected output to contain: $needle"
  fi
}

expect_failure() {
  output=$1
  shift
  set +e
  "$@" >"${output}" 2>&1
  status=$?
  set -e
  [ "$status" -ne 0 ] || fail "expected command to fail: $*"
}

make_source() {
  destination=$1
  copy_source_tree "$destination"
  git -C "$destination" init -q -b main
  git -C "$destination" config user.email "fixture@example.invalid"
  git -C "$destination" config user.name "Sync Fixture"
  git -C "$destination" config commit.gpgsign false
  git -C "$destination" add -A
  git -C "$destination" commit -q -m "fixture source"
}

copy_source_tree() {
  destination=$1
  mkdir -p "$destination"
  (
    cd "$repo_root"
    tar -cf - AGENTS.md docs entrypoints surfaces scaffolds tools
  ) | (
    cd "$destination"
    tar -xf -
  )
}

commit_source_change() {
  source=$1
  message=$2
  git -C "$source" add -A
  git -C "$source" commit -q -m "$message"
}

init_target() {
  source=$1
  target=$2
  bash "$agent_tool" init \
    --source "$source" \
    --target "$target" \
    --entrypoint claude \
    --surface github \
    --materialize-project \
    --apply >/dev/null
}

assert_json_v03_lock() {
  lock=$1
  python3 - "$lock" <<'PY'
import json
import re
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["schema_version"] == "0.3"
assert data["source"]["repository"] == "local-source"
assert data["source"]["channel"] == "main"
assert re.match(r"^[0-9a-f]{40}$", data["source"]["resolved_commit"])
assert data["project_extension_path"] == "docs/project"
assert data["selected_entrypoints"] == [
    {"name": "claude", "source_path": "entrypoints/claude"}
]
assert data["selected_surfaces"] == [
    {"name": "github", "source_path": "surfaces/github", "detached": False}
]
managed = {entry["path"]: entry for entry in data["managed_files"]}
for required in [
    "AGENTS.md",
    "docs/agent-context/README.md",
    "docs/agent-context/path-ownership-and-sync-safety.md",
    "CLAUDE.md",
    ".github/pull_request_template.md",
    ".github/ISSUE_TEMPLATE/parent-program.yml",
    ".github/ISSUE_TEMPLATE/child-change.yml",
]:
    assert required in managed, required
assert "GEMINI.md" not in managed
for entry in data["managed_files"]:
    assert entry["ownership"] == "package-managed"
    assert not entry["path"].startswith("docs/project/")
    assert not entry["path"].startswith("tools/")
    assert not entry["source_path"].startswith("tools/")
    assert entry["checksum"]["algorithm"] == "sha256"
    assert re.match(r"^sha256:[0-9a-f]{64}$", entry["checksum"]["previous"])
    assert entry["checksum"]["previous"] == entry["checksum"]["target"]
    group = entry["group"]
    assert group["kind"] in {"portable-core", "entrypoint", "surface"}
    if group["kind"] == "portable-core":
        assert group["name"] is None
    elif group["kind"] == "entrypoint":
        assert group["name"] == "claude"
    elif group["kind"] == "surface":
        assert group["name"] == "github"
PY
}

assert_no_project_or_tool_managed() {
  lock=$1
  python3 - "$lock" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
for entry in data["managed_files"]:
    assert not entry["path"].startswith("docs/project/"), entry["path"]
    assert not entry["path"].startswith("tools/"), entry["path"]
    assert not entry["source_path"].startswith("tools/"), entry["source_path"]
PY
}

assert_lock_missing_path() {
  lock=$1
  missing=$2
  python3 - "$lock" "$missing" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
paths = {entry["path"] for entry in data["managed_files"]}
assert sys.argv[2] not in paths
PY
}

test_dry_run_clean_no_mutation() {
  source="${tmp_root}/source-dry"
  target="${tmp_root}/dry-run-clean"
  make_source "$source"
  mkdir -p "$target"
  output="${tmp_root}/dry-run-clean.out"
  bash "$agent_tool" init --source "$source" --target "$target" --entrypoint claude --surface github >"$output"
  assert_contains "$output" "Command: agent-context init"
  assert_contains "$output" "Mode: dry-run"
  assert_contains "$output" "CREATE AGENTS.md"
  assert_contains "$output" "CREATE CLAUDE.md"
  assert_contains "$output" "LOCK create agent-context.lock.json"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/agent-context.lock.json"
  pass "dry-run init reports writes without mutation"
}

test_apply_clean_and_parse_lock() {
  source="${tmp_root}/source-apply"
  target="${tmp_root}/apply-clean"
  make_source "$source"
  mkdir -p "$target"
  output="${tmp_root}/apply-clean.out"
  init_target "$source" "$target" >"$output"
  assert_file "${target}/AGENTS.md"
  assert_file "${target}/docs/agent-context/README.md"
  assert_file "${target}/CLAUDE.md"
  assert_file "${target}/.github/pull_request_template.md"
  assert_file "${target}/docs/project/profile.md"
  assert_no_path "${target}/tools/agent-context.sh"
  assert_no_path "${target}/tools/sync-agent-context.sh"
  assert_file "${target}/agent-context.lock.json"
  assert_json_v03_lock "${target}/agent-context.lock.json"
  pass "apply init writes v0.3 managed files and valid lock"
}

test_sync_uses_lock_selected_groups() {
  source="${tmp_root}/source-sync-selection"
  target="${tmp_root}/sync-selection"
  make_source "$source"
  mkdir -p "$target"
  init_target "$source" "$target"
  printf '\nSource entrypoint update fixture.\n' >>"${source}/entrypoints/claude/CLAUDE.md"
  printf '\nSource surface update fixture.\n' >>"${source}/surfaces/github/pull_request_template.md"
  commit_source_change "$source" "update selected payloads"
  output="${tmp_root}/sync-selection.out"
  bash "$agent_tool" sync --source "$source" --target "$target" --apply >"$output"
  assert_contains "$output" "Command: agent-context sync"
  assert_contains "$output" "Selected entrypoints: claude"
  assert_contains "$output" "Selected surfaces: github"
  assert_contains "$output" "UPDATE CLAUDE.md"
  assert_contains "$output" "UPDATE .github/pull_request_template.md"
  assert_contains "${target}/CLAUDE.md" "Source entrypoint update fixture."
  assert_contains "${target}/.github/pull_request_template.md" "Source surface update fixture."
  pass "sync uses lock-selected entrypoints and surfaces without re-selection"
}

test_sync_dry_run_no_mutation() {
  source="${tmp_root}/source-sync-dry"
  target="${tmp_root}/sync-dry"
  make_source "$source"
  mkdir -p "$target"
  init_target "$source" "$target"
  printf '\nDry-run source update fixture.\n' >>"${source}/AGENTS.md"
  commit_source_change "$source" "update source for dry run"
  cp "${target}/AGENTS.md" "${tmp_root}/sync-dry-agents.before"
  cp "${target}/agent-context.lock.json" "${tmp_root}/sync-dry-lock.before"
  output="${tmp_root}/sync-dry.out"
  bash "$agent_tool" sync --source "$source" --target "$target" >"$output"
  assert_contains "$output" "Command: agent-context sync"
  assert_contains "$output" "Mode: dry-run"
  assert_contains "$output" "UPDATE AGENTS.md"
  cmp -s "${target}/AGENTS.md" "${tmp_root}/sync-dry-agents.before" \
    || fail "managed file changed during sync dry-run"
  cmp -s "${target}/agent-context.lock.json" "${tmp_root}/sync-dry-lock.before" \
    || fail "lock changed during sync dry-run"
  pass "sync dry-run reports updates without mutation"
}

test_modified_managed_refusal() {
  source="${tmp_root}/source-modified"
  target="${tmp_root}/modified-managed"
  make_source "$source"
  mkdir -p "$target"
  init_target "$source" "$target"
  printf '\nconsumer edit\n' >>"${target}/AGENTS.md"
  cp "${target}/agent-context.lock.json" "${tmp_root}/modified-managed.lock.before"
  output="${tmp_root}/modified-managed.out"
  expect_failure "$output" bash "$agent_tool" sync --source "$source" --target "$target" --apply
  assert_contains "$output" "REFUSE AGENTS.md (dirty managed file"
  assert_contains "${target}/AGENTS.md" "consumer edit"
  cmp -s "${target}/agent-context.lock.json" "${tmp_root}/modified-managed.lock.before" \
    || fail "lock changed after modified managed refusal"
  pass "dirty managed file is refused and preserved atomically"
}

test_source_removal_deletes_clean_managed_file() {
  source="${tmp_root}/source-removal"
  target="${tmp_root}/source-removal-target"
  make_source "$source"
  mkdir -p "$target"
  init_target "$source" "$target"
  rm -f "${source}/docs/agent-context/evaluations.md"
  commit_source_change "$source" "remove managed source file"
  output="${tmp_root}/source-removal.out"
  bash "$agent_tool" sync --source "$source" --target "$target" --apply >"$output"
  assert_contains "$output" "DELETE docs/agent-context/evaluations.md"
  assert_no_path "${target}/docs/agent-context/evaluations.md"
  assert_lock_missing_path "${target}/agent-context.lock.json" "docs/agent-context/evaluations.md"
  pass "clean managed source removal deletes destination and advances lock"
}

test_dirty_source_removal_refusal() {
  source="${tmp_root}/source-removal-dirty"
  target="${tmp_root}/source-removal-dirty-target"
  make_source "$source"
  mkdir -p "$target"
  init_target "$source" "$target"
  rm -f "${source}/docs/agent-context/evaluations.md"
  output="${tmp_root}/dirty-source-removal.out"
  expect_failure "$output" bash "$agent_tool" sync --source "$source" --target "$target" --apply
  assert_contains "$output" "REFUSE source (source package is dirty"
  assert_file "${target}/docs/agent-context/evaluations.md"
  pass "dirty source refuses apply before managed deletion"
}

test_unresolved_source_refusal_and_local_development_metadata() {
  source="${tmp_root}/source-unresolved"
  target="${tmp_root}/unresolved-target"
  local_target="${tmp_root}/local-development-target"
  copy_source_tree "$source"
  mkdir -p "$target" "$local_target"
  output="${tmp_root}/unresolved-source.out"
  expect_failure "$output" bash "$agent_tool" init --source "$source" --target "$target" --apply
  assert_contains "$output" "REFUSE source (source channel cannot be resolved to a full commit SHA)"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/agent-context.lock.json"

  local_output="${tmp_root}/local-development.out"
  bash "$agent_tool" init \
    --source "$source" \
    --target "$local_target" \
    --local-development \
    --apply >"$local_output"
  assert_contains "$local_output" "LOCAL-DEVELOPMENT local-development mode applied from an unresolved source"
  python3 - "${local_target}/agent-context.lock.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["schema_version"] == "0.3"
assert data["source"]["channel"] == "unresolved-local"
assert data["source"]["resolved_commit"] == "0" * 40
assert data["local_development"]["enabled"] is True
assert data["local_development"]["unresolved_source"] is True
PY
  pass "unresolved source refuses by default and local-development mode is explicit in output and lock"
}

test_requested_channel_mismatch_refusal() {
  source="${tmp_root}/source-channel-mismatch"
  target="${tmp_root}/channel-mismatch-target"
  make_source "$source"
  git -C "$source" switch -q -c feature
  printf '\nFeature source bytes that are not main.\n' >>"${source}/AGENTS.md"
  commit_source_change "$source" "feature source update"
  mkdir -p "$target"
  output="${tmp_root}/channel-mismatch.out"
  expect_failure "$output" bash "$agent_tool" init --source "$source" --target "$target" --channel main --apply
  assert_contains "$output" "REFUSE source (source checkout HEAD does not match requested source channel main"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/agent-context.lock.json"
  pass "requested source channel must resolve to the checkout bytes being applied"
}

test_unowned_collision_refusal() {
  source="${tmp_root}/source-collision"
  target="${tmp_root}/unowned-collision"
  make_source "$source"
  mkdir -p "$target"
  printf 'pre-existing entry point\n' >"${target}/AGENTS.md"
  output="${tmp_root}/unowned-collision.out"
  expect_failure "$output" bash "$agent_tool" init --source "$source" --target "$target" --apply
  assert_contains "$output" "REFUSE AGENTS.md (unowned destination collision"
  assert_contains "${target}/AGENTS.md" "pre-existing entry point"
  assert_no_path "${target}/agent-context.lock.json"
  pass "existing unowned portable-core collision is refused"
}

test_entrypoint_unowned_collision_refusal() {
  source="${tmp_root}/source-entry-collision"
  target="${tmp_root}/entrypoint-collision"
  make_source "$source"
  mkdir -p "$target"
  printf 'pre-existing entrypoint file\n' >"${target}/CLAUDE.md"
  output="${tmp_root}/entrypoint-collision.out"
  expect_failure "$output" bash "$agent_tool" init --source "$source" --target "$target" --entrypoint claude --apply
  assert_contains "$output" "REFUSE CLAUDE.md (unowned destination collision"
  assert_contains "${target}/CLAUDE.md" "pre-existing entrypoint file"
  assert_no_path "${target}/agent-context.lock.json"
  pass "existing unowned entrypoint destination is refused"
}

test_project_scaffold_materialize_and_preserve() {
  source="${tmp_root}/source-project"
  target="${tmp_root}/project-materialize"
  make_source "$source"
  mkdir -p "$target"
  init_target "$source" "$target"
  assert_file "${target}/docs/project/profile.md"
  assert_no_project_or_tool_managed "${target}/agent-context.lock.json"
  printf '\nlocal profile edit\n' >>"${target}/docs/project/profile.md"
  cp "${target}/docs/project/profile.md" "${tmp_root}/profile.before"
  printf '\nSource scaffold change that must not sync.\n' >>"${source}/scaffolds/project/profile.md"
  commit_source_change "$source" "change project scaffold"
  output="${tmp_root}/project-sync.out"
  bash "$agent_tool" sync --source "$source" --target "$target" --apply >"$output"
  assert_contains "$output" "SKIP docs/project (project extension is consumer-owned)"
  cmp -s "${target}/docs/project/profile.md" "${tmp_root}/profile.before" \
    || fail "project extension file was overwritten"
  assert_no_project_or_tool_managed "${target}/agent-context.lock.json"
  pass "project scaffold materialization is not lock-managed and sync preserves docs/project"
}

test_malformed_unsupported_and_inconsistent_locks() {
  source="${tmp_root}/source-locks"
  make_source "$source"
  target="${tmp_root}/bad-lock"
  mkdir -p "$target"
  printf '{ bad json\n' >"${target}/agent-context.lock.json"
  output="${tmp_root}/bad-lock.out"
  expect_failure "$output" bash "$agent_tool" sync --source "$source" --target "$target" --apply
  assert_contains "$output" "malformed JSON"
  assert_no_path "${target}/AGENTS.md"

  target2="${tmp_root}/unsupported-lock"
  mkdir -p "$target2"
  printf '{"schema_version":"0.1","source_ref":"legacy","managed_files":[]}\n' >"${target2}/agent-context.lock.json"
  output2="${tmp_root}/unsupported-lock.out"
  expect_failure "$output2" bash "$agent_tool" sync --source "$source" --target "$target2" --apply
  assert_contains "$output2" "unsupported schema_version"
  assert_no_path "${target2}/AGENTS.md"

  target3="${tmp_root}/inconsistent-lock"
  mkdir -p "$target3"
  printf '{"schema_version":"0.3","source":{"repository":"local-source","channel":"main","resolved_commit":"0000000000000000000000000000000000000000"},"project_extension_path":"docs/project","selected_entrypoints":[],"selected_surfaces":[],"managed_files":[{"path":"docs/project/profile.md","source_path":"docs/project/profile.md","ownership":"package-managed","group":{"kind":"portable-core","name":null},"checksum":{"algorithm":"sha256","previous":"sha256:0000000000000000000000000000000000000000000000000000000000000000","target":"sha256:0000000000000000000000000000000000000000000000000000000000000000"}}],"created_by":{"tool":"agent-context","version":"0.3"}}\n' >"${target3}/agent-context.lock.json"
  output3="${tmp_root}/inconsistent-lock.out"
  expect_failure "$output3" bash "$agent_tool" sync --source "$source" --target "$target3" --apply
  assert_contains "$output3" "must not manage project extension files"
  assert_no_path "${target3}/AGENTS.md"
  pass "malformed, unsupported, and inconsistent locks refuse before writes"
}

test_symlink_lock_refusal() {
  source="${tmp_root}/source-symlink"
  target="${tmp_root}/symlink-lock"
  make_source "$source"
  mkdir -p "$target"
  printf '{}\n' >"${tmp_root}/external-lock.json"
  ln -s "${tmp_root}/external-lock.json" "${target}/agent-context.lock.json"
  output="${tmp_root}/symlink-lock.out"
  expect_failure "$output" bash "$agent_tool" sync --source "$source" --target "$target" --apply
  assert_contains "$output" "lock file must not be a symlink"
  assert_no_path "${target}/AGENTS.md"
  [ -L "${target}/agent-context.lock.json" ] || fail "symlink lock was replaced"
  pass "symlink lock refuses before writes"
}

test_partial_failure_rollback() {
  source="${tmp_root}/source-rollback"
  target="${tmp_root}/partial-failure"
  make_source "$source"
  mkdir -p "$target"
  output="${tmp_root}/partial-failure.out"
  expect_failure "$output" env \
    AGENT_CONTEXT_SYNC_FAIL_AFTER_WRITES=1 \
    bash "$agent_tool" init --source "$source" --target "$target" --apply
  assert_contains "$output" "ROLLBACK complete"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/agent-context.lock.json"
  bash "$agent_tool" init --source "$source" --target "$target" --apply >/dev/null
  assert_file "${target}/AGENTS.md"
  assert_file "${target}/agent-context.lock.json"
  pass "partial apply failure rolls back and target can recover"
}

test_compatibility_shim_invokes_sync() {
  source="${tmp_root}/source-shim"
  target="${tmp_root}/shim-target"
  make_source "$source"
  mkdir -p "$target"
  bash "$agent_tool" init --source "$source" --target "$target" --apply >/dev/null
  output="${tmp_root}/shim.out"
  bash "$sync_shim" --source "$source" --target "$target" >"$output" 2>&1
  assert_contains "$output" "compatibility shim"
  assert_contains "$output" "Command: agent-context sync"
  pass "legacy sync script is a thin compatibility shim"
}

test_dry_run_clean_no_mutation
test_apply_clean_and_parse_lock
test_sync_uses_lock_selected_groups
test_sync_dry_run_no_mutation
test_modified_managed_refusal
test_source_removal_deletes_clean_managed_file
test_dirty_source_removal_refusal
test_unresolved_source_refusal_and_local_development_metadata
test_requested_channel_mismatch_refusal
test_unowned_collision_refusal
test_entrypoint_unowned_collision_refusal
test_project_scaffold_materialize_and_preserve
test_malformed_unsupported_and_inconsistent_locks
test_symlink_lock_refusal
test_partial_failure_rollback
test_compatibility_shim_invokes_sync

log "completed ${pass_count} fixture checks"
