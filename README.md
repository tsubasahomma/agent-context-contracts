# Agent Context Contracts

This repository provides portable, reviewable agent-context files that can be
installed into a consumer repository with one command:

```sh
curl -fsSL https://raw.githubusercontent.com/tsubasahomma/agent-context-contracts/main/install.sh | sh
```

Run the command from the consumer repository root. The same command handles
first-time adoption and later refreshes.

## What Gets Installed

The installer resolves the configured source channel, defaulting to `main`, to a
full commit SHA. It then downloads one GitHub archive for that resolved commit
and copies files from that archive.

| Source path | Destination path | Behavior |
| --- | --- | --- |
| `AGENTS.md` | `AGENTS.md` | Overwritten on every run. |
| `docs/agent-context/**` | `docs/agent-context/**` | Replaced from the resolved source commit on every run. |
| `payload/missing-only/**` | Matching destination paths | Created only when the destination file is absent. |

The portable contracts live in `AGENTS.md` and `docs/agent-context/**`. Consumer
repositories should keep repository identity, commands, local policy, workflow
exceptions, validation details, and sensitive-surface notes under
`docs/project/**`.

## Missing-Only Payload

`payload/missing-only/**` mirrors consumer repository destination paths. It is
starter content, not active context for this source repository.

Missing-only means file-level creation only:

- if the destination file is absent, the installer creates it;
- if the destination file already exists, the installer preserves it;
- the installer never overwrites, patches, deletes, renames, diff-applies,
  merges, or tracks previous content for missing-only files.

The missing-only tree may seed local project starter files under
`docs/project/**` and thin vendor routing shims at:

- `CLAUDE.md`;
- `GEMINI.md`;
- `.github/copilot-instructions.md`.

Vendor shims route agents to `AGENTS.md`, `docs/agent-context/README.md`, and
relevant `docs/project/**` files. Existing vendor instruction files in a
consumer repository are always preserved.

## What This Does Not Manage

This repository does not install a local package manager lifecycle. There are no
public `init` or `sync` subcommands, and the installer does not create
`agent-context.lock.json` or an equivalent consumer-side state file.

The simplified default installer also does not install platform collaboration
surfaces such as:

- `.github/ISSUE_TEMPLATE/**`;
- `.github/pull_request_template.md`;
- `.gemini/config.yaml`;
- `.gemini/styleguide.md`.

Those files often encode local review behavior, platform workflow, or
repository-specific policy. Keep them under consumer control unless a separate
local workflow intentionally manages them.

## Configuration

The default source is this repository on the `main` channel. Optional settings:

```sh
curl -fsSL https://raw.githubusercontent.com/tsubasahomma/agent-context-contracts/main/install.sh |
  AGENT_CONTEXT_CHANNEL=v1.0.0 sh
```

```sh
curl -fsSL https://raw.githubusercontent.com/tsubasahomma/agent-context-contracts/main/install.sh |
  AGENT_CONTEXT_REPO=owner/repo AGENT_CONTEXT_CHANNEL=main sh
```

For private repositories or higher GitHub API limits, set `GITHUB_TOKEN` in the
environment. The installer uses the token for both the commit-resolution API
request and the resolved archive download.

Use `--dry-run` for diagnostics:

```sh
sh install.sh --dry-run
```

## Contract Index

Start with [docs/agent-context/README.md](docs/agent-context/README.md) for the
portable contract set. Ownership and installer behavior are defined in
[docs/agent-context/ownership.md](docs/agent-context/ownership.md).
