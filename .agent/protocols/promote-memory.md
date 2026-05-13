# Memory Promotion Protocol

Use this protocol when an observation, decision, validation result, or repeated
pattern should become durable scope, evidence, policy, or documentation.

## Promotion Gate

Before promotion, confirm:

- the claim being promoted and its owning layer;
- current inspected evidence or exact maintainer confirmation;
- freshness and limitations;
- whether the claim is scope, factual state, local policy, validation evidence,
  review evidence, or reference documentation;
- the durable destination and intended consumer.

## Destinations

Promote to:

- parent or child issue when the claim governs scope or follow-up work;
- PR body, review comment, readiness report, or validation report when the
  claim supports review of a specific change;
- `docs/project/**` when the consumer repository owns local identity, commands,
  policy, workflow exceptions, source maps, or sensitive-surface rules;
- `docs/agent-context/**` only when the claim is reusable portable doctrine;
- runtime protocol files under `.agent/**` only when the claim changes
  source-owned portable execution behavior.

## Prohibited Promotion

Do not promote broad transcripts, raw worker notes, old tool output, repeated
examples, or validation success into durable policy without evidence and
authority for the exact claim.
