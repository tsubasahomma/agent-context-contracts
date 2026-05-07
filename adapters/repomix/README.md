# Repomix Adapter

This adapter provides optional Repomix-oriented evidence-packing guidance for a
consumer repository. It helps consumers that choose a Repomix-based workflow
route generated or summarized evidence back to the portable contracts and the
consumer-owned project extension without making Repomix part of the portable
core.

The adapter is not the source of durable operating-contract rules. Durable rules
belong in the root `AGENTS.md`, the portable contract index at
[docs/agent-context/README.md](../../docs/agent-context/README.md), and any
materialized project extension under `docs/project/**`.

## Payload Mapping

The Repomix adapter stores payload files under `adapters/repomix/files/**`. When
a consumer explicitly selects this adapter, the payload maps to the following
destination path:

| Source payload | Intended destination |
| --- | --- |
| `adapters/repomix/files/repomix-instructions.md` | `repomix-instructions.md` |

The source payload path is package-owned adapter content. The destination path
is an optional Repomix-oriented instruction file in a consumer repository.

## Installation Boundary

Installation is optional and explicit. The presence of this adapter in a source
package MUST NOT install Repomix payload files by itself.

A sync or adoption process MAY install the payload only when the Repomix adapter
is selected. Unselected adapter payloads MUST NOT create, update, remove, or
record destination files.

Installing this adapter does not require Repomix, does not materialize
`docs/project/**`, does not create evidence packs, does not create sync tooling,
and does not change portable core contracts. Project extension files remain
consumer-owned after creation.

## Ownership And Collision Rules

When a selected adapter creates a missing destination file and records it through
sync or an explicit adoption process, the destination file becomes an
adapter-installed managed file. It MAY be updated later only when the Repomix
adapter is selected and checksum or adoption evidence says the update is safe.

Existing unowned destination files MUST NOT be overwritten. If a consumer already
has `repomix-instructions.md` and it is not recorded as adapter-managed, the
adapter install or update MUST refuse that path and preserve the existing file.
A future recovery or adoption process may define how to intentionally adopt such
a file, but this adapter does not define that process.

This adapter does not perform semantic merges. It follows the path ownership and
sync safety boundaries in
[docs/agent-context/path-ownership-and-sync-safety.md](../../docs/agent-context/path-ownership-and-sync-safety.md).

## Adapter Boundary

Repomix-specific behavior belongs in this adapter or in consumer-owned local
workflow documentation. It MUST NOT be copied into portable core contracts as a
baseline requirement.

The payload `repomix-instructions.md` is a generic adapter payload. It is not a
repository-local evidence pack, not a generated context pack, and not durable
portable-core doctrine.

The adapter does not define Repomix command syntax, generated output format,
configuration files, token budgets, source selection logic, or redaction
implementation. Consumers that use Repomix SHOULD document local workflow facts,
allowed surfaces, validation commands, and secrets policy in `docs/project/**`
when those details matter.

## Routing Contract

Installed Repomix payloads should route maintainers and agents to the current
durable context in this order:

1. Read the root `AGENTS.md` entry point.
2. Read `docs/agent-context/README.md` and the relevant portable contracts,
   especially `docs/agent-context/evidence-packing.md`,
   `docs/agent-context/artifacts.md`, `docs/agent-context/validation.md`, and
   `docs/agent-context/workflows.md`.
3. Read materialized `docs/project/**` files when present for repository-local
   identity, surfaces, validation commands, workflow exceptions, secrets policy,
   and sensitive-data boundaries.
4. Treat missing `docs/project/**` files as missing local extension evidence,
   not as permission to invent local facts or include unrestricted surfaces.

The payload should preserve local secrets policy, project surface boundaries,
and the portable validation vocabulary. It MUST NOT duplicate or replace
portable-core doctrine, project-local facts, sync implementation behavior, or
future adapter rules for other tools.

## Payload Content Rules

Repomix payload files MUST remain generic. They MUST NOT include real repository
names, maintainer names, host-absolute paths, local command lines, secrets,
tokens, private identifiers, concrete issue or pull request numbers, external
URLs, generated evidence pack contents, or unsupported claims about Repomix
behavior.

When a consumer needs local facts, record them in the materialized project
extension instead of editing this adapter payload as the durable source of those
facts.
