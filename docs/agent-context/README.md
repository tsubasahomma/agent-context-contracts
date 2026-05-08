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
| [Core contract](core.md) | Defines the shared portable principles and boundary between core, local extensions, optional entrypoints, optional collaboration surfaces, and tooling. |
| [Source precedence and trust boundaries](sources.md) | Defines portable source classes, trust boundaries, and claim-type conflict handling without a universal override stack. |
| [Artifact contracts](artifacts.md) | Defines the portable durable artifact model, metadata, provenance, evidence-reference, schema, and uncertainty expectations. |
| [Agent-authored output contracts](outputs.md) | Defines portable durable text output categories, output-role boundaries, safe body handling, and reviewable change-proposal and change-message defaults. |
| [Workflow contracts](workflows.md) | Defines portable thread roles, bounded handoffs, scope preservation, readiness reporting, and the change lifecycle. |
| [Validation contracts](validation.md) | Defines the portable validation claim model, status vocabulary, evidence requirements, and success-claim rules. |
| [Evidence-packing contracts](evidence-packing.md) | Defines the tool-neutral boundary for packaging evidence without choosing a specific packing tool. |
| [Evaluation contracts](evaluations.md) | Defines concrete reviewable pass/fail cases for predictable contract failures. |
| [Path ownership and sync safety](path-ownership-and-sync-safety.md) | Defines the v0.3 curl-first `init` / `sync` lifecycle, source and destination ownership, lock metadata, checksum-safe update and deletion behavior, and overwrite refusal behavior. |

## Lifecycle And Ownership

The target v0.3 public lifecycle is curl-first `init` and `sync`.

`init` performs initial adoption. `sync` updates package-managed content from
the resolved source package. Dry-run is the default; writes require `--apply` or
an equivalent explicit apply signal.

The portable core sync target is `AGENTS.md` plus `docs/agent-context/**`.
Selected entrypoints from `entrypoints/**` and selected collaboration surfaces
from `surfaces/**` are package-managed only when selected and recorded in
`agent-context.lock.json`. Project scaffolds from `scaffolds/project/**` may
materialize missing `docs/project/**` files during adoption, but materialized
project files are consumer-owned after creation.

Source-package tooling is distribution machinery, not default consumer managed
payload. The root `agent-context.lock.json` file records sync metadata,
including source channel and resolved commit, but it does not own portable
contract doctrine.

## Ownership Boundary

Portable files in this directory own reusable collaboration contracts only. They
MUST NOT own repository identity, local source maps, local validation commands,
secrets policy details, optional entrypoint or surface payloads, sync-tool
implementation behavior, or portability-lint implementation behavior except
where a contract explicitly defines a boundary for later work.

Later detailed contracts should extend the specific file that owns their topic.
They should add narrow normative sections instead of duplicating rules across the
contract set.
