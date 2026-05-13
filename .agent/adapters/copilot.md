# GitHub Copilot Adapter

This adapter maps portable runtime protocols to GitHub Copilot surfaces. It is
a non-authoritative mapping and does not replace the protocols.

## Mapping

- Use repository instructions and path-scoped instructions as routing surfaces
  that point to `AGENTS.md`, `.agent/**`, and relevant project-local files.
- Use Copilot agent, coding-agent, custom-instruction, prompt, or skill
  features as tool-native ways to invoke the portable protocols when available.
- Keep issue, PR, review, label, assignee, milestone, and project-field
  mechanics in project-local policy or consumer-owned platform surfaces.
- Treat generated suggestions, task progress, and platform status as evidence
  pointers until validated by current inspected state or explicit confirmation.

Concrete Copilot settings and platform behavior belong to the adapter,
consumer-owned platform surfaces, or project-local policy.
