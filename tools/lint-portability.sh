#!/usr/bin/env bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

usage() {
  cat <<'USAGE'
Usage: tools/lint-portability.sh [PATH ...]

Scans portable agent-context files for repository-local facts and portability
boundary drift. With no PATH arguments, the default scan surface is:

  AGENTS.md
  docs/agent-context/**

Explicit PATH arguments may name files or directories, including synthetic
fixtures. The tool is read-only, does not use the network, and exits non-zero
when findings are detected.
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

missing=0
findings=0

display_path() {
  case "$1" in
    "${repo_root}"/*) printf '%s\n' "${1#"${repo_root}/"}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

resolve_path() {
  path=$1
  case "$path" in
    /*)
      printf '%s\n' "$path"
      ;;
    *)
      if [ -e "$path" ]; then
        dir=$(dirname -- "$path")
        base=$(basename -- "$path")
        printf '%s/%s\n' "$(cd -- "$dir" && pwd -P)" "$base"
      elif [ -e "${repo_root}/${path}" ]; then
        printf '%s\n' "${repo_root}/${path}"
      else
        printf '%s\n' "${repo_root}/${path}"
      fi
      ;;
  esac
}

is_text_file() {
  LC_ALL=C grep -Iq . "$1" 2>/dev/null || [ ! -s "$1" ]
}

scan_file() {
  file=$1
  shown=$(display_path "$file")

  if ! is_text_file "$file"; then
    return 0
  fi

  awk -v file="$shown" '
    function report(rule, message) {
      printf "%s:%d: %s: %s\n", file, NR, rule, message
      found = 1
    }

    function tool_boundary_allowed(line) {
      return line ~ /must not/ ||
        line ~ /does not require/ ||
        line ~ /do not require/ ||
        line ~ /not required/ ||
        line ~ /not a .*requirement/ ||
        line ~ /optional/ ||
        line ~ /(adapter|payload).*(selected|explicit|generic|boundary|tool-specific)/ ||
        line ~ /claim to be/ ||
        line ~ /assert universal/ ||
        line ~ /forbidden/ ||
        line ~ /fail condition/ ||
        line ~ /belongs in/
    }

    {
      raw = $0
      line = tolower(raw)

      if (raw ~ /https?:\/\/(www\.)?(github|gitlab|bitbucket)\.com\/[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+/) {
        report("repo-identity", "portable files must not embed concrete hosted repository URLs")
      }
      if (raw ~ /git@(github|gitlab|bitbucket)\.com:[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+/) {
        report("repo-identity", "portable files must not embed concrete hosted repository SSH locators")
      }
      if (line ~ /(repo|repository|project|module|package)[ _-]*(name|slug|id)?[[:space:]]*[:=][[:space:]]*[a-z0-9_.-]+\/[a-z0-9_.-]+/) {
        report("repo-identity", "portable files must not embed concrete repository owner/name identifiers")
      }

      if (line ~ /[[:alnum:]._%+-]+@[[:alnum:].-]+\.[a-z][a-z]+/) {
        report("private-identifier", "portable files must not embed personal or private email identifiers")
      }
      if (line ~ /(private|internal|confidential)[_-][[:alnum:]_-]+/) {
        report("private-identifier", "portable files must not embed private or internal identifier tokens")
      }
      if (line ~ /(employee|customer|tenant|account|workspace|organization|org|maintainer)[ _-]?(id|key|slug)?[[:space:]]*[:=][[:space:]]*[[:alnum:]_.:-][[:alnum:]_.:-][[:alnum:]_.:-][[:alnum:]_.:-][[:alnum:]_.:-]/) {
        report("private-identifier", "portable files must not embed private organization, user, tenant, or account identifiers")
      }
      if (line ~ /(api|access|secret|private)[_-]?(key|token|secret)[[:space:]]*[:=][[:space:]]*[^[:space:]`][^[:space:]`][^[:space:]`][^[:space:]`][^[:space:]`][^[:space:]`][^[:space:]`][^[:space:]`]/) {
        report("private-identifier", "portable files must not embed secret-adjacent key or token values")
      }

      if (raw ~ /\/Users\/[A-Za-z0-9_.-]+/ ||
          raw ~ /\/home\/[A-Za-z0-9_.-]+/ ||
          raw ~ /~\/[A-Za-z0-9_.-]+/ ||
          raw ~ /[A-Za-z]:\\\\/) {
        report("host-specific", "portable files must not embed host-specific filesystem paths")
      }
      if (line ~ /(localhost|127\.0\.0\.1|0\.0\.0\.0)(:[0-9]+)?/) {
        report("host-specific", "portable files must not assume local hostnames or ports")
      }
      if (line ~ /[a-z0-9.-]+\.(local|lan|internal)([^a-z0-9]|$)/) {
        report("host-specific", "portable files must not embed private hostnames")
      }

      if (line ~ /(codex|claude|gemini|github copilot|copilot|repomix)/ &&
          line ~ /(must|shall|required|requires|require|baseline|only supported|always use|default tool|all agents)/ &&
          !tool_boundary_allowed(line)) {
        report("tool-baseline", "portable files must not require a specific agent or evidence-packing tool as baseline")
      }

      if (line ~ /legacy[- ]only[ _-]*(path|command|repo|repository|host|fact)[[:space:]]*[:=]/ ||
          line ~ /(copied from|kept from) legacy/) {
        report("legacy-only-fact", "portable files must not preserve legacy-only facts as reusable contract content")
      }
    }

    END {
      if (found) {
        exit 1
      }
    }
  ' "$file"
}

scan_target() {
  target=$1
  resolved=$(resolve_path "$target")

  if [ ! -e "$resolved" ]; then
    printf '%s: missing path\n' "$target" >&2
    missing=1
    return
  fi

  if [ -d "$resolved" ]; then
    while IFS= read -r file; do
      [ -n "$file" ] || continue
      if scan_file "$file"; then
        :
      else
        findings=1
      fi
    done <<EOF
$(find "$resolved" -type f | LC_ALL=C sort)
EOF
  else
    if scan_file "$resolved"; then
      :
    else
      findings=1
    fi
  fi
}

if [ "$#" -eq 0 ]; then
  scan_target "${repo_root}/AGENTS.md"
  scan_target "${repo_root}/docs/agent-context"
else
  for arg in "$@"; do
    scan_target "$arg"
  done
fi

if [ "$missing" -ne 0 ]; then
  exit 2
fi

if [ "$findings" -ne 0 ]; then
  exit 1
fi

exit 0
