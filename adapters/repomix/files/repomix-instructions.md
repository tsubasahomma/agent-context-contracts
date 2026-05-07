# Repomix Adapter Routing

This file is an optional Repomix-oriented adapter payload. It does not replace
the durable operating contracts, and it is not itself an evidence pack.

Use this routing order before preparing, reviewing, or relying on packed
evidence:

1. Start with the root `AGENTS.md`.
2. Read `docs/agent-context/README.md` and the relevant portable contracts.
3. For evidence packing, follow `docs/agent-context/evidence-packing.md`.
4. For artifact metadata and validation claims, follow
   `docs/agent-context/artifacts.md` and `docs/agent-context/validation.md`.
5. For worker or evaluator handoffs, follow
   `docs/agent-context/workflows.md`.
6. If `docs/project/**` exists, read the relevant local extension files for
   repository-local identity, surfaces, validation commands, workflow
   exceptions, secrets policy, and sensitive-data boundaries.
7. If `docs/project/**` is absent or incomplete, report the missing local
   evidence instead of inventing local facts.

Packed evidence should stay bounded to the active subject and intended consumer.
It should identify subject, producer, intended consumer, source references,
included and omitted surfaces, observation point, freshness, redaction notes,
limitations, and any generated or tool-produced evidence.

Treat packed evidence as supporting evidence, not automatic proof of current
source state. Re-inspect current repository evidence when the workflow contract,
validation claim, or review question requires current state.

Preserve local secrets policy and sensitive-surface boundaries. Do not include
actual secrets, tokens, credentials, private keys, private personal data,
unredacted sensitive output, host-absolute paths, or private identifiers in
packed evidence. Redact, summarize, omit, or request maintainer confirmation
when safe review requires it.

Use the validation status vocabulary from
`docs/agent-context/validation.md`: `passed`, `failed`, `pending`, `skipped`,
`not_required`, and `maintainer_confirmed`. Do not claim validation passed
because a pack exists.

This payload does not define command syntax, generated output format,
configuration files, token budgets, source selection logic, or redaction
implementation. Local workflow facts belong in the project extension.
