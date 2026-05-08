# Surfaces

Surfaces are source-owned optional collaboration payloads. They map portable
workflow, output, validation, and source-boundary expectations into a
platform-native form such as a pull request template or issue form.

Surfaces can remain package-managed by the source package when they are selected
and lock-recorded. A consumer that wants local workflow rules in a surface needs
an explicit detach or local ownership workflow before editing that destination
as consumer-owned content.

## Active Surface Groups

| Group | Source payload | Intended destination |
| --- | --- | --- |
| `github` | `surfaces/github/pull_request_template.md` | `.github/pull_request_template.md` |
| `github` | `surfaces/github/ISSUE_TEMPLATE/parent-program.yml` | `.github/ISSUE_TEMPLATE/parent-program.yml` |
| `github` | `surfaces/github/ISSUE_TEMPLATE/child-change.yml` | `.github/ISSUE_TEMPLATE/child-change.yml` |

The GitHub Copilot repository instruction payload is not part of this surface
group. It lives under `entrypoints/github-copilot/**` because its job is thin
routing rather than proposal, planning, or validation presentation.

## Legacy Source Mapping

| Earlier source path | v0.3 source path |
| --- | --- |
| `adapters/github/files/.github/pull_request_template.md` | `surfaces/github/pull_request_template.md` |
| `adapters/github/files/.github/ISSUE_TEMPLATE/parent-program.yml` | `surfaces/github/ISSUE_TEMPLATE/parent-program.yml` |
| `adapters/github/files/.github/ISSUE_TEMPLATE/child-change.yml` | `surfaces/github/ISSUE_TEMPLATE/child-change.yml` |
