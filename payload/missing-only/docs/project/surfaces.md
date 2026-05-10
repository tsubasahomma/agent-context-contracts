# Project Surfaces

Use this file as concise local memory for repository surfaces that agents
should inspect, update, avoid, regenerate, protect, or route through local
policy. It is not a complete inventory; record surface knowledge only when it
is reusable across work items.

Local surface memory extends the portable source, artifact, output, validation,
evidence-packing, workflow, and ownership contracts. It MUST NOT copy local
surface facts into `docs/agent-context/**` or silently replace portable
boundaries.

Do not record secrets, sensitive values, private personal details,
host-absolute paths, private infrastructure identifiers, temporary task notes,
worker narration, stale process notes, or one-off investigation scratch.

## Surface Memory Rules

- Record only reusable source, artifact, output, generated, entry-point, or
  sensitive-surface knowledge.
- Keep observations and pending decisions visibly non-authoritative.
- Confirmed surface decisions require explicit maintainer confirmation,
  materialized local authority, or another authoritative local evidence pointer.
- Use `unknown`, `pending`, `omitted`, and `not_required` when authority,
  evidence, or applicability is incomplete.
- Use `maintainer_confirmed` only for exact maintainer-confirmed claims.
- Project-memory entries may point to validation evidence, but they are not
  validation evidence by themselves.

## Surface Index

Use this compact index when a surface locator or handling note is reusable but
does not yet need a full decision entry. Keep locators repository-relative or
use safe local artifact names.

| Surface | Surface type | Locator | Handling state | Notes or limits |
| --- | --- | --- | --- | --- |
| `[surface name]` | `[source, artifact, output, generated, entry_point, sensitive, or other type]` | `[repository-relative path, local artifact locator, surface-owned field, or omitted reason]` | `[unknown, pending, omitted, not_required, or confirmed decision pointer]` | `[purpose, owner role, generated status, sensitivity boundary, evidence expectation, or limit]` |

## Observed Surface Case Studies

Record concrete surface cases that may help future agents find, edit, route, or
protect similar surfaces. These entries are evidence pointers and examples, not
policy.

| Case | Surface type | Observation | Evidence pointer | Outcome or limit |
| --- | --- | --- | --- | --- |
| `[case name]` | `[source, artifact, output, generated, entry_point, sensitive, or other type]` | `[what was observed and why it may recur]` | `[local file, issue, pull request, validation evidence, maintainer note, or omitted reason]` | `[reusable lesson, unresolved risk, pending decision, not_required scope, or limit]` |

## Pending Local Surface Decisions

Use this section when a local surface rule, mapping, owner, or edit policy
appears needed but authority has not confirmed it. Pending entries are
proposals or open questions only.

| Decision question | Candidate surface rule | Affected surfaces | Evidence basis | Needed authority or blocker | State |
| --- | --- | --- | --- | --- | --- |
| `[question]` | `[proposed source map, artifact route, output mapping, generated-output edit policy, entry-point rule, sensitive-surface boundary, or omitted reason]` | `[paths, artifact classes, output surfaces, generated files, entry points, sensitive areas, or not_required reason]` | `[observed case, current source, platform surface, maintainer question, or limitation]` | `[maintainer confirmation, local authority rule, surface owner, unavailable evidence, sensitive-data boundary, or blocker]` | `[unknown, pending, omitted, or not_required]` |

## Confirmed Local Surface Decisions

Use this section only for scoped surface memory with authority. Do not promote
an observed surface, generated pattern, issue text, pull request text, label,
checkbox, successful check, or repeated agent behavior into confirmed policy
unless an authority source explicitly makes that surface decisive for the
recorded scope.

| Decision | Scope | Surface types | Authority source | Evidence pointer | Limits |
| --- | --- | --- | --- | --- | --- |
| `[confirmed surface rule, mapping, owner, edit policy, or exception]` | `[exact paths, artifact classes, output surfaces, generated files, entry points, sensitive areas, work types, or other boundary]` | `[source, artifact, output, generated, entry_point, sensitive, or other types]` | `[maintainer confirmation, materialized local authority rule, or authoritative local evidence pointer]` | `[where the authority and supporting evidence are recorded]` | `[what is not authorized, freshness limit, required recheck, sensitivity limit, or portable boundary]` |

## Surface Boundaries

- Keep local source maps and surface handling rules in project memory, not in
  portable contracts under `docs/agent-context/**`.
- Surface entries may guide inspection and routing, but they do not prove
  validation status or current generated-output freshness by themselves.
- Generated outputs should identify when agents edit source, regenerate, or
  avoid direct edits. If that rule is not confirmed, record it as pending.
- Sensitive-surface entries must describe safe categories and handling
  boundaries only. Record redaction and storage policy details in `secrets.md`
  when they are reusable.
- Platform fields, labels, templates, reviewers, assignees, and project fields
  are local or surface-owned mappings, not portable doctrine.
- Do not record transient task notes, issue-plan narration, stale migration
  prose, worker self-reporting, dead comments, or obsolete guidance.
