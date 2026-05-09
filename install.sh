#!/bin/sh

set -eu

default_repo="tsubasahomma/agent-context-contracts"
repo="${AGENT_CONTEXT_REPO:-$default_repo}"
channel="${AGENT_CONTEXT_CHANNEL:-main}"
target="."
dry_run=0

usage() {
  cat <<'USAGE'
Usage: sh install.sh [--dry-run] [--repo OWNER/REPO] [--channel REF] [--target DIR]

Install or refresh portable agent-context files in a consumer repository.

By default this resolves tsubasahomma/agent-context-contracts main to a full
commit SHA, downloads one GitHub archive for that commit, overwrites the
source-owned portable payload, and seeds missing-only payload files only when
the destination path is absent.

Environment:
  AGENT_CONTEXT_REPO      Source repository owner/name.
  AGENT_CONTEXT_CHANNEL   Source branch, tag, or commit selector.
  GITHUB_TOKEN            Optional token for GitHub API and archive requests.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    --repo)
      [ "$#" -ge 2 ] || {
        printf 'install.sh: --repo requires a value\n' >&2
        exit 64
      }
      repo=$2
      shift 2
      ;;
    --channel)
      [ "$#" -ge 2 ] || {
        printf 'install.sh: --channel requires a value\n' >&2
        exit 64
      }
      channel=$2
      shift 2
      ;;
    --target)
      [ "$#" -ge 2 ] || {
        printf 'install.sh: --target requires a value\n' >&2
        exit 64
      }
      target=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'install.sh: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'install.sh: %s is required\n' "$1" >&2
    exit 127
  fi
}

curl_fetch() {
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl -fsSL \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "$1"
  else
    curl -fsSL "$1"
  fi
}

urlencode_ref() {
  printf '%s' "$1" |
    sed \
      -e 's/%/%25/g' \
      -e 's/ /%20/g' \
      -e 's/#/%23/g' \
      -e 's/?/%3F/g' \
      -e 's#/#%2F#g'
}

unsafe_destination() {
  rel=$1
  reason=$2
  printf 'install.sh: unsafe destination %s: %s\n' "$rel" "$reason" >&2
  exit 73
}

validate_relative_destination() {
  rel=$1
  case "$rel" in
    ""|/*|*'//'*) unsafe_destination "$rel" "destination path must be repository-relative" ;;
  esac
  case "/${rel}/" in
    *"/./"*|*"/../"*) unsafe_destination "$rel" "destination path contains an unsafe segment" ;;
  esac
}

ensure_destination_parent_safe() {
  rel=$1
  validate_relative_destination "$rel"

  parent=$(dirname "$rel")
  [ "$parent" != "." ] || return 0

  current=$target_root
  rest=$parent
  while [ -n "$rest" ]; do
    case "$rest" in
      */*)
        component=${rest%%/*}
        rest=${rest#*/}
        ;;
      *)
        component=$rest
        rest=
        ;;
    esac

    current="${current}/${component}"
    if [ -L "$current" ]; then
      unsafe_destination "$rel" "parent component ${component} is a symlink"
    fi
    if [ -e "$current" ] && [ ! -d "$current" ]; then
      unsafe_destination "$rel" "parent component ${component} is not a directory"
    fi
    if [ ! -e "$current" ]; then
      return 0
    fi
  done
}

preflight_missing_only_destinations() {
  missing_root=$1
  [ -d "$missing_root" ] || return 0

  while IFS= read -r src; do
    [ -n "$src" ] || continue
    rel=${src#"$missing_root"/}
    ensure_destination_parent_safe "$rel"
  done <<EOF
$(find "$missing_root" -type f | LC_ALL=C sort)
EOF
}

preflight_destinations() {
  ensure_destination_parent_safe "AGENTS.md"
  ensure_destination_parent_safe "docs/agent-context"
  preflight_missing_only_destinations "$1"
}

copy_overwrite_file() {
  src=$1
  rel=$2
  ensure_destination_parent_safe "$rel"
  dst="${target_root}/${rel}"
  if [ "$dry_run" -eq 1 ]; then
    printf 'OVERWRITE %s\n' "$rel"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  cp "$src" "$dst"
}

replace_directory() {
  src=$1
  rel=$2
  ensure_destination_parent_safe "$rel"
  dst="${target_root}/${rel}"
  if [ "$dry_run" -eq 1 ]; then
    printf 'REPLACE %s/\n' "$rel"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  (
    cd "$src"
    tar -cf - .
  ) | (
    mkdir -p "$dst"
    cd "$dst"
    tar -xf -
  )
}

seed_missing_only() {
  missing_root=$1
  [ -d "$missing_root" ] || return 0

  find "$missing_root" -type f | LC_ALL=C sort | while IFS= read -r src; do
    rel=${src#"$missing_root"/}
    ensure_destination_parent_safe "$rel"
    dst="${target_root}/${rel}"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      printf 'SKIP existing %s\n' "$rel"
      continue
    fi
    if [ "$dry_run" -eq 1 ]; then
      printf 'CREATE missing-only %s\n' "$rel"
      continue
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    printf 'CREATE missing-only %s\n' "$rel"
  done
}

require_command curl
require_command sed
require_command tar
require_command mktemp
require_command find
require_command sort
require_command dirname

if [ ! -d "$target" ]; then
  printf 'install.sh: target is not a directory: %s\n' "$target" >&2
  exit 66
fi

target_root="$(cd "$target" && pwd -P)"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/agent-context-install.XXXXXX")"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT HUP INT TERM

encoded_channel="$(urlencode_ref "$channel")"
api_url="https://api.github.com/repos/${repo}/commits/${encoded_channel}"
commit="$(
  curl_fetch "$api_url" |
    sed -n 's/^.*"sha":[[:space:]]*"\([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]\)".*/\1/p' |
    sed -n '1p'
)"

if [ -z "$commit" ]; then
  printf 'install.sh: could not resolve %s %s to a full commit SHA\n' "$repo" "$channel" >&2
  exit 69
fi

archive="${tmp_dir}/source.tar.gz"
source_dir="${tmp_dir}/source"
mkdir -p "$source_dir"
archive_url="https://codeload.github.com/${repo}/tar.gz/${commit}"
curl_fetch "$archive_url" >"$archive"
tar -xzf "$archive" --strip-components=1 -C "$source_dir"

if [ ! -f "${source_dir}/AGENTS.md" ] || [ ! -d "${source_dir}/docs/agent-context" ]; then
  printf 'install.sh: source archive does not contain the portable payload\n' >&2
  exit 65
fi

preflight_destinations "${source_dir}/payload/missing-only"

printf 'Source: %s\n' "$repo"
printf 'Channel: %s\n' "$channel"
printf 'Resolved commit: %s\n' "$commit"
printf 'Target: %s\n' "$target_root"
if [ "$dry_run" -eq 1 ]; then
  printf 'Mode: dry-run\n'
else
  printf 'Mode: apply\n'
fi

copy_overwrite_file "${source_dir}/AGENTS.md" "AGENTS.md"
replace_directory "${source_dir}/docs/agent-context" "docs/agent-context"
seed_missing_only "${source_dir}/payload/missing-only"

printf 'Done.\n'
