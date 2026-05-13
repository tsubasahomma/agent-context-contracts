# Gemini Adapter

This adapter maps portable runtime protocols to Gemini coding surfaces. It is a
non-authoritative mapping and does not replace the protocols.

## Mapping

- Use Gemini project context files as routing shims that point to `AGENTS.md`,
  `.agent/**`, and relevant project-local files.
- Use Gemini agent or subagent features for bounded delegated roles when the
  active Gemini surface supports them.
- Use custom commands or prompt-library entries only as tool-native shortcuts;
  they must not become portable doctrine.
- Use isolated workspaces, branches, or cloud checkouts for implementation or
  evaluation work that should not share mutable state.

Concrete Gemini command syntax, extension configuration, and tool availability
belong to the adapter, vendor surface, or project-local policy.
