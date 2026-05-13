# Claude Adapter

This adapter maps portable runtime protocols to Claude Code surfaces. It is a
non-authoritative mapping and does not replace the protocols.

## Mapping

- Use plan-oriented permission modes for `protocols/plan.md` when scope is not
  accepted.
- Use Claude Code subagents or equivalent bounded sessions for delegated
  explorer, worker, evaluator, or integrator roles when available.
- Use separate worktrees, branches, or sandboxed checkouts for
  `protocols/isolate.md` when implementation or evaluation should not share a
  mutable workspace.
- Keep project-level Claude configuration as a vendor-owned mapping surface; it
  must route back to `AGENTS.md`, `.agent/**`, and relevant project-local files.

Concrete Claude commands, settings, and file locations belong to the adapter or
project-local policy, not to portable runtime protocols.
