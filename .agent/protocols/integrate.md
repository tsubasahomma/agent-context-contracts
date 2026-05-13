# Integration Protocol

Use this protocol when combining related worker outputs into an integration
branch, coherent PR, stacked PRs, or another final review surface.

## Integration Branch

An integration branch collects related worker outputs under one parent scope
before final review. It is not the same as a worker branch, and it does not
require every worker to publish a PR.

## Integrator Duties

- Confirm the parent scope and accepted child work items.
- Inspect each worker deliverable and readiness report before importing it.
- Resolve conflicts against current source state and portable boundaries.
- Keep worker unit, branch unit, commit unit, and PR unit explicit.
- Route unrelated findings into later work instead of absorbing them silently.
- Run whole-change validation before final readiness claims.

## PR Granularity

Use one coherent PR when the runtime protocols, installer behavior, ownership
docs, and validation fixtures must change atomically. Use stacked PRs only when
reviewability improves without leaving an intermediate branch that violates
installer or ownership boundaries.

## Final Review Surface

The final review surface should include:

- parent and child artifact identifiers when available;
- summary of integrated changes;
- validation claims with status and evidence;
- residual risks and skipped or pending checks;
- out-of-scope findings and follow-up routing.
