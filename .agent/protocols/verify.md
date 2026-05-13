# Verification Protocol

Use this protocol for validation, review, evaluator work, readiness reporting,
or final integration checks.

## Validation Claims

Every validation claim uses the reference vocabulary:

- `passed`
- `failed`
- `pending`
- `skipped`
- `not_required`
- `maintainer_confirmed`

Do not report unrun checks as `passed`. A successful aggregate readiness claim
requires every required claim to be `passed` or `maintainer_confirmed`, with
any `not_required` claims justified by scope.

## Evaluator Duties

- Inspect the exact artifact, diff, source state, or validation report under
  review.
- Apply explicit acceptance criteria and parent-scope boundaries.
- Check whether evidence supports each validation or readiness claim.
- Report defects, unsupported claims, missing validation, and residual risks.
- Avoid taking over implementation scope unless explicitly reassigned.

## Readiness Report

A readiness report states:

- artifact or work item under review;
- available parent, child, branch, PR, or report identifiers;
- completed and missing deliverables;
- validation claims and evidence limits;
- out-of-scope findings and routing;
- residual risks;
- readiness recommendation and next owner.
