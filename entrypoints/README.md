# Entrypoints

Entrypoints are source-owned optional routing payloads. They help a selected
tool or hosted agent find the root `AGENTS.md` entry point, the portable
contract index under `docs/agent-context/**`, and consumer-owned project
extension files under `docs/project/**` when those files exist.

Entrypoints are thin shims. They are not the durable source of portable
doctrine, repository-local facts, validation proof, or sync behavior.

## Active Entrypoint Groups

| Group | Source payload | Intended destination |
| --- | --- | --- |
| `claude` | `entrypoints/claude/CLAUDE.md` | `CLAUDE.md` |
| `codex` | `entrypoints/codex/config.example.toml` | `.codex/config.example.toml` |
| `gemini` | `entrypoints/gemini/GEMINI.md` | `GEMINI.md` |
| `github-copilot` | `entrypoints/github-copilot/copilot-instructions.md` | `.github/copilot-instructions.md` |

The presence of an entrypoint group in the source package does not install it.
Selection and lock metadata decide whether a destination file is
package-managed in a consumer repository.

## Legacy Source Mapping

The v0.3 taxonomy splits the earlier adapter layout into ownership classes:

| Earlier source path | v0.3 source path |
| --- | --- |
| `adapters/claude/files/CLAUDE.md` | `entrypoints/claude/CLAUDE.md` |
| `adapters/codex/files/.codex/config.example.toml` | `entrypoints/codex/config.example.toml` |
| `adapters/gemini/files/GEMINI.md` | `entrypoints/gemini/GEMINI.md` |
| `adapters/github/files/.github/copilot-instructions.md` | `entrypoints/github-copilot/copilot-instructions.md` |

GitHub pull request and issue form payloads moved to `surfaces/github/**`
because they are collaboration surfaces rather than thin routing entrypoints.

## Repomix Classification

The earlier Repomix payload is intentionally not represented as an active v0.3
entrypoint, collaboration surface, or project scaffold in this child. Its
content was evidence-packing workflow guidance for one tool, not a thin routing
file or platform-native collaboration form. Placing that guidance in portable
core would make tool-specific evidence-packing behavior look like reusable
doctrine.

A later selected evidence-tool layer can reintroduce Repomix-oriented content
with an explicit ownership class, destination mapping, lock behavior, and
validation boundary.
