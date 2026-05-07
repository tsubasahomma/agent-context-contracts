# Codex Adapter

This adapter provides an optional Codex-specific entry point for a consumer
repository. It helps local Codex configuration examples route agents back to the
portable contracts and the consumer-owned project extension without making Codex
behavior part of the portable core.

The adapter is not the source of durable operating-contract rules. Durable rules
belong in the root `AGENTS.md`, the portable contract index at
[docs/agent-context/README.md](../../docs/agent-context/README.md), and any
materialized project extension under `docs/project/**`.

## Payload Mapping

The Codex adapter stores payload files under `adapters/codex/files/**`. When a
consumer explicitly selects this adapter, the payload maps to the following
Codex destination path:

| Source payload | Intended destination |
| --- | --- |
| `adapters/codex/files/.codex/config.example.toml` | `.codex/config.example.toml` |

The source payload path is package-owned adapter content. The destination path
is a Codex-specific example configuration file in a consumer repository.

## Installation Boundary

Installation is optional and explicit. The presence of this adapter in a source
package MUST NOT install Codex payload files by itself.

A sync or adoption process MAY install the payload only when the Codex adapter
is selected. Unselected adapter payloads MUST NOT create, update, remove, or
record destination files.

Installing this adapter does not materialize `docs/project/**`, does not create
sync tooling, and does not change portable core contracts. Project extension
files remain consumer-owned after creation.

## Ownership And Collision Rules

When a selected adapter creates a missing destination file and records it through
sync or an explicit adoption process, the destination file becomes an
adapter-installed managed file. It MAY be updated later only when the Codex
adapter is selected and checksum or adoption evidence says the update is safe.

Existing unowned destination files MUST NOT be overwritten. If a consumer already
has a file at the Codex destination path that is not recorded as
adapter-managed, the adapter install or update MUST refuse that path and
preserve the existing file. A future recovery or adoption process may define how
to intentionally adopt such a file, but this adapter does not define that
process.

This adapter does not perform semantic merges. It follows the path ownership and
sync safety boundaries in
[docs/agent-context/path-ownership-and-sync-safety.md](../../docs/agent-context/path-ownership-and-sync-safety.md).

## Routing Contract

Installed Codex entry points should route agents to the current durable context
in this order:

1. Read the root `AGENTS.md` entry point.
2. Read `docs/agent-context/README.md` and the relevant portable contracts.
3. Read materialized `docs/project/**` files when present for repository-local
   identity, surfaces, validation commands, workflow exceptions, and policy.
4. Treat missing `docs/project/**` files as missing local extension evidence,
   not as permission to invent local facts.

The Codex payload may provide Codex-specific example configuration content. It
MUST NOT duplicate or replace portable-core doctrine, project-local facts, sync
implementation behavior, or future adapter rules for other tools.

## Payload Content Rules

The Codex TOML payload MUST remain generic, safe example content. It MUST NOT
claim to be a required portable baseline or assert universal Codex runtime
behavior.

The payload MUST NOT include real repository names, maintainer names,
host-absolute paths, local command lines, secrets, tokens, private identifiers,
concrete issue or pull request numbers, external URLs, or assumptions about
non-Codex tools.

When a consumer needs local facts or supported local Codex settings, record them
in the materialized project extension or local configuration owned by that
consumer instead of editing this adapter payload as the durable source of those
facts.
