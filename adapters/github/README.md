# GitHub Adapter

This adapter provides optional GitHub collaboration-platform entry points for a
consumer repository. It helps GitHub issues, pull requests, and GitHub-hosted
agent instruction files route people and agents back to the portable contracts
and the consumer-owned project extension.

The adapter is not the source of durable operating-contract rules. Durable rules
belong in the root `AGENTS.md`, the portable contract index at
[docs/agent-context/README.md](../../docs/agent-context/README.md), and any
materialized project extension under `docs/project/**`.

GitHub entry points MAY make portable defaults easier to use on GitHub, but they
do not make GitHub issue forms, pull request templates, labels, checkboxes,
reviewer requests, milestones, status checks, issue-linking syntax, or command
interfaces portable requirements.

## Payload Mapping

The GitHub adapter stores payload files under `adapters/github/files/**`. When a
consumer explicitly selects this adapter, those payloads map to the following
GitHub destination paths:

| Source payload | Intended destination |
| --- | --- |
| `adapters/github/files/.github/copilot-instructions.md` | `.github/copilot-instructions.md` |
| `adapters/github/files/.github/pull_request_template.md` | `.github/pull_request_template.md` |
| `adapters/github/files/.github/ISSUE_TEMPLATE/parent-program.yml` | `.github/ISSUE_TEMPLATE/parent-program.yml` |
| `adapters/github/files/.github/ISSUE_TEMPLATE/child-change.yml` | `.github/ISSUE_TEMPLATE/child-change.yml` |

The source payload paths are package-owned adapter content. The destination
paths are GitHub-specific entry points in a consumer repository.

## v0.2 Contract Mapping

This adapter maps the v0.2 portable source and output contracts into these
GitHub entry points without duplicating those contracts as GitHub doctrine:

- Pull request template: maps the portable change-proposal body default from
  [docs/agent-context/outputs.md](../../docs/agent-context/outputs.md) into
  GitHub Markdown sections for summary, scope, changes, validation, risks,
  rollback, review notes, out-of-scope findings, and linked work. Exact local
  headings, required fields, release notes, issue-linking policy, and reviewer
  conventions belong to the project extension or a selected adapter policy.
- Parent issue form: captures parent-scope planning fields as a durable
  collaboration artifact while routing source precedence, workflow, output,
  validation, and evidence expectations to the portable contracts. It does not
  replace the workflow contract or prove current repository state.
- Child issue form: captures one bounded work item with scope, in-scope
  surfaces, out-of-scope boundaries, output expectations, validation
  requirements, and evidence pointers. It is a worker-scope entry point, not
  permission to expand beyond accepted scope or skip current evidence
  inspection.
- Copilot instructions: routes GitHub-hosted agent behavior to `AGENTS.md`, the
  portable contract index, relevant contracts including `sources.md` and
  `outputs.md`, and materialized `docs/project/**` files such as
  `docs/project/output-policy.md` when present.

The portable source-precedence rules in
[docs/agent-context/sources.md](../../docs/agent-context/sources.md) control how
agents treat issue bodies, pull request bodies, prompts, generated summaries,
adapter payloads, and current inspected state. GitHub collaboration artifacts
provide scope or review evidence; they are not proof that current files,
validation results, or repository state still match.

The portable output rules in
[docs/agent-context/outputs.md](../../docs/agent-context/outputs.md) control
agent-authored durable text output boundaries, safe structured-body handling,
validation status reporting, and change-proposal defaults. Local output policy,
when materialized, belongs in `docs/project/output-policy.md` or another
consumer-owned local extension file.

## Installation Boundary

Installation is optional and explicit. The presence of this adapter in a source
package MUST NOT install GitHub payload files by itself.

A sync or adoption process MAY install these payloads only when the GitHub
adapter is selected. Unselected adapter payloads MUST NOT create, update,
remove, or record destination files.

Installing this adapter does not materialize `docs/project/**`, does not create
sync tooling, and does not change portable core contracts. Project extension
files remain consumer-owned after creation.

## Ownership And Collision Rules

When a selected adapter creates a missing destination file and records it through
sync or an explicit adoption process, the destination file becomes an
adapter-installed managed file. It MAY be updated later only when the GitHub
adapter is selected and checksum or adoption evidence says the update is safe.

Existing unowned destination files MUST NOT be overwritten. If a consumer already
has a file at a GitHub destination path that is not recorded as adapter-managed,
the adapter install or update MUST refuse that path and preserve the existing
file. A future recovery or adoption process may define how to intentionally
adopt such a file, but this adapter does not define that process.

This adapter does not perform semantic merges. It follows the path ownership and
sync safety boundaries in
[docs/agent-context/path-ownership-and-sync-safety.md](../../docs/agent-context/path-ownership-and-sync-safety.md).

## Routing Contract

Installed GitHub entry points should route maintainers, contributors, and agents
to the current durable context in this order:

1. Read the root `AGENTS.md` entry point.
2. Read `docs/agent-context/README.md` and the relevant portable contracts.
3. For source, output, workflow, and validation decisions, read the relevant
   portable contracts, including `docs/agent-context/sources.md`,
   `docs/agent-context/outputs.md`, `docs/agent-context/workflows.md`, and
   `docs/agent-context/validation.md`.
4. Read materialized `docs/project/**` files when present for repository-local
   identity, surfaces, validation commands, workflow exceptions, and policy.
   Include `docs/project/output-policy.md` when local output policy has been
   materialized.
5. Treat missing `docs/project/**` files as missing local extension evidence,
   not as permission to invent local facts.

The GitHub files may provide GitHub-native prompts, templates, and report shapes.
They MUST NOT duplicate or replace portable-core doctrine, project-local facts,
sync implementation behavior, or future adapter rules for other tools.

## Payload Content Rules

GitHub payload files MUST remain generic. They MUST NOT include real repository
names, maintainer names, host-absolute paths, local command lines, secrets,
tokens, private identifiers, concrete issue or pull request numbers, external
URLs, or assumptions about non-GitHub tools.

When a consumer needs local facts, record them in the materialized project
extension instead of editing this adapter payload as the durable source of those
facts.
