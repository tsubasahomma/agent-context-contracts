#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
sync_tool="${repo_root}/tools/sync-agent-context.sh"

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
    printf '--- %s ---\n' "$file" >&2
    sed -n '1,220p' "$file" >&2
    fail "expected output to contain: $needle"
  fi
}

assert_not_contains() {
  file=$1
  needle=$2
  if grep -Fq -- "$needle" "$file"; then
    printf '--- %s ---\n' "$file" >&2
    sed -n '1,220p' "$file" >&2
    fail "expected output not to contain: $needle"
  fi
}

assert_json_clean_lock() {
  lock=$1
  python3 - "$lock" <<'PY'
import json
import re
import sys

path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
assert data["schema_version"] == "0.1"
assert data["package_version"] == "0.1.0"
assert data["project_extension_path"] == "docs/project"
assert data["created_by"]["tool"] == "sync-agent-context"
assert data["created_by"]["version"] == "0.1.0"
assert data["installed_adapters"] == []
managed = {entry["path"]: entry for entry in data["managed_files"]}
for required in [
    "AGENTS.md",
    "docs/agent-context/README.md",
    "docs/agent-context/path-ownership-and-sync-safety.md",
    "tools/lint-portability.sh",
    "tools/sync-agent-context.sh",
]:
    assert required in managed, required
for entry in data["managed_files"]:
    assert not entry["path"].startswith("docs/project/")
    assert entry["ownership"] == "package-managed"
    assert entry.get("source_adapter") is None
    checksum = entry["checksum"]
    assert checksum["algorithm"] == "sha256"
    assert re.match(r"^sha256:[0-9a-f]{64}$", checksum["previous"])
    assert checksum["previous"] == checksum["target"]
PY
}

assert_json_adapter_lock() {
  lock=$1
  python3 - "$lock" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
installed = [item["name"] for item in data["installed_adapters"]]
assert installed == ["claude"], installed
managed = {entry["path"]: entry for entry in data["managed_files"]}
assert "CLAUDE.md" in managed
assert managed["CLAUDE.md"]["ownership"] == "adapter-installed"
assert managed["CLAUDE.md"]["source_adapter"] == "claude"
assert "GEMINI.md" not in managed
PY
}

assert_json_no_project_managed() {
  lock=$1
  python3 - "$lock" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
for entry in data["managed_files"]:
    assert not entry["path"].startswith("docs/project/"), entry["path"]
PY
}

