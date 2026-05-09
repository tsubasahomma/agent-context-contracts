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

## Lifecycle Gate Decisions

Use this section to record local owners and evidence expectations for lifecycle
gates. If a gate owner or delegation is not confirmed, record the state as
`unknown` or `pending` and require maintainer confirmation before irreversible
action.

| Gate | Applies to | Local owner or delegation | Required evidence | Status | Evidence pointer |
| --- | --- | --- | --- | --- | --- |
| Accepted implementation scope | `[work item type, parent scope, risk class, or pending decision]` | `[orchestrator, maintainer, platform surface, project extension, pending, or omitted reason]` | `[accepted work item, handoff, maintainer confirmation, or limitation]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Worker self-review and readiness | `[work item type, artifact, source change, or pending decision]` | `[worker role, readiness reviewer, platform surface, pending, or omitted reason]` | `[self-review note, validation report, readiness report, or limitation]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Independent evaluation or review | `[risk class, path set, artifact type, release scope, or not_required reason]` | `[evaluator role, reviewer group, maintainer, platform surface, pending, or omitted reason]` | `[evaluation report, review finding, validation evidence, maintainer confirmation, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Change proposal or review surface creation | `[work item type, platform surface, source change, or not_required reason]` | `[worker, orchestrator, maintainer, platform surface, pending, or omitted reason]` | `[readiness report, proposal body, linked work item, or limitation]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Final acceptance, merge, release, issue closure, or destructive cleanup | `[release scope, source change, platform item, cleanup action, or not_required reason]` | `[maintainer, owning process, delegated role, platform surface, pending, or omitted reason]` | `[acceptance decision, validation evidence, maintainer confirmation, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Progress-state mapping | `[checkboxes, tasklists, project fields, labels, status columns, or omitted reason]` | `[platform surface, project extension, maintainer, pending, or omitted reason]` | `[routing evidence only, validation claim reference, or limitation]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Work Item And Progress-State Mutation Authority

Record who may update durable work-item bodies and progress surfaces after
creation. These slots do not make progress state validation evidence; they only
record local authority for mutation and routing.

