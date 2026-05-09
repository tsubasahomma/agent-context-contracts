# Parent #37 Final Closure Audit

This repository-local historical audit was created for Child Issue #48 after
Parent Issue #37 had already been closed. It records post-merge evidence for
whether Parent #37 can remain closed. It is not portable doctrine and does not
belong under `docs/agent-context/**`.

## Changed Files

- `docs/project/reports/parent-37-final-audit.md`: new repository-local audit
  record.
- `tests/fixtures/sync/README.md`: narrow correction from stale v0.1 fixture
  wording to current v0.3 fixture coverage.

## Evidence Inspected

- Parent Issue #37.
- Child Issues #38, #40, #42, #44, #46, and #48.
- Merged PRs #39, #41, #43, #45, and #47.
- Root and contract files: `AGENTS.md`, `README.md`,
  `docs/agent-context/README.md`, and
  `docs/agent-context/path-ownership-and-sync-safety.md`.
- Lifecycle tooling and fixtures: `tools/agent-context.sh`,
  `tools/agent_context_cli.py`, `tools/sync-agent-context.sh`, and
  `tests/run-sync-fixtures.sh`.
- Active source taxonomy: `entrypoints/**`, `surfaces/**`, and
  `scaffolds/project/**`.

## Parent #37 Acceptance Matrix

| Criterion | Status | Merged evidence |
| --- | --- | --- |
| Source tree uses `entrypoints/**`, `surfaces/**`, and `scaffolds/project/**`. | passed | PR #41 moved active optional content and project starters into those trees; local path inspection found those trees and no active `adapters/**` or `templates/**` directories. |
| Portable core sync target is `AGENTS.md` plus `docs/agent-context/**`. | passed | PR #39 defined the contract baseline; `tools/agent_context_cli.py` collects `AGENTS.md` and `docs/agent-context/**`; generated-lock inspection listed portable core managed entries. |
| `tools/*` is not part of default consumer managed payload. | passed | PR #43 removed default tool management; fixture and generated-lock inspections showed no `tools/**` entries in `managed_files[]`. |
| `init` and `sync` are the primary documented lifecycle commands. | passed | PR #43 implemented `tools/agent-context.sh init` and `sync`; PR #47 documented only the curl-first `init` / `sync` lifecycle. |
| Lock schema records source channel and resolved commit SHA. | passed | PR #43 implemented v0.3 `source.channel` and `source.resolved_commit`; PR #47 added archive `--resolved-commit`; generated locks recorded `channel=main` and a full 40-character SHA. |
| Lock-selected optional entrypoints and surfaces update safely by checksum. | passed | `tests/run-sync-fixtures.sh` passed lock-selected entrypoint and surface update coverage. |
| Clean package-managed source removals delete on `sync --apply`. | passed | `tests/run-sync-fixtures.sh` passed clean managed source-removal deletion coverage. |
| Dirty managed files and unowned collisions are refused. | passed | `tests/run-sync-fixtures.sh` passed dirty managed-file refusal, portable-core collision refusal, and entrypoint collision refusal coverage. |
| Materialized `docs/project/**` files remain consumer-owned. | passed | PR #43 excluded project scaffolds from `managed_files[]`; PR #45 added advisory-only scaffold drift; generated-lock inspection showed no `docs/project/**` managed entries. |
| Collaboration surfaces can remain package-managed until explicitly detached. | passed | PR #45 implemented `agent-context sync --detach-surface <name>`; fixtures passed detach dry-run, detach apply, dirty surface detach, and later sync non-remanagement coverage. |
| Root README explains adoption and update flow without becoming the contract body. | passed | PR #47 added `README.md`; README links to durable contracts and documents adoption/update at a high level. |
| Tests cover lifecycle smoke, ownership boundaries, deletion, and refusal behavior. | passed | `tests/run-sync-fixtures.sh` completed 20 fixture checks on the merged main baseline. |

## Validation Evidence

| Command or check | Status | Evidence |
| --- | --- | --- |
| `tests/run-sync-fixtures.sh` | passed | Completed 20 fixture checks. |
| `tools/lint-portability.sh` | passed | Exited 0. |
| `git diff --check` after audit edits | passed | Exited 0. |
| README Markdown link check | passed | Checked 8 local Markdown links. |
| Markdown link check for `docs/agent-context/**`, `entrypoints/**`, `surfaces/**`, and `scaffolds/**` | passed | Checked 104 local Markdown links. |
| Archive/curl-first smoke test for `main` | passed | Authenticated curl resolved `main` to `4ee8d127dcd1ed7a91903564949b5e14ee4f0bc5`, downloaded the codeload archive, ran `init` dry-run, `init --apply`, and `sync` dry-run, and inspected lock metadata. |
| Generated-lock inspection from fresh adoption | passed | Observed `schema_version=0.3`, `source_repository=tsubasahomma/agent-context-contracts`, `source_channel=main`, 40-character resolved commit, selected entrypoints `claude,github-copilot`, selected surface `github`, `has_tools_managed=False`, `has_project_managed=False`, and materialized project files outside lock management. |
| Targeted old taxonomy and v0.1 search | passed after narrow fix | Active `adapters/**` and `templates/**` directories were absent. Historical mapping notes remained in `entrypoints/README.md`, `surfaces/README.md`, `scaffolds/README.md`, and the path ownership contract. Legacy `source_ref` remained only in an unsupported-lock refusal fixture and unrelated `source_refs` evidence-pack schema wording. Stale v0.1 fixture README wording was corrected in this PR. |

## Curl And Credential Notes

The remote archive smoke used authenticated curl through the available GitHub
CLI token because this private repository requires credentials for codeload
access. The README's `GITHUB_TOKEN` path matches that requirement. No network
blocker remained after authenticated access was available.

## Blockers, Contradictions, And Residual Risks

One narrow repository defect was found and fixed: `tests/fixtures/sync/README.md`
still described v0.1 sync behavior, transitional adapter flags, tool copying,
and source-removal preservation even though the active fixture runner now covers
v0.3 behavior. No runtime defect was found in lifecycle tooling.

No contradiction was found between Parent #37 decisions and merged repository
state after that fix.

Residual risks:

- Anonymous codeload access may fail for this private repository; authenticated
  `GITHUB_TOKEN` access is documented and was validated.
- Detached surface re-adoption remains intentionally out of Parent #37 scope.
- Branch names containing slashes may require a GitHub refs API lookup instead
  of the README's simpler `commits/${channel}` pattern; the documented `main`
  channel path was validated.

## Recommendation

Parent Issue #37 can remain closed after the stale fixture README wording fix in
this PR is merged. The aggregate merged evidence satisfies every Parent #37
acceptance criterion, and the remaining risks are explicit non-goals or access
caveats rather than blockers.