assert_json_preserved_removed_source() {
  lock=$1
  python3 - "$lock" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
managed = {entry["path"]: entry for entry in data["managed_files"]}
assert "docs/agent-context/evaluations.md" in managed
PY
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

copy_source() {
  destination=$1
  mkdir -p "$destination"
  (
    cd "$repo_root"
    tar -cf - AGENTS.md docs tools adapters templates
  ) | (
    cd "$destination"
    tar -xf -
  )
}

copy_source_without_one_file() {
  destination=$1
  copy_source "$destination"
  rm -f "${destination}/docs/agent-context/evaluations.md"
}

test_dry_run_clean_no_mutation() {
  target="${tmp_root}/dry-run-clean"
  mkdir -p "$target"
  output="${tmp_root}/dry-run-clean.out"
  bash "$sync_tool" --source "$repo_root" --target "$target" >"$output"
  assert_contains "$output" "Mode: dry-run"
  assert_contains "$output" "CREATE AGENTS.md"
  assert_contains "$output" "LOCK create agent-context.lock.json"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/agent-context.lock.json"
  pass "dry-run clean target reports writes without mutation"
}

test_apply_clean_and_parse_lock() {
  target="${tmp_root}/apply-clean"
  mkdir -p "$target"
  output="${tmp_root}/apply-clean.out"
  bash "$sync_tool" --source "$repo_root" --target "$target" --apply >"$output"
  assert_file "${target}/AGENTS.md"
  assert_file "${target}/docs/agent-context/README.md"
  assert_file "${target}/tools/sync-agent-context.sh"
  assert_file "${target}/agent-context.lock.json"
  assert_json_clean_lock "${target}/agent-context.lock.json"
  pass "apply clean target writes managed files and valid lock"
}

test_modified_managed_refusal() {
  target="${tmp_root}/modified-managed"
  mkdir -p "$target"
  bash "$sync_tool" --source "$repo_root" --target "$target" --apply >/dev/null
  printf 'consumer edit\n' >>"${target}/AGENTS.md"
  cp "${target}/agent-context.lock.json" "${tmp_root}/modified-managed.lock.before"
  output="${tmp_root}/modified-managed.out"
  expect_failure "$output" bash "$sync_tool" --source "$repo_root" --target "$target" --apply
  assert_contains "$output" "REFUSE AGENTS.md (modified managed file"
  assert_contains "${target}/AGENTS.md" "consumer edit"
  cmp -s "${target}/agent-context.lock.json" "${tmp_root}/modified-managed.lock.before" \
    || fail "lock changed after modified managed refusal"
  pass "modified managed file is refused and preserved"
}

test_checksum_safe_update() {
  target="${tmp_root}/checksum-update-target"
  source_update="${tmp_root}/checksum-update-source"
  mkdir -p "$target"
  bash "$sync_tool" --source "$repo_root" --target "$target" --apply >/dev/null
  copy_source "$source_update"
  printf '\nSource package update fixture.\n' >>"${source_update}/AGENTS.md"
  output="${tmp_root}/checksum-update.out"
  bash "$sync_tool" --source "$source_update" --target "$target" --apply >"$output"
  assert_contains "$output" "UPDATE AGENTS.md"
  assert_contains "${target}/AGENTS.md" "Source package update fixture."
  python3 - "${target}/agent-context.lock.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
entry = next(item for item in data["managed_files"] if item["path"] == "AGENTS.md")
assert entry["checksum"]["previous"] == entry["checksum"]["target"]
PY
  pass "checksum-matching managed file updates safely"
}

test_unowned_collision_refusal() {
  target="${tmp_root}/unowned-collision"
  mkdir -p "$target"
  printf 'pre-existing entry point\n' >"${target}/AGENTS.md"
  output="${tmp_root}/unowned-collision.out"
  expect_failure "$output" bash "$sync_tool" --source "$repo_root" --target "$target" --apply
  assert_contains "$output" "REFUSE AGENTS.md (unowned destination collision"
  assert_contains "${target}/AGENTS.md" "pre-existing entry point"
  assert_no_path "${target}/agent-context.lock.json"
  pass "existing unowned package collision is refused"
}

test_selected_adapter_and_unselected_skip() {
  target="${tmp_root}/selected-adapter"
  mkdir -p "$target"
  output="${tmp_root}/selected-adapter.out"
  bash "$sync_tool" --source "$repo_root" --target "$target" --adapter claude --apply >"$output"
  assert_contains "$output" "ADAPTER claude (selected)"
  assert_contains "$output" "SKIP gemini (adapter not selected)"
  assert_file "${target}/CLAUDE.md"
  assert_no_path "${target}/GEMINI.md"
  assert_json_adapter_lock "${target}/agent-context.lock.json"
  pass "selected adapter installs and unselected adapter is skipped"
}

test_adapter_unowned_collision_refusal() {
  target="${tmp_root}/adapter-collision"
  mkdir -p "$target"
  printf 'pre-existing adapter file\n' >"${target}/CLAUDE.md"
  output="${tmp_root}/adapter-collision.out"
  expect_failure "$output" bash "$sync_tool" --source "$repo_root" --target "$target" --adapter claude --apply
  assert_contains "$output" "REFUSE CLAUDE.md (unowned destination collision"
  assert_contains "${target}/CLAUDE.md" "pre-existing adapter file"
  assert_no_path "${target}/agent-context.lock.json"
  pass "existing unowned adapter destination is refused"
}

test_project_extension_seed_and_preserve() {
  target="${tmp_root}/project-seed"
  mkdir -p "$target"
  bash "$sync_tool" --source "$repo_root" --target "$target" --seed-project --apply >/dev/null
  assert_file "${target}/docs/project/README.md"
  assert_file "${target}/docs/project/profile.md"
  assert_json_no_project_managed "${target}/agent-context.lock.json"
  printf '\nlocal profile edit\n' >>"${target}/docs/project/profile.md"
  cp "${target}/docs/project/profile.md" "${tmp_root}/profile.before"
  output="${tmp_root}/project-seed-again.out"
  bash "$sync_tool" --source "$repo_root" --target "$target" --seed-project --apply >"$output"
  assert_contains "$output" "PRESERVE docs/project/profile.md (project extension exists; consumer-owned)"
  cmp -s "${target}/docs/project/profile.md" "${tmp_root}/profile.before" \
    || fail "project extension file was overwritten"
  assert_json_no_project_managed "${target}/agent-context.lock.json"
  pass "project extension is seeded once and then preserved"
}

test_malformed_and_unsupported_lock_refusal() {
  target="${tmp_root}/bad-lock"
  mkdir -p "$target"
  printf '{ bad json\n' >"${target}/agent-context.lock.json"
  cp "${target}/agent-context.lock.json" "${tmp_root}/bad-lock.before"
  output="${tmp_root}/bad-lock.out"
  expect_failure "$output" bash "$sync_tool" --source "$repo_root" --target "$target" --apply
  assert_contains "$output" "REFUSE agent-context.lock.json"
  assert_no_path "${target}/AGENTS.md"
  cmp -s "${target}/agent-context.lock.json" "${tmp_root}/bad-lock.before" \
    || fail "malformed lock changed"

  target2="${tmp_root}/unsupported-lock"
  mkdir -p "$target2"
  cat >"${target2}/agent-context.lock.json" <<'JSON'
{
  "schema_version": "9.9",
  "package_version": "0.1.0",
  "source_ref": "synthetic-source",
  "project_extension_path": "docs/project",
  "managed_files": [],
  "installed_adapters": [],
  "created_by": {
    "tool": "sync-agent-context",
    "version": "0.1.0"
  }
}
JSON
  output2="${tmp_root}/unsupported-lock.out"
  expect_failure "$output2" bash "$sync_tool" --source "$repo_root" --target "$target2" --apply
  assert_contains "$output2" "unsupported schema_version"
  assert_no_path "${target2}/AGENTS.md"
  pass "malformed and unsupported locks refuse before writes"
}

test_source_removal_preserve() {
  target="${tmp_root}/source-removal-target"
  source_removed="${tmp_root}/source-removed"
  mkdir -p "$target"
  bash "$sync_tool" --source "$repo_root" --target "$target" --apply >/dev/null
  copy_source_without_one_file "$source_removed"
  output="${tmp_root}/source-removal.out"
  bash "$sync_tool" --source "$source_removed" --target "$target" --apply >"$output"
  assert_contains "$output" "PRESERVE docs/agent-context/evaluations.md"
  assert_file "${target}/docs/agent-context/evaluations.md"
  assert_json_preserved_removed_source "${target}/agent-context.lock.json"
  pass "source removal preserves destination by default"
}

test_partial_failure_rollback() {
  target="${tmp_root}/partial-failure"
  mkdir -p "$target"
  output="${tmp_root}/partial-failure.out"
  expect_failure "$output" env \
    AGENT_CONTEXT_SYNC_TEST_MODE=1 \
    AGENT_CONTEXT_SYNC_FAIL_AFTER_WRITES=1 \
    bash "$sync_tool" --source "$repo_root" --target "$target" --apply
  assert_contains "$output" "ROLLBACK complete"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/agent-context.lock.json"
  bash "$sync_tool" --source "$repo_root" --target "$target" --apply >/dev/null
  assert_file "${target}/AGENTS.md"
  assert_file "${target}/agent-context.lock.json"
  pass "partial apply failure rolls back and target can recover"
}

test_dry_run_clean_no_mutation
test_apply_clean_and_parse_lock
test_modified_managed_refusal
test_checksum_safe_update
test_unowned_collision_refusal
test_selected_adapter_and_unselected_skip
test_adapter_unowned_collision_refusal
test_project_extension_seed_and_preserve
test_malformed_and_unsupported_lock_refusal
test_source_removal_preserve
test_partial_failure_rollback

log "completed ${pass_count} fixture checks"
