# Runtime Protocol Index

This directory contains source-owned portable runtime protocols. It is the
short operational layer agents read before consulting the reference contracts in
`docs/agent-context/**`.

Runtime protocols are task-selective. They tell an agent what to do for the
current role without making every task consume the full reference contract set.
The reference contracts remain authoritative for durable boundaries,
validation vocabulary, evidence rules, ownership, and installer safety.

## Protocols

| Task | Read |
| --- | --- |
| Planning before accepted implementation scope | `protocols/plan.md` |
| Delegating or receiving bounded work | `protocols/delegate.md` |
| Working in a separate filesystem, branch, sandbox, or cloud checkout | `protocols/isolate.md` |
| Combining worker outputs into an integration branch or final review surface | `protocols/integrate.md` |
| Reviewing, evaluating, validating, or reporting readiness | `protocols/verify.md` |
| Handling transient notes, tool output, or temporary observations | `protocols/scratch.md` |
| Promoting observations into durable policy, scope, or evidence | `protocols/promote-memory.md` |

## Roles

Role files under `roles/**` describe bounded responsibilities for explorers,
workers, evaluators, and integrators. They do not replace the workflow
reference contract; they are concise runtime entry points for those roles.

## Adapters

Adapter files under `adapters/**` map these portable protocols into
tool-native surfaces. Adapters are non-authoritative mappings. If an adapter and
a portable protocol appear to conflict, preserve the portable boundary and route
the conflict through the relevant reference contract or project-local policy.
