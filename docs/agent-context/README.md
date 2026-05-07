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
| [Artifact contracts](artifacts.md) | Reserves the place for durable artifact expectations without defining schemas yet. |
| [Workflow contracts](workflows.md) | Reserves the place for collaboration workflow expectations without defining detailed role or handoff rules yet. |
| [Validation contracts](validation.md) | Reserves the place for evidence-backed validation expectations without defining the full validation vocabulary yet. |
| [Evidence-packing contracts](evidence-packing.md) | Defines the tool-neutral boundary for packaging evidence without choosing a specific packing tool. |
| [Evaluation contracts](evaluations.md) | Reserves the place for reviewable evaluation rules without adding concrete test cases yet. |
| [Path ownership and sync safety](path-ownership-and-sync-safety.md) | Defines source and destination ownership, lock-file ownership, checksum-safe sync decisions, and overwrite refusal behavior. |

## Ownership Boundary

Portable files in this directory own reusable collaboration contracts only. They
MUST NOT own repository identity, local source maps, local validation commands,
secrets policy details, adapter payloads, sync-tool implementation behavior, or
portability-lint implementation behavior except where a contract explicitly
defines a boundary for later work.

Later detailed contracts should extend the specific file that owns their topic.
They should add narrow normative sections instead of duplicating rules across the
contract set.
