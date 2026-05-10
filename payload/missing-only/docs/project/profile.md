# Project Profile

Use this file as concise local memory for repository identity, roles, decision
sources, assumptions, and maintainer confirmations that future agents should
reuse. It is not an onboarding form; leave sections sparse until concrete
repository work reveals reusable profile knowledge.

Local profile memory extends the portable source and ownership contracts. It
MUST NOT copy local facts into `docs/agent-context/**` or silently replace
portable role, validation, workflow, artifact, evidence, or installer-safety
boundaries.

Do not record secrets, private personal details, host-absolute paths, temporary
task notes, worker narration, stale process notes, or repository facts that
belong in portable core files.

## Profile Memory Rules

- Record only reusable identity, role, decision-source, assumption, or
  maintainer-confirmation knowledge.
- Keep observations and pending decisions visibly non-authoritative.
- Confirmed profile decisions require explicit maintainer confirmation,
  materialized local authority, or another authoritative local evidence pointer.
- Use `unknown`, `pending`, `omitted`, and `not_required` when authority,
  evidence, or applicability is incomplete.
- Use `maintainer_confirmed` only for exact maintainer-confirmed claims.
- Project-memory entries may point to validation evidence, but they are not
  validation evidence by themselves.

## Observed Profile Case Studies

Record concrete profile cases that may help future agents orient themselves.
These entries are evidence pointers and examples, not policy.

| Case | Profile area | Observation | Evidence pointer | Outcome or limit |
| --- | --- | --- | --- | --- |
| `[case name]` | `[identity, purpose, domain, role, decision source, assumption, confirmation path, or other area]` | `[what was observed and why it may recur]` | `[local file, issue, pull request, maintainer note, or omitted reason]` | `[reusable lesson, unresolved risk, pending decision, not_required scope, or limit]` |

## Pending Local Profile Decisions

Use this section when a reusable profile fact or rule appears needed but
authority has not confirmed it. Pending entries are proposals or open questions
only.

| Decision question | Candidate profile memory | Scope | Evidence basis | Needed authority or blocker | State |
| --- | --- | --- | --- | --- | --- |
| `[question]` | `[proposed identity, role, decision source, assumption, confirmation path, or omitted reason]` | `[repository, path set, work type, artifact class, role boundary, or not_required reason]` | `[observed case, current source, maintainer question, or limitation]` | `[maintainer confirmation, local authority rule, authoritative local source, unavailable evidence, or blocker]` | `[unknown, pending, omitted, or not_required]` |

## Confirmed Local Profile Decisions

Use this section only for scoped profile memory with authority. Do not promote
an observed pattern, repeated agent behavior, issue text, pull request text,
successful check, label, checkbox, or project field into confirmed policy unless
an authority source explicitly makes that surface decisive for the recorded
scope.

| Decision | Scope | Applies to | Authority source | Evidence pointer | Limits |
| --- | --- | --- | --- | --- | --- |
| `[confirmed profile rule, fact, or exception]` | `[exact repository area, path set, work type, artifact class, role boundary, or other boundary]` | `[identity, purpose, domain, role, decision source, assumption, maintainer confirmation, or other area]` | `[maintainer confirmation, materialized local authority rule, or authoritative local evidence pointer]` | `[where the authority and supporting evidence are recorded]` | `[what is not authorized, freshness limit, required recheck, or portable boundary]` |

## Profile Boundaries

- Keep profile facts repository-local. Do not copy them into portable contracts
  under `docs/agent-context/**`.
- Record roles and authority surfaces, not unnecessary personal identifiers.
- Use `unknown`, `pending`, `omitted`, and `not_required` when a profile fact is
  incomplete or intentionally absent.
- Use `maintainer_confirmed` only for exact maintainer-confirmed claims and cite
  the confirming evidence.
- A confirmed profile decision does not authorize validation success,
  workflow mutation, publication, release, cleanup, or broader local policy
  unless its scope explicitly says so.
- Do not record transient task notes, issue-plan narration, stale migration
  prose, worker self-reporting, dead comments, or obsolete guidance.
