#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
default_source="$(cd -- "${script_dir}/.." && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  printf 'agent-context: python3 is required\n' >&2
  exit 127
fi

export AGENT_CONTEXT_DEFAULT_SOURCE="${default_source}"

exec python3 "${script_dir}/agent_context_cli.py" "$@"
