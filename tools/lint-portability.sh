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
  .agent/**
  docs/agent-context/**
  payload/missing-only/**

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
        line ~ /(shim|surface|payload).*(explicit|generic|boundary|tool-specific|missing-only)/ ||
        line ~ /claim to be/ ||
        line ~ /assert universal/ ||
        line ~ /forbidden/ ||
        line ~ /fail condition/ ||
        line ~ /belongs in/
    }

    function boundary_or_negative_allowed(line) {
      return line ~ /must not/ ||
        line ~ /does not/ ||
        line ~ /do not/ ||
        line ~ /not required/ ||
        line ~ /not mirrored/ ||
        line ~ /not mirror/ ||
        line ~ /not manually mirror/ ||
        line ~ /without/ ||
        line ~ /belongs (in|to)/ ||
        line ~ /local .*policy/ ||
        line ~ /project .*extension/ ||
        line ~ /(shim|surface).*(owned|local|boundary|mapping|optional|missing-only)/ ||
        line ~ /placeholder/ ||
        line ~ /explicit placeholders?/ ||
        line ~ /fail condition/ ||
        line ~ /manual review/ ||
        line ~ /evaluation cases?/
    }

    function command_baseline_allowed(line) {
      return boundary_or_negative_allowed(line) ||
        line ~ /command placeholder/ ||
        line ~ /repository-owned tool entry point/
    }

    function dynamic_status_allowed(line) {
      return boundary_or_negative_allowed(line) ||
        line ~ /observed/ ||
        line ~ /observation point/ ||
        line ~ /freshness/ ||
        line ~ /evidence/ ||
        line ~ /limitation/ ||
        line ~ /current state/ ||
        line ~ /always-current truth/ ||
        line ~ /status vocabulary/ ||
        line ~ /pending/ ||
        line ~ /skipped/ ||
        line ~ /not_required/ ||
        line ~ /maintainer_confirmed/ ||
        line ~ /failed/
    }

    function reusable_text_surface(file) {
      return file ~ /^AGENTS\.md$/ ||
        file ~ /^\.agent\// ||
        file ~ /^docs\/agent-context\// ||
        file ~ /^payload\/missing-only\// ||
        file ~ /^tests\/fixtures\/portability-lint\// ||
        file ~ /\.(md|markdown|txt|yml|yaml)$/
    }

    function reusable_payload_or_fixture(file) {
      return file ~ /^payload\/missing-only\// ||
        file ~ /^tests\/fixtures\/portability-lint\//
    }

    function static_template_status_surface(file) {
      return file ~ /^payload\/missing-only\// ||
        reusable_payload_or_fixture(file)
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

      if (reusable_text_surface(file) &&
          (line ~ /(^|[^a-z0-9_<])#[0-9]+([^0-9]|$)/ ||
           line ~ /(issue|pull request|pr|ticket|tracker|bug|story)[[:space:]]*#?[0-9]+/)) {
        report("concrete-tracker-reference", "reusable surfaces must use placeholders or local policy for concrete issue, pull request, or tracker references")
      }

      if (reusable_text_surface(file) &&
          (line ~ /(^|[^a-z])((close[sd]?)|(fix(e[sd])?)|(resolve[sd]?))[[:space:]]+#[0-9]+([^0-9]|$)/)) {
        report("concrete-closing-reference", "portable or generic text must not include concrete issue-closing keywords with real tracker numbers")
      }

      if (reusable_text_surface(file) &&
          (line ~ /branch[ _-]*(prefix|name|naming|default)[[:space:]]*[:=][[:space:]]*[`"]?[a-z0-9][a-z0-9._-]*\// ||
           line ~ /(all|new|default|every)[[:space:]][^.;:]*branches?[^.;:]*(must|shall|required|always|use)[^.;:]*[a-z0-9][a-z0-9._-]*\/[a-z0-9._\/-]*/)) {
        report("concrete-branch-default", "portable or generic text must not embed concrete branch naming defaults or prefixes")
      }

      if (reusable_text_surface(file) &&
          !command_baseline_allowed(line) &&
          (line ~ /(must|shall|required|requires|always|default|baseline)[^.;:]*(run|use|invoke|execute)[^.;:]*(gh|git|make|npm|pnpm|yarn|pytest|tox|cargo|go test|mvn|gradle|docker|kubectl)([^a-z0-9_-]|$)/ ||
           line ~ /default[ _-]*(command|validation command)[[:space:]]*[:=][[:space:]]*[`"]?(gh|git|make|npm|pnpm|yarn|pytest|tox|cargo|go test|mvn|gradle|docker|kubectl)([^a-z0-9_-]|$)/)) {
        report("local-command-baseline", "portable or generic text must not present concrete local or platform commands as reusable baseline behavior")
      }

      if (static_template_status_surface(file) &&
          !dynamic_status_allowed(line) &&
          line ~ /(^|[^a-z])(ci|check|checks|status|review|deployment|deploy|release|external)([^a-z]|$)/ &&
          line ~ /(^|[^a-z])(passed|passing|approved|deployed|released|current|complete|green)([^a-z]|$)/) {
        report("dynamic-status-mirroring", "static templates and durable examples must not mirror dynamic CI, review, deployment, release, or external status as current truth")
      }

      if (reusable_payload_or_fixture(file) &&
          !boundary_or_negative_allowed(line) &&
          (raw ~ /^#{1,3}[[:space:]]*(Portable[[:space:]]+)?(Operating[[:space:]]+Contract|Durable[[:space:]]+Operating[[:space:]]+Rules|Workflow[[:space:]]+Contract|Validation[[:space:]]+Contract|Source[[:space:]]+Precedence|Agent[[:space:]]+Context[[:space:]]+Contracts)/ ||
           line ~ /(this template|this form|this file).*(authoritative|durable|complete).*(manual|contract|source of truth|operating rules)/)) {
        report("platform-template-manualization", "reusable payloads must route durable operating rules to owning contracts")
      }

      if (reusable_text_surface(file) &&
          !boundary_or_negative_allowed(line) &&
          (line ~ /dotfiles[- ]only/ ||
           line ~ /(copied|migrated|ported)[^.;:]*(dotfiles|legacy)/)) {
        report("historical-evidence-leak", "historical dotfiles evidence must not be copied into reusable lint, fixture, payload, surface, or contract text")
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
  scan_target "${repo_root}/.agent"
  scan_target "${repo_root}/docs/agent-context"
  scan_target "${repo_root}/payload/missing-only"
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
