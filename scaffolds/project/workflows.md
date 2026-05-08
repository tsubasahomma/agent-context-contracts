# Project Workflows

Use this file to record local workflow exceptions, branch policy, review gates,
release or deployment notes, rollback routing, and handoff rules for a consumer
repository.

Local workflow rules extend the portable workflow contract. They MUST NOT
silently replace portable role boundaries, handoff requirements, validation
status vocabulary, or ownership rules.

Do not add project-local workflow exceptions to portable core files.

Local durable output body requirements belong in `output-policy.md`. This file
records when those outputs are required by workflow, who reviews them, and how
out-of-scope workflow findings are routed.

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

## Branch And Change Routing

Record local branching or change-routing policy only as consumer-owned facts.
Do not infer a branch naming convention from historical examples, issue text, or
selected entrypoint or surface defaults.

| Policy area | Applies to | Local rule | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| Branch naming | `[work type, role, release scope, or omitted reason]` | `[local naming rule, pending decision, omitted reason, or maintainer confirmation]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Change ownership | `[paths, artifacts, generated outputs, or workflow stage]` | `[who may create, update, review, or route the change]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Scope escalation | `[finding, request, blocked validation, or review gate]` | `[route to maintainer, planner, orchestrator, selected surface, queue, or omitted reason]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Release And Deployment Notes

Record local release or deployment facts only when they are safe and necessary
for agents working in this repository.

| Topic | Local note | Handling boundary | Output expectation |
| --- | --- | --- | --- |
| `[release or deployment topic]` | `[safe local note, unknown, pending, or omitted reason]` | `[who to ask, what not to change, or required evidence]` | `[release note, rollback note, readiness note, pending, not_required, or omitted reason]` |

## Rollback And Recovery Routing

Use this section for local rollback, recovery, or mitigation routing that affects
workflow readiness. Keep sensitive operational details in the local secrets
policy or another approved consumer-owned location.

| Situation | Required routing | Required evidence | Output boundary |
| --- | --- | --- | --- |
| `[rollback, recovery, deployment failure, or readiness blocker]` | `[role, maintainer path, incident path, pending decision, or omitted reason]` | `[validation claim, inspected state, confirmation, or limitation]` | `[what the worker may report, must not perform, or must escalate]` |

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

| Handoff type | Local field | Why it is needed | Status |
| --- | --- | --- | --- |
| `[worker, evaluator, release, rollback, or readiness]` | `[field name]` | `[local reason and evidence expectation]` | `[unknown, pending, omitted, or maintainer_confirmed]` |

## Workflow Boundaries

- Local exceptions MUST name the portable rule they extend.
- Local exceptions MUST use explicit states when evidence is missing or pending.
- Local exceptions MUST NOT authorize unrelated edits outside the active work
  item.
- Maintainer confirmation MUST state the exact scope confirmed.
- Branch naming, routing, and review gates MUST be recorded as local facts, not
  inferred from examples.
- Release or deployment notes MUST avoid secrets and sensitive operational
  details unless the local secrets policy allows the specific summary.
- Durable output formatting, issue-reference policy, trailers, closure keywords,
  and merge-message policy belong in `output-policy.md` or a selected-surface
  mapping.
