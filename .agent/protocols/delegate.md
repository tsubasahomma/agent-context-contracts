# Delegation Protocol

Use this protocol when an orchestrator prepares handoffs or when a delegated
agent receives bounded work.

## Orchestrator Duties

- Keep the parent scope, child work item, and current role explicit.
- Send only the context needed for the delegated role.
- Allocate an isolated workspace when the recipient may edit, run risky checks,
  or evaluate independently.
- Preserve accepted scope, out-of-scope boundaries, validation expectations,
  deliverables, and known risks.
- Treat worker, branch, and PR units as separate decisions.

## Required Worker Handoff Content

A bounded worker handoff includes:

- active work item and parent scope;
- accepted scope and out-of-scope boundaries;
- in-scope paths, surfaces, or artifacts;
- current evidence pointers;
- required validation and expected status vocabulary;
- known risks and blocked assumptions;
- deliverables and readiness report expectations.

## Recipient Duties

- Re-inspect current evidence before editing, reviewing, or claiming
  validation.
- Treat handoff text as scope evidence, not proof of current repository state.
- Report stale, missing, contradictory, or overbroad handoff evidence before
  expanding scope.
- Return a bounded finding, patch, branch, validation result, or readiness
  report without dumping raw transcripts.

Use `roles/explorer.md`, `roles/worker.md`, `roles/evaluator.md`, or
`roles/integrator.md` for role-specific expectations.
