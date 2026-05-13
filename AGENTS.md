# Agent Instructions

Start with this router, then read only the runtime protocol needed for the
active task.

## Runtime Path

1. Classify the task:
   - planning or scope design: `.agent/protocols/plan.md`;
   - delegated work or handoff: `.agent/protocols/delegate.md`;
   - isolated filesystem or branch work: `.agent/protocols/isolate.md`;
   - integration branch or PR shaping: `.agent/protocols/integrate.md`;
   - validation, review, or readiness: `.agent/protocols/verify.md`;
   - scratch handling: `.agent/protocols/scratch.md`;
   - durable memory or policy promotion: `.agent/protocols/promote-memory.md`.
2. Read any role file under `.agent/roles/**` that matches the active role.
3. Read adapter notes under `.agent/adapters/**` only when operating in that
   tool surface.
4. Read reference contracts from `docs/agent-context/README.md` when a runtime
   protocol points to them or when the task affects durable contract,
   validation, evidence, output, workflow, or installer boundaries.
5. If a consumer-owned local extension exists under `docs/project/**`, read the
   relevant local files after the portable runtime and reference contracts.

Keep portable contract files free of repository identity, host details, personal
identifiers, secrets, vendor-specific baseline assumptions, and local operational
facts. Put those details in the project extension instead.

## Durable Boundary

Use collaboration artifacts, readiness reports, validation reports, issue or PR
records, and `docs/project/**` for durable scope or local policy. Treat scratch,
conversation history, raw worker notes, and old tool output as non-authoritative
until promoted through `.agent/protocols/promote-memory.md`.
