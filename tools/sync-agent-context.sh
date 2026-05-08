#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

printf 'sync-agent-context: compatibility shim; use agent-context sync\n' >&2

case "${1:-}" in
  init|sync)
    exec "${script_dir}/agent-context.sh" "$@"
    ;;
  *)
    exec "${script_dir}/agent-context.sh" sync "$@"
    ;;
esac
