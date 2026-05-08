# Agent Context Contracts

This directory contains portable operating contracts for agent collaboration in a
consumer repository. The contracts are repository-agnostic: they define reusable
boundaries, expectations, and extension points without embedding local identity,
host details, commands, secrets, or tool-specific baseline assumptions.

Project-local context belongs under `docs/project/**` when a consumer repository
needs to describe its own surfaces, validation commands, workflow exceptions, or
policy details.

## Contract Set

| Contract | Purpose |
| --- | --- |
| [Core contract](core.md) | Defines the shared portable principles and boundary between core, local extensions, adapters, and tooling. |
| [Artifact contracts](artifacts.md) | Defines the portable durable artifact model, metadata, provenance, evidence-reference, schema, and uncertainty expectations. |
| [Workflow contracts](workflows.md) | Defines portable thread roles, bounded handoffs, scope preservation, readiness reporting, and the change lifecycle. |
| [Validation contracts](validation.md) | Defines the portable validation claim model, status vocabulary, evidence requirements, and success-claim rules. |
| [Evidence-packing contracts](evidence-packing.md) | Defines the tool-neutral boundary for packaging evidence without choosing a specific packing tool. |
| [Evaluation contracts](evaluations.md) | Defines concrete reviewable pass/fail cases for predictable contract failures. |
| [Path ownership and sync safety](path-ownership-and-sync-safety.md) | Defines source and destination ownership, lock-file ownership, checksum-safe sync decisions, and overwrite refusal behavior. |

## Tool Entry Points

`tools/lint-portability.sh` is the v0.1 read-only portability lint entry point.
With no arguments, it scans `AGENTS.md` and `docs/agent-context/**`. Explicit
path arguments may be used to scan synthetic fixtures or review-specific paths.

`tools/sync-agent-context.sh` is the v0.1 safe vendored-snapshot sync entry
point. It defaults to dry-run, requires `--apply` before writing, accepts
explicit `--adapter` selections, and seeds missing project extension files only
when `--seed-project` is passed. `tests/run-sync-fixtures.sh` exercises the
sync safety cases against temporary consumer targets.

## Ownership Boundary

Portable files in this directory own reusable collaboration contracts only. They
MUST NOT own repository identity, local source maps, local validation commands,
secrets policy details, adapter payloads, sync-tool implementation behavior, or
portability-lint implementation behavior except where a contract explicitly
defines a boundary for later work.

Later detailed contracts should extend the specific file that owns their topic.
They should add narrow normative sections instead of duplicating rules across the
contract set.
