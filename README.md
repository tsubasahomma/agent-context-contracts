# Agent Context Contracts

This repository is a portable agent-context contract package. It is not only a
documentation repository and it is not a one-off template. It provides reusable
contract files, optional routing entrypoints, optional collaboration surfaces,
project-local scaffolds, and source-package tooling for adopting and updating
those files in consumer repositories.

Durable portable contracts live under
[`docs/agent-context/**`](docs/agent-context/README.md) so agent instructions can
stay small while still routing agents to reviewable, versioned doctrine. The
root [`AGENTS.md`](AGENTS.md) is the portable root entrypoint. Local consumer
facts, commands, exceptions, and policy details belong under `docs/project/**`
after a consumer repository materializes or writes them.

For the durable contract body, start with the
[`docs/agent-context` index](docs/agent-context/README.md). For lifecycle and
ownership rules, see
[`path-ownership-and-sync-safety.md`](docs/agent-context/path-ownership-and-sync-safety.md).

## Quick Start

Run these commands from the consumer repository root. The tool is run from a
temporary source-package directory and is not installed into the consumer
repository as managed payload. The shell snippets below use Bash-compatible
syntax.

Use a commit-addressed archive and pass the same resolved commit to the tool so
`agent-context.lock.json` can record both the mutable source channel and the
immutable source revision:

```sh
repo="tsubasahomma/agent-context-contracts"
channel="main"
workdir="$(mktemp -d)"
source="${workdir}/agent-context-contracts"
mkdir -p "${source}"
curl_auth=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  curl_auth=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

commit="$(
  curl -fsSL "${curl_auth[@]}" "https://api.github.com/repos/${repo}/commits/${channel}" |
    python3 -c 'import json, sys; print(json.load(sys.stdin)["sha"])'
)"

curl -fsSL "${curl_auth[@]}" "https://codeload.github.com/${repo}/tar.gz/${commit}" |
  tar -xz --strip-components=1 -C "${source}"
```

Preview initial adoption:

```sh
bash "${source}/tools/agent-context.sh" init \
  --source "${source}" \
  --target . \
  --repository "${repo}" \
  --channel "${channel}" \
  --resolved-commit "${commit}" \
  --entrypoint claude \
  --surface github \
  --materialize-project
```

Apply the same adoption plan:

```sh
bash "${source}/tools/agent-context.sh" init \
  --source "${source}" \
  --target . \
  --repository "${repo}" \
  --channel "${channel}" \
  --resolved-commit "${commit}" \
  --entrypoint claude \
  --surface github \
  --materialize-project \
  --apply
```

Dry-run is the default. Writes require `--apply`.

Do not use `curl .../tools/agent-context.sh | bash` for this package layout. The
shell entrypoint expects the neighboring Python CLI and source package content.

## Update Flow

To update a repository that already has `agent-context.lock.json`, fetch a fresh
source package revision with the same archive pattern and run `sync`:

```sh
bash "${source}/tools/agent-context.sh" sync \
  --source "${source}" \
  --target . \
  --repository "${repo}" \
  --channel "${channel}" \
  --resolved-commit "${commit}"
```

Apply with `--apply` after reviewing the dry-run output.

Normal `sync` uses the entrypoints and collaboration surfaces already recorded
in `agent-context.lock.json`; it does not require selecting them again. If the
lock selected the `claude` entrypoint and the `github` surface during `init`,
plain `sync` updates those managed files when checksum-safe.

If you already have a clean local checkout of this source package, you may run
the same commands with `--source <source-checkout>`. In that case the tool can
resolve the source channel from git and `--resolved-commit` is optional.

## Optional Content

Selected entrypoints install thin routing files from
[`entrypoints/**`](entrypoints/README.md). Examples:

```sh
--entrypoint claude
--entrypoint github-copilot
```

Selected collaboration surfaces install platform-native work surfaces from
[`surfaces/**`](surfaces/README.md). Example:

```sh
--surface github
```

Project-local starter files come from
[`scaffolds/project/**`](scaffolds/project/README.md) only when requested:

```sh
--materialize-project
```

Materialized `docs/project/**` files become consumer-owned after creation. Later
`sync` may report scaffold drift as advisory output, but it does not overwrite,
delete, patch, merge, or lock-manage project files.

## Surface Detach

Collaboration surfaces remain package-managed until explicitly detached. To
preview detaching the GitHub surface:

```sh
bash "${source}/tools/agent-context.sh" sync \
  --source "${source}" \
  --target . \
  --repository "${repo}" \
  --channel "${channel}" \
  --resolved-commit "${commit}" \
  --detach-surface github
```

Apply the detach with `--apply`. Detach preserves destination files and removes
the detached surface files from `managed_files[]`; later plain `sync --apply`
does not reattach, overwrite, update, or delete them.

## Ownership Model

| Class | Paths | Ownership |
| --- | --- | --- |
| Portable core | `AGENTS.md`, `docs/agent-context/**` | Package-managed. |
| Optional entrypoints | Selected files from `entrypoints/**` | Package-managed only when selected and lock-recorded. |
| Optional collaboration surfaces | Selected files from `surfaces/**` | Package-managed until explicitly detached. |
| Sync metadata | `agent-context.lock.json` | Sync-tool-managed root metadata. |
| Project extension | `docs/project/**` | Consumer-owned after materialization or creation. |
| Source-package tooling | `tools/**` | Source-package tooling, not default consumer payload. |

The lock records selected entrypoints, selected surfaces, managed files,
checksums, source repository, source channel, and resolved commit SHA.

## Safety Summary

`init` performs initial adoption. `sync` updates package-managed content from
the source package single source of truth.

At a high level, the tool refuses unsafe writes for dirty managed files, unowned
destination collisions, malformed or unsupported locks, symlinked or
inconsistent locks, dirty source checkouts, unresolved source revisions, and
requested source channels that do not match the bytes being applied.

When a package-managed file is clean in the consumer repository and no longer
exists in the resolved source package, dry-run reports the deletion and
`sync --apply` deletes it. This clean managed deletion rule does not apply to
consumer-owned `docs/project/**` files or detached surfaces.

For detailed normative behavior, use the
[`path ownership and sync safety contract`](docs/agent-context/path-ownership-and-sync-safety.md)
instead of treating this README as the contract body.
