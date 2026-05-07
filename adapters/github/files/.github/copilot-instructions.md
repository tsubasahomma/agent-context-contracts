# GitHub Copilot Instructions

This file is an optional GitHub adapter entry point. It does not replace the
durable operating contracts.

Before making or reviewing changes, use this routing order:

1. Start with the root `AGENTS.md`.
2. Read `docs/agent-context/README.md` and the relevant portable contracts.
3. If `docs/project/**` exists, read the relevant local extension files for
   repository-local identity, surfaces, validation commands, workflow
   exceptions, and policy.
4. If `docs/project/**` is absent or incomplete, report the missing local
   evidence instead of inventing local facts.

Keep work bounded to the accepted task. Re-inspect current repository evidence
before editing, treat handoff text as scope evidence rather than proof of current
state, and report out-of-scope findings without silently expanding the task.

Use the validation status vocabulary from `docs/agent-context/validation.md` in
readiness reports: `passed`, `failed`, `pending`, `skipped`, `not_required`, and
`maintainer_confirmed`. Do not claim validation passed without evidence.

Do not put repository identity, maintainer names, host paths, local commands,
secrets, tokens, private identifiers, or durable portable-core rules in this
file. Local facts belong in the project extension.
