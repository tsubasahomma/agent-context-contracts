# Codex Adapter

This adapter maps portable runtime protocols to Codex surfaces. It is a
non-authoritative mapping and does not replace the protocols.

## Mapping

- Use the primary thread for current task framing, final response, and
  integration decisions.
- Use planning mode or read-only exploration for `protocols/plan.md` when
  implementation scope is not accepted.
- Use delegated agents, background tasks, or separate cloud/local workspaces for
  `protocols/delegate.md` and `protocols/isolate.md` when available in the
  active Codex surface.
- Use a branch or isolated workspace as the integration target when applying
  `protocols/integrate.md`.
- Use explicit validation reports and readiness summaries for
  `protocols/verify.md`.

Codex-specific availability, permissions, network policy, sandbox behavior, and
publication mechanics belong to the current execution environment or local
project policy.
