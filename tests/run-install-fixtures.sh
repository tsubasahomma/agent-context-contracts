#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"
installer="${repo_root}/install.sh"

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

pass_count=0

log() {
  printf 'install-fixture: %s\n' "$*"
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

assert_file_contains() {
  file=$1
  needle=$2
  assert_file "$file"
  grep -Fq -- "$needle" "$file" || fail "expected $file to contain: $needle"
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

make_source_archive() {
  destination=$1
  commit=$2
  source_parent="${tmp_root}/source-parent"
  source_tree="${source_parent}/agent-context-contracts-${commit}"
  rm -rf "$source_parent"
  mkdir -p "$source_tree"
  (
    cd "$repo_root"
    tar -cf - AGENTS.md docs/agent-context payload/missing-only
  ) | (
    cd "$source_tree"
    tar -xf -
  )
  tar -czf "$destination" -C "$source_parent" "agent-context-contracts-${commit}"
}

make_fake_curl() {
  bin_dir=$1
  archive=$2
  calls=$3
  commit=$4
  mkdir -p "$bin_dir"
  cat >"${bin_dir}/curl" <<EOF
#!/bin/sh
archive='${archive}'
calls='${calls}'
commit='${commit}'

url=''
while [ "\$#" -gt 0 ]; do
  case "\$1" in
    -H)
      shift 2
      ;;
    -*)
      shift
      ;;
    *)
      url=\$1
      shift
      ;;
  esac
done

printf '%s\n' "\$url" >>"\$calls"

case "\$url" in
  https://api.github.com/repos/test-owner/test-repo/commits/main)
    printf '{"sha":"%s"}\n' "\$commit"
    ;;
  https://codeload.github.com/test-owner/test-repo/tar.gz/"\$commit")
    cat "\$archive"
    ;;
  *)
    printf 'unexpected curl url: %s\n' "\$url" >&2
    exit 22
    ;;
esac
EOF
  chmod +x "${bin_dir}/curl"
}

run_installer() {
  target=$1
  output=$2
  shift 2
  PATH="${fake_bin}:$PATH" \
    AGENT_CONTEXT_REPO="test-owner/test-repo" \
    AGENT_CONTEXT_CHANNEL="main" \
    sh "$installer" --target "$target" "$@" >"$output"
}

test_install_and_refresh_behavior() {
  commit=1111111111111111111111111111111111111111
  archive="${tmp_root}/source.tar.gz"
  fake_bin="${tmp_root}/bin"
  calls="${tmp_root}/curl-calls.log"
  make_source_archive "$archive" "$commit"
  make_fake_curl "$fake_bin" "$archive" "$calls" "$commit"

  source_tree="${tmp_root}/source-parent/agent-context-contracts-${commit}"
  target="${tmp_root}/target"
  mkdir -p "${target}/docs/agent-context" "${target}/docs/project" "${target}/.github"
  printf 'stale AGENTS\n' >"${target}/AGENTS.md"
  printf 'stale portable README\n' >"${target}/docs/agent-context/README.md"
  printf 'stale portable extra\n' >"${target}/docs/agent-context/obsolete.md"
  printf 'consumer profile\n' >"${target}/docs/project/profile.md"
  printf 'consumer Claude file\n' >"${target}/CLAUDE.md"
  printf 'consumer Copilot file\n' >"${target}/.github/copilot-instructions.md"

  output="${tmp_root}/install.out"
  run_installer "$target" "$output"

  assert_contains "$output" "Resolved commit: ${commit}"
  cmp -s "${source_tree}/AGENTS.md" "${target}/AGENTS.md" ||
    fail "AGENTS.md was not overwritten from source archive"
  cmp -s "${source_tree}/docs/agent-context/README.md" "${target}/docs/agent-context/README.md" ||
    fail "docs/agent-context/README.md was not overwritten from source archive"
  assert_no_path "${target}/docs/agent-context/obsolete.md"
  assert_file_contains "${target}/docs/project/profile.md" "consumer profile"
  cmp -s "${source_tree}/payload/missing-only/docs/project/README.md" "${target}/docs/project/README.md" ||
    fail "missing docs/project/README.md was not seeded"
  assert_file_contains "${target}/CLAUDE.md" "consumer Claude file"
  assert_file_contains "${target}/.github/copilot-instructions.md" "consumer Copilot file"
  cmp -s "${source_tree}/payload/missing-only/GEMINI.md" "${target}/GEMINI.md" ||
    fail "missing GEMINI.md vendor shim was not seeded"
  assert_no_path "${target}/agent-context.lock.json"
  assert_no_path "${target}/tools/agent-context.sh"
  assert_no_path "${target}/.github/pull_request_template.md"
  assert_no_path "${target}/.github/ISSUE_TEMPLATE"
  assert_no_path "${target}/.gemini/config.yaml"

  printf 'consumer edit that should be refreshed\n' >"${target}/AGENTS.md"
  printf 'consumer profile after refresh\n' >"${target}/docs/project/profile.md"
  refresh_output="${tmp_root}/refresh.out"
  run_installer "$target" "$refresh_output"

  cmp -s "${source_tree}/AGENTS.md" "${target}/AGENTS.md" ||
    fail "AGENTS.md was not refreshed on second installer run"
  assert_file_contains "${target}/docs/project/profile.md" "consumer profile after refresh"
  assert_file_contains "${target}/CLAUDE.md" "consumer Claude file"
  assert_no_path "${target}/agent-context.lock.json"

  api_count=$(grep -c 'api.github.com/repos/test-owner/test-repo/commits/main' "$calls")
  archive_count=$(grep -c "codeload.github.com/test-owner/test-repo/tar.gz/${commit}" "$calls")
  [ "$api_count" -eq 2 ] || fail "expected two commit resolution calls, got $api_count"
  [ "$archive_count" -eq 2 ] || fail "expected one archive fetch per run, got $archive_count"

  pass "installer overwrites portable payload, seeds missing-only files, preserves consumer files, and creates no lock"
}

test_dry_run_does_not_mutate() {
  commit=2222222222222222222222222222222222222222
  archive="${tmp_root}/dry-source.tar.gz"
  fake_bin="${tmp_root}/dry-bin"
  calls="${tmp_root}/dry-curl-calls.log"
  make_source_archive "$archive" "$commit"
  make_fake_curl "$fake_bin" "$archive" "$calls" "$commit"

  target="${tmp_root}/dry-target"
  mkdir -p "$target"
  output="${tmp_root}/dry-run.out"
  run_installer "$target" "$output" --dry-run

  assert_contains "$output" "Mode: dry-run"
  assert_contains "$output" "OVERWRITE AGENTS.md"
  assert_contains "$output" "REPLACE docs/agent-context/"
  assert_contains "$output" "CREATE missing-only CLAUDE.md"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/docs"
  assert_no_path "${target}/agent-context.lock.json"

  pass "dry-run reports installer actions without mutating the target"
}

test_old_subcommands_are_not_public_lifecycle() {
  output="${tmp_root}/unknown-subcommand.out"
  expect_failure "$output" sh "$installer" init
  assert_contains "$output" "unknown option: init"

  output_sync="${tmp_root}/unknown-sync.out"
  expect_failure "$output_sync" sh "$installer" sync
  assert_contains "$output_sync" "unknown option: sync"

  pass "old init and sync subcommands are not public installer commands"
}

test_install_and_refresh_behavior
test_dry_run_does_not_mutate
test_old_subcommands_are_not_public_lifecycle

log "completed ${pass_count} fixture checks"
