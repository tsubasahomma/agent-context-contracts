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

assert_not_contains() {
  file=$1
  needle=$2
  if grep -Fq -- "$needle" "$file"; then
    printf -- '--- %s ---\n' "$file" >&2
    sed -n '1,220p' "$file" >&2
    fail "expected output not to contain: $needle"
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

expect_installer_failure() {
  target=$1
  output=$2
  shift 2
  set +e
  run_installer "$target" "$output" "$@"
  status=$?
  set -e
  [ "$status" -ne 0 ] || fail "expected installer to fail for target: $target"
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
  source_repo=${5:-test-owner/test-repo}
  encoded_ref=${6:-main}
  mkdir -p "$bin_dir"
  cat >"${bin_dir}/curl" <<EOF
#!/bin/sh
archive='${archive}'
calls='${calls}'
commit='${commit}'
source_repo='${source_repo}'
encoded_ref='${encoded_ref}'

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

api_url="https://api.github.com/repos/\${source_repo}/commits/\${encoded_ref}"
archive_url="https://codeload.github.com/\${source_repo}/tar.gz/\${commit}"

if [ "\$url" = "\$api_url" ]; then
  printf '{"sha":"%s"}\n' "\$commit"
elif [ "\$url" = "\$archive_url" ]; then
  cat "\$archive"
else
  printf 'unexpected curl url: %s\n' "\$url" >&2
  exit 22
fi
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
    sh "$installer" --target "$target" "$@" >"$output" 2>&1
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

test_cli_repo_and_channel_flags_override_environment() {
  commit=6666666666666666666666666666666666666666
  archive="${tmp_root}/cli-config-source.tar.gz"
  fake_bin="${tmp_root}/cli-config-bin"
  calls="${tmp_root}/cli-config-curl-calls.log"
  make_source_archive "$archive" "$commit"
  make_fake_curl "$fake_bin" "$archive" "$calls" "$commit" "cli-owner/cli-repo" "feature%2Finstaller-hardening"

  target="${tmp_root}/cli-config-target"
  mkdir -p "$target"
  output="${tmp_root}/cli-config.out"
  run_installer "$target" "$output" --repo "cli-owner/cli-repo" --channel "feature/installer-hardening"

  assert_contains "$output" "Source: cli-owner/cli-repo"
  assert_contains "$output" "Channel: feature/installer-hardening"
  assert_contains "$output" "Resolved commit: ${commit}"
  assert_contains "$calls" "https://api.github.com/repos/cli-owner/cli-repo/commits/feature%2Finstaller-hardening"
  assert_contains "$calls" "https://codeload.github.com/cli-owner/cli-repo/tar.gz/${commit}"
  assert_not_contains "$calls" "https://api.github.com/repos/test-owner/test-repo/commits/main"
  assert_file "${target}/AGENTS.md"
  assert_no_path "${target}/agent-context.lock.json"

  pass "CLI repo and slash-containing channel flags override environment defaults and use encoded commit API URL"
}

test_source_owned_parent_symlink_refusal() {
  commit=3333333333333333333333333333333333333333
  archive="${tmp_root}/source-symlink-source-owned.tar.gz"
  fake_bin="${tmp_root}/source-symlink-bin"
  calls="${tmp_root}/source-symlink-curl-calls.log"
  make_source_archive "$archive" "$commit"
  make_fake_curl "$fake_bin" "$archive" "$calls" "$commit"

  target="${tmp_root}/source-symlink-target"
  external="${tmp_root}/source-symlink-external"
  mkdir -p "$target" "$external"
  ln -s "$external" "${target}/docs"

  output="${tmp_root}/source-symlink.out"
  expect_installer_failure "$target" "$output"

  assert_contains "$output" "unsafe destination docs/agent-context"
  assert_contains "$output" "parent component docs is a symlink"
  assert_no_path "${external}/agent-context"
  assert_no_path "${external}/project"
  assert_no_path "${target}/AGENTS.md"

  pass "source-owned payload refuses symlinked parent without writing outside target"
}

test_source_owned_file_parent_refusal() {
  commit=7777777777777777777777777777777777777777
  archive="${tmp_root}/source-file-parent-source-owned.tar.gz"
  fake_bin="${tmp_root}/source-file-parent-bin"
  calls="${tmp_root}/source-file-parent-curl-calls.log"
  make_source_archive "$archive" "$commit"
  make_fake_curl "$fake_bin" "$archive" "$calls" "$commit"

  target="${tmp_root}/source-file-parent-target"
  mkdir -p "$target"
  printf 'blocking docs file\n' >"${target}/docs"

  output="${tmp_root}/source-file-parent.out"
  expect_installer_failure "$target" "$output"

  assert_contains "$output" "unsafe destination docs/agent-context"
  assert_contains "$output" "parent component docs is not a directory"
  assert_file_contains "${target}/docs" "blocking docs file"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/CLAUDE.md"
  assert_no_path "${target}/agent-context.lock.json"

  pass "source-owned payload refuses non-directory parent before partial writes"
}

test_missing_only_parent_symlink_refusal() {
  commit=4444444444444444444444444444444444444444
  archive="${tmp_root}/source-symlink-missing-only.tar.gz"
  fake_bin="${tmp_root}/missing-symlink-bin"
  calls="${tmp_root}/missing-symlink-curl-calls.log"
  make_source_archive "$archive" "$commit"
  make_fake_curl "$fake_bin" "$archive" "$calls" "$commit"

  target="${tmp_root}/missing-symlink-target"
  external="${tmp_root}/missing-symlink-external"
  mkdir -p "$target" "$external"
  ln -s "$external" "${target}/.github"

  output="${tmp_root}/missing-symlink.out"
  expect_installer_failure "$target" "$output"

  assert_contains "$output" "unsafe destination .github/copilot-instructions.md"
  assert_contains "$output" "parent component .github is a symlink"
  assert_no_path "${external}/copilot-instructions.md"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/docs"

  pass "missing-only payload refuses symlinked parent without writing outside target"
}

test_missing_only_file_parent_refusal() {
  commit=8888888888888888888888888888888888888888
  archive="${tmp_root}/missing-file-parent-source.tar.gz"
  fake_bin="${tmp_root}/missing-file-parent-bin"
  calls="${tmp_root}/missing-file-parent-curl-calls.log"
  make_source_archive "$archive" "$commit"
  make_fake_curl "$fake_bin" "$archive" "$calls" "$commit"

  target="${tmp_root}/missing-file-parent-target"
  mkdir -p "$target"
  printf 'blocking github file\n' >"${target}/.github"

  output="${tmp_root}/missing-file-parent.out"
  expect_installer_failure "$target" "$output"

  assert_contains "$output" "unsafe destination .github/copilot-instructions.md"
  assert_contains "$output" "parent component .github is not a directory"
  assert_file_contains "${target}/.github" "blocking github file"
  assert_no_path "${target}/AGENTS.md"
  assert_no_path "${target}/docs"
  assert_no_path "${target}/CLAUDE.md"
  assert_no_path "${target}/GEMINI.md"
  assert_no_path "${target}/agent-context.lock.json"

  pass "missing-only payload refuses non-directory parent before partial writes"
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
test_cli_repo_and_channel_flags_override_environment
test_source_owned_parent_symlink_refusal
test_source_owned_file_parent_refusal
test_missing_only_parent_symlink_refusal
test_missing_only_file_parent_refusal
test_old_subcommands_are_not_public_lifecycle

log "completed ${pass_count} fixture checks"
