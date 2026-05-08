# Sync Fixtures

`tests/run-sync-fixtures.sh` builds temporary consumer targets for the v0.1
sync behavior instead of storing materialized target repositories here.

The runner covers clean dry-run and apply, checksum-safe update, checksum
refusal, unowned collision refusal, selected and unselected optional payload
behavior through the transitional adapter flag, parent path collision refusal,
project extension seeding and preservation,
project extension path overlap refusal, malformed, unsupported, inconsistent,
or symlink lock refusal, source-removal preservation, preserved managed checksum
refusal, and partial-failure rollback.