| Mutation area | Applies to | Authorized local owner | Required evidence or confirmation | Status | Evidence pointer |
| --- | --- | --- | --- | --- | --- |
| Parent work-item body edits | `[parent scope type, platform surface, or not_required reason]` | `[maintainer, orchestrator, platform owner, pending, or omitted reason]` | `[local policy, maintainer confirmation, platform-surface rule, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Child work-item body edits | `[work item type, platform surface, or not_required reason]` | `[maintainer, orchestrator, worker, platform owner, pending, or omitted reason]` | `[local policy, maintainer confirmation, platform-surface rule, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Acceptance-criteria or checklist mutation | `[work item type, checkbox, tasklist, linked item, sub-item, or not_required reason]` | `[maintainer, orchestrator, platform owner, pending, or omitted reason]` | `[routing evidence, validation claim reference, maintainer confirmation, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Project status or field mutation | `[status column, project field, platform surface, or not_required reason]` | `[maintainer, orchestrator, project owner, platform owner, pending, or omitted reason]` | `[local policy, platform-surface rule, maintainer confirmation, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Review Gates

| Gate | Applies to | Required evidence | Bypass or escalation |
| --- | --- | --- | --- |
| `[review gate]` | `[paths, artifacts, risk class, or release scope]` | `[validation claim, manual review, CI evidence, or maintainer confirmation]` | `[not allowed, maintainer confirmation, pending, or omitted reason]` |

## Branch And Change Routing

Record local branching or change-routing policy only as consumer-owned facts.
Do not infer a branch naming convention from historical examples, issue text,
vendor shims, or platform surface defaults.

| Policy area | Applies to | Local rule | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| Branch naming | `[work type, role, release scope, or omitted reason]` | `[local naming rule, pending decision, omitted reason, or maintainer confirmation]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Change ownership | `[paths, artifacts, generated outputs, or workflow stage]` | `[who may create, update, review, or route the change]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Scope escalation | `[finding, request, blocked validation, or review gate]` | `[route to maintainer, planner, orchestrator, platform surface, queue, or omitted reason]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Platform Surface Mutation Authority

Record local authority for mutating platform-surface routing state. These slots
do not create a taxonomy or require any platform surface. If a surface is absent
or outside local workflow scope, record `not_required` or an omitted reason.

| Mutation area | Applies to | Authorized local owner | Required evidence or confirmation | Status | Evidence pointer |
| --- | --- | --- | --- | --- | --- |
| Label mutation | `[work item type, platform surface, risk class, or not_required reason]` | `[maintainer, orchestrator, worker, platform owner, pending, or omitted reason]` | `[local policy, maintainer confirmation, platform-surface rule, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Assignee mutation | `[work item type, platform surface, ownership area, or not_required reason]` | `[maintainer, orchestrator, worker, platform owner, pending, or omitted reason]` | `[local policy, maintainer confirmation, platform-surface rule, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Reviewer request mutation | `[change proposal, review surface, risk class, or not_required reason]` | `[maintainer, orchestrator, worker, platform owner, pending, or omitted reason]` | `[local policy, maintainer confirmation, platform-surface rule, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Milestone mutation | `[work item type, release scope, platform surface, or not_required reason]` | `[maintainer, orchestrator, release owner, platform owner, pending, or omitted reason]` | `[local policy, maintainer confirmation, platform-surface rule, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Project-field mutation | `[work item type, project surface, status field, routing field, or not_required reason]` | `[maintainer, orchestrator, project owner, platform owner, pending, or omitted reason]` | `[local policy, maintainer confirmation, platform-surface rule, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

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

## Prompt And Handoff Skeletons

Use this section to record local prompt or handoff skeletons for recurring role
transitions. Skeletons should preserve portable role boundaries, include
available artifact identifiers, and avoid requiring recipients to replay broad
history.

| Transition | Skeleton owner | Required local slots | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| Orchestrator to Worker | `[orchestrator, platform surface, project extension, pending, or omitted reason]` | `[active work item, parent scope, accepted scope, evidence pointers, required validation, known risks, deliverables, or local additions]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Worker to Orchestrator | `[worker, platform surface, project extension, pending, or omitted reason]` | `[deliverables, validation claims, self-review evidence, residual risks, out-of-scope findings, next requested decision, or local additions]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Orchestrator to Evaluator | `[orchestrator, platform surface, project extension, pending, or omitted reason]` | `[artifact under review, relevant state refs, acceptance criteria, validation evidence, known risks, exact evaluation question, or local additions]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Evaluator to Orchestrator or maintainer | `[evaluator, platform surface, project extension, pending, or omitted reason]` | `[findings, non-findings, validation assessment, disputed assumptions, readiness recommendation, requested decision, or local additions]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Failure Thresholds And Escalation

Record local thresholds for stopping, escalating, or requesting maintainer
confirmation. Do not infer thresholds from examples or prior agent behavior.

| Condition | Threshold | Required escalation packet | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| `[repeated validation failure, missing authority, contradictory evidence, scope expansion request, sensitive evidence, or other condition]` | `[local threshold, pending decision, omitted reason, or not_required reason]` | `[evidence pointer, validation status, residual risk, requested decision, or limitation]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Workflow Boundaries

- Local exceptions MUST name the portable rule they extend.
- Local exceptions MUST use explicit states when evidence is missing or pending.
- Local exceptions MUST NOT authorize unrelated edits outside the active work
  item.
- Maintainer confirmation MUST state the exact scope confirmed.
- Branch naming, routing, and review gates MUST be recorded as local facts, not
  inferred from examples.
- Label, assignee, reviewer request, milestone, and project-field mutation
  authority MUST be recorded as local policy or platform-surface ownership
  before agents treat it as delegated authority.
- Work-item body edits and progress-state mutations MUST be recorded as local
  authority before agents treat them as delegated authority.
- Release or deployment notes MUST avoid secrets and sensitive operational
  details unless the local secrets policy allows the specific summary.
- Durable output formatting, issue-reference policy, trailers, closure keywords,
  and merge-message policy belong in `output-policy.md` or a platform-surface
  mapping.
