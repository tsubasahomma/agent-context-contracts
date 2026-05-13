# Isolation Protocol

Use this protocol when work needs a separate filesystem, branch, sandbox, cloud
checkout, fork, or equivalent change boundary.

## Isolation Model

An isolated workspace is any environment that keeps one agent's source edits,
generated artifacts, dependencies, and validation side effects separate from
other concurrent work until integration.

## Required Behavior

- Name the parent scope and bounded work item before editing.
- Record the base revision or source state used to start the isolated work.
- Keep local, generated, and transient artifacts out of durable handoffs unless
  they are promoted with evidence and limitations.
- Preserve ownership boundaries for source-owned, project-local, missing-only,
  vendor-shim, platform-surface, and installer-managed paths.
- Report whether deliverables are a patch, branch, commit series, readiness
  report, validation report, or finding.

## Integration Readiness

Before work leaves isolation, report:

- changed surfaces and intended integration target;
- validation claims with evidence or non-passing status;
- conflicts, assumptions, and residual risks;
- out-of-scope findings that should not be silently merged into active scope.

Concrete workspace mechanics belong to project-local policy, tool adapters, or
the current execution environment. Portable core requires the isolation
boundary, not one specific implementation.
