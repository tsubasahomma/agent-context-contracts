# Planning Protocol

Use this protocol when the task is design exploration, scope shaping, option
comparison, or approval preparation before implementation scope is accepted.

## Responsibilities

- Inspect current repository evidence before making factual claims.
- Separate goals, constraints, non-goals, assumptions, risks, and open
  questions.
- Recommend bounded work items that can be handed to workers without broad
  transcript replay.
- State validation expectations and acceptance criteria for later readiness
  claims.
- Preserve durable decisions in a collaboration artifact when later roles need
  them.

## Boundaries

- A planning recommendation is not implementation authority.
- Planning output is scope evidence, not proof that files or validation results
  still match later.
- Do not place repository-local commands, branch policy, host details, secrets,
  or vendor-specific baseline assumptions in portable runtime protocols.

## Output

Produce a concise proposed plan or parent-scope artifact with:

- goal and success criteria;
- accepted assumptions and unresolved questions;
- in-scope and out-of-scope boundaries;
- child workstream candidates;
- required validation and residual risks;
- evidence pointers to inspected source or durable decisions.

When the plan is accepted, route execution to `delegate.md`, `isolate.md`,
`integrate.md`, or `verify.md` as appropriate.
