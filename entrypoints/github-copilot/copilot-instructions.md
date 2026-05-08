# GitHub Copilot Instructions

This file is an optional GitHub Copilot entry point. It does not replace the
durable operating contracts.

Before making or reviewing changes, use this routing order:

1. Start with the root `AGENTS.md`.
2. Read `docs/agent-context/README.md` and the relevant portable contracts.
   For source, output, workflow, and validation decisions, include
   `docs/agent-context/sources.md`, `docs/agent-context/outputs.md`,
   `docs/agent-context/workflows.md`, and
   `docs/agent-context/validation.md`.
3. If `docs/project/**` exists, read the relevant local extension files for
   repository-local identity, surfaces, validation commands, workflow
   exceptions, and policy. Include `docs/project/output-policy.md` when it is
   present.
4. If `docs/project/**` is absent or incomplete, report the missing local
   evidence instead of inventing local facts.

Keep work bounded to the accepted task. Re-inspect current repository evidence
before editing, treat handoff text as scope evidence rather than proof of current
state, and report out-of-scope findings without silently expanding the task.

For durable text outputs such as issue bodies, pull request bodies, change
summaries, validation reports, readiness reports, prompts, review findings,
commit or change messages, and command bodies, follow
`docs/agent-context/outputs.md` and any materialized project output policy. Do
not manually mirror dynamic review, CI, deployment, or external status as
always-current durable body text.

Use the validation status vocabulary from `docs/agent-context/validation.md` in
readiness reports: `passed`, `failed`, `pending`, `skipped`, `not_required`, and
`maintainer_confirmed`. Do not claim validation passed without evidence.

Do not put repository identity, maintainer names, host paths, local commands,
secrets, tokens, private identifiers, or durable portable-core rules in this
file. Local facts belong in the project extension.
