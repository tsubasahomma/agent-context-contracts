# Project Workflows

Use this file to record reusable local workflow memory for one consumer
repository. It may cover lifecycle gates, mutation authority, branch or change
routing, handoff additions, escalation, release routing, rollback routing, and
workflow exceptions that portable contracts cannot decide.

Local workflow memory extends the portable workflow contract. It MUST NOT
silently replace portable role boundaries, handoff requirements, validation
status vocabulary, ownership rules, or irreversible-publication gates.

Do not use this file as a human-filled workflow questionnaire. Leave it sparse
until concrete repository work reveals reusable workflow knowledge.

Durable output body rules belong in `output-policy.md`. Validation commands and
evidence expectations belong in `validation.md`.

## Workflow Memory Rules

Use the local memory layers below. Observations and pending decisions are
non-authoritative. They may guide future inspection, but they do not authorize a
workflow action, broaden scope, or prove validation.

`Confirmed Local Decisions` are authoritative only for their recorded scope. A
confirmed workflow decision requires explicit maintainer confirmation, a
materialized local authority rule, or another recorded authoritative local
evidence pointer whose ownership, freshness, and scope are clear.

When authority is missing, keep the entry in `Observed Workflow Case Studies`,
`Pending Local Workflow Decisions`, or an explicit state such as `unknown`,
`pending`, `omitted`, or `not_required`.

`maintainer_confirmed` is an explicit state or evidence marker for the exact
confirmed claim. It is not a synonym for every `Confirmed Local Decision`;
confirmed decisions may also be authorized by a materialized local authority
rule or another authoritative local evidence pointer.

Project-memory entries may point to validation evidence, but they are not
validation evidence by themselves. Validation claims still need evidence that
satisfies the portable validation contract.

## Observed Workflow Case Studies

Record concrete workflow cases that may help future agents recognize recurring
local patterns. These entries are evidence pointers and examples, not policy.

| Case | Workflow area | Observation | Evidence pointer | Outcome or limit |
| --- | --- | --- | --- | --- |
| `[case name]` | `[lifecycle gate, mutation authority, handoff, escalation, branch routing, release routing, rollback routing, or other area]` | `[what happened and why it may recur]` | `[issue, pull request, local file, validation report, maintainer note, or omitted reason]` | `[reusable lesson, unresolved risk, pending decision, not_required scope, or limit]` |

## Pending Local Workflow Decisions

Use this section when a local workflow rule appears needed but authority has not
confirmed it. Pending entries are proposals or open questions only.

| Decision question | Candidate local rule | Scope | Evidence basis | Needed authority or blocker | State |
| --- | --- | --- | --- | --- | --- |
| `[question]` | `[proposed rule, exception, owner, routing path, or omitted reason]` | `[paths, work item type, risk class, platform surface, release scope, or not_required reason]` | `[observed case, current source, platform surface, maintainer question, or limitation]` | `[maintainer confirmation, local authority rule, platform owner, unavailable evidence, or blocker]` | `[unknown, pending, omitted, or not_required]` |

## Confirmed Local Workflow Decisions

Use this section only for scoped local workflow policy with authority. Do not
promote an observed pattern, successful check, issue text, label, checkbox,
project field, or repeated agent behavior into confirmed policy unless an
authority source explicitly makes that surface decisive for the recorded scope.

| Decision | Scope | Applies to | Authority source | Evidence pointer | Limits |
| --- | --- | --- | --- | --- | --- |
| `[confirmed workflow rule or exception]` | `[exact paths, work item type, risk class, platform surface, release scope, or other boundary]` | `[lifecycle gate, mutation area, handoff, escalation, branch routing, release routing, rollback routing, or review gate]` | `[maintainer confirmation, materialized local authority rule, or authoritative local evidence pointer]` | `[where the authority and supporting evidence are recorded]` | `[what is not authorized, freshness limit, required recheck, or portable boundary]` |

## Common Workflow Decision Areas

Record an entry above only when it is reusable. Common workflow decisions include:

- lifecycle gates for accepted implementation scope, worker readiness,
  independent evaluation, final acceptance, merge, release, issue closure,
  destructive cleanup, and other irreversible publication;
- mutation authority for work-item bodies, acceptance criteria, checkboxes,
  tasklists, labels, assignees, reviewer requests, milestones, project fields,
  status columns, and other progress surfaces;
- branch naming, change ownership, scope escalation, handoff additions, prompt
  skeleton ownership, failure thresholds, release routing, and rollback routing;
- platform-surface mappings that route progress, not validation evidence.

## Workflow Boundaries

- Local workflow entries MUST preserve Planning, Orchestrator, Worker, and
  Evaluator role boundaries.
- Worker self-review is required readiness evidence, not final independent
  approval.
- Final acceptance, merge, release, destructive cleanup, issue closure, or
  equivalent irreversible publication requires explicit owning process,
  maintainer confirmation, or project-local delegation.
- Progress state such as labels, checkboxes, tasklists, project fields, and
  status columns MAY help routing, but it MUST NOT become validation evidence,
  review evidence, final approval, closure authority, or
  irreversible-publication authority by itself.
- Do not infer branch policy, reviewer policy, label taxonomy, assignment
  authority, release authority, or cleanup authority from examples alone.
- Do not record secrets, sensitive operational details, transient task details,
  stale historical prose, role-specific scratch narration, commented-out
  instructions, or obsolete guidance.
