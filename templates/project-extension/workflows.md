# Project Workflows

Use this file to record local workflow exceptions, review gates, release or
deployment notes, and routing rules for a consumer repository.

Local workflow rules extend the portable workflow contract. They MUST NOT
silently replace portable role boundaries, handoff requirements, validation
status vocabulary, or ownership rules.

Do not add project-local workflow exceptions to portable core files.

## Local Workflow Exceptions

Each exception should identify the portable boundary it extends, the local rule,
and the evidence or confirmation that supports it.

| Exception | Extends portable boundary | Local rule | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| `[exception name]` | `[role, handoff, validation, lifecycle, ownership, or other boundary]` | `[local exception or pending decision]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Review Gates

| Gate | Applies to | Required evidence | Bypass or escalation |
| --- | --- | --- | --- |
| `[review gate]` | `[paths, artifacts, risk class, or release scope]` | `[validation claim, manual review, CI evidence, or maintainer confirmation]` | `[not allowed, maintainer confirmation, pending, or omitted reason]` |

## Release And Deployment Notes

Record local release or deployment facts only when they are safe and necessary
for agents working in this repository.

| Topic | Local note | Handling boundary |
| --- | --- | --- |
| `[release or deployment topic]` | `[safe local note, unknown, pending, or omitted reason]` | `[who to ask, what not to change, or required evidence]` |

## Routing Rules

Routing rules tell agents where to send work that is outside their current
scope. They do not expand a worker's accepted scope by themselves.

| Finding or request | Route to | Required packet |
| --- | --- | --- |
| `[finding type]` | `[role, owner group, queue, or maintainer confirmation path]` | `[evidence pointer, residual risk, proposed follow-up, or omitted reason]` |

## Handoff Additions

Use this section for local fields that should be added to worker or evaluator
handoffs. Additions should make local work safer without requiring unbounded
history.

| Handoff type | Local field | Why it is needed |
| --- | --- | --- |
| `[worker or evaluator]` | `[field name]` | `[local reason and evidence expectation]` |

## Workflow Boundaries

- Local exceptions MUST name the portable rule they extend.
- Local exceptions MUST use explicit states when evidence is missing or pending.
- Local exceptions MUST NOT authorize unrelated edits outside the active work
  item.
- Maintainer confirmation MUST state the exact scope confirmed.
- Release or deployment notes MUST avoid secrets and sensitive operational
  details unless the local secrets policy allows the specific summary.
