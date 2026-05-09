# Sync Fixtures

`tests/run-sync-fixtures.sh` builds temporary consumer targets for the v0.3
`agent-context init` / `agent-context sync` lifecycle instead of storing
materialized target repositories here.

The runner covers clean `init` and `sync` dry-run and apply, lock-selected
entrypoint and collaboration-surface updates, generated v0.3 lock metadata,
default exclusion of `tools/**`, project scaffold materialization without
`docs/project/**` lock management, clean managed source-removal deletion, dirty
managed-file refusal, unowned collision refusal, malformed, unsupported,
inconsistent, and symlink lock refusal, dirty or unresolved source refusal,
channel mismatch refusal, explicit local-development metadata, collaboration
surface detach, advisory-only project scaffold drift, archive-style source
metadata, compatibility shim routing, and partial-failure rollback.
