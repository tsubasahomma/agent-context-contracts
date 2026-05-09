# Project Output Policy

Use this file to record local policy for durable text outputs that agents,
maintainers, tools, vendor shims, or platform surfaces create for this
repository.

Local output policy extends the portable output contract. It MUST NOT silently
replace portable source, artifact, workflow, validation, evidence-packing,
ownership, or safety boundaries.

Do not add concrete local output policy to portable core files. Use explicit
states such as `unknown`, `pending`, `omitted`, `not_required`, and
`maintainer_confirmed` instead of guessing.

## Local Decision States

Use these states when recording local policy decisions:

- `unknown`: the local decision has not been investigated.
- `pending`: the decision is expected but not settled.
- `omitted`: this output intentionally leaves the field or mechanism out.
- `not_required`: this output does not need the field or mechanism for the
  stated local scope.
- `maintainer_confirmed`: the local decision is backed by explicit maintainer
  confirmation.

Add other local state values only when the project owns their meaning.

## Language Policy

Record local language decisions for conversational coordination and durable
artifacts. Keep the two decisions separate because conversation language and
durable artifact language may serve different consumers.

| Language surface | Applies to | Local decision | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| Conversation language | `[agent conversation, maintainer coordination, platform comments, pending decision, or not_required reason]` | `[local language, follow requester language, surface-owned rule, pending, omitted, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Durable artifact language | `[repository documentation, issue bodies, change proposals, review comments, validation reports, readiness reports, pending decision, or not_required reason]` | `[local language, artifact-specific rule, surface-owned rule, pending, omitted, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Parent Issue Local Fields

Record local field decisions for Parent Issue bodies. Use placeholders until a
consumer-owned tracker, project extension, or platform surface confirms concrete
field names.

| Local field slot | Required when | Local handling | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| `[parent field name or omitted reason]` | `[parent scope type, risk class, tracker surface, pending decision, or not_required reason]` | `[required, optional, surface-owned, project-extension-owned, omitted, or pending]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Child Issue Local Fields

Record local field decisions for Child Issue bodies. Keep the entries focused on
one bounded work item and local routing needs.

| Local field slot | Required when | Local handling | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| `[child field name or omitted reason]` | `[work item type, affected surface, dependency, risk class, pending decision, or not_required reason]` | `[required, optional, surface-owned, project-extension-owned, omitted, or pending]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Change-Proposal Local Fields

Record local requirements for reviewable change-proposal or pull request bodies.
Use generic field names or placeholders when a consumer-owned platform surface
owns the final template mapping.

| Local field slot | Applies to | Local handling | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| `[proposal field name, platform field, or omitted reason]` | `[all changes, risk class, release scope, artifact type, pending decision, or not_required reason]` | `[required heading, optional field, surface-owned mapping, evidence note, freshness note, omitted, or pending]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Change Messages

Record local commit, changeset, or version-control message policy. Keep subject
and body limits practical, and record local exceptions instead of treating a
numeric target as an absolute validity gate.

| Policy area | Local decision | Practical exceptions | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| Subject style | `[plain imperative, scoped, structured, generated, pending, omitted, or maintainer_confirmed rule]` | `[exception category, not_required reason, or omitted]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Subject length target | `[local target, soft limit, pending decision, omitted, or not_required reason]` | `[URLs, generated identifiers, machine fields, local exception category, or omitted]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Body line target | `[local target, soft limit, pending decision, omitted, or not_required reason]` | `[URLs, code, diagnostic output, trailers, machine fields, non-prose text, local exception category, or omitted]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Body required when | `[rationale, risk, validation, release impact, discarded alternative, pending decision, or omitted reason]` | `[exception category, not_required reason, or omitted]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Scope notation | `[scope list source, surface-owned scope, pending decision, omitted, or not_required reason]` | `[exception category, not_required reason, or omitted]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Commit Conventions

Record whether this project opts in to, opts out of, defers, or omits named
commit-message conventions. Do not treat any convention as the local default
until this table records the local decision.

| Convention area | Local decision | Applies to | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| Conventional Commits | `[opt_in, opt_out, pending, omitted, not_required, or maintainer_confirmed decision]` | `[all changes, release changes, generated changes, platform surface, pending decision, or omitted reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Other named convention | `[convention name placeholder, opt_in, opt_out, pending, omitted, not_required, or maintainer_confirmed decision]` | `[all changes, release changes, generated changes, platform surface, pending decision, or omitted reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Tracker References, Closure Syntax, And Trailers

Record local decisions for tracker references, closure syntax, and message
trailers. Use placeholders for syntax examples until the owning tracker or
platform surface confirms concrete forms.

| Policy area | Local decision | Applies to | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| Tracker references | `[allowed, required, forbidden, surface-owned, pending, omitted, or not_required reason]` | `[issue bodies, proposal bodies, change messages, release notes, platform field, or omitted reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Closure syntax | `[allowed, required, forbidden, surface-owned, pending, omitted, or not_required reason]` | `[issue bodies, proposal bodies, change messages, merge messages, platform field, or omitted reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |
| Message trailers | `[allowed, required, forbidden, surface-owned, pending, omitted, or not_required reason]` | `[change messages, merge messages, release changes, generated changes, or omitted reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Merge Messages And Release Notes

Record local policy for merge-message bodies, release-note fields, rollback
notes, deployment notes, readiness reports, and follow-up summaries when those
outputs are local policy.

| Output | Required local content | Evidence expectation | Status | Boundary |
| --- | --- | --- | --- | --- |
| `[merge message, release note, rollback note, deployment note, readiness report, follow-up output, or omitted reason]` | `[field, note, owner role, pending decision, omitted, or not_required reason]` | `[validation claim, maintainer confirmation, inspected state, surface-owned field, limitation, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[what this output may not decide or claim]` |

## Issue And Prompt Fields

Record local fields expected in issue bodies, worker prompts, evaluator prompts,
review findings, validation reports, readiness reports, or evidence summaries.
Fields should help consumers review scope and evidence without requiring broad
history.

| Output type | Local field | Required when | Evidence or validation expectation | Status |
| --- | --- | --- | --- | --- |
| `[worker prompt, evaluator prompt, review finding, validation report, readiness report, evidence summary, or omitted reason]` | `[field name, evidence slot, status slot, or omitted reason]` | `[scope, risk class, artifact type, pending decision, not_required reason, or maintainer confirmation]` | `[evidence pointer, validation status, limitation, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` |

## AI-Authored Comments

Record local policy for agent-authored comments on collaboration surfaces.
Comments should be sparse, role-specific, and evidence-oriented. Do not require
comments for every progress update unless a consumer-owned surface or local
policy explicitly owns that requirement.

| Comment purpose | Required when | Required content | Local placement or owner | Status | Evidence pointer |
| --- | --- | --- | --- | --- | --- |
| `[worker readiness, evaluator finding, orchestrator routing, maintainer question, or omitted reason]` | `[scope, risk class, platform event, pending decision, not_required reason, or maintainer confirmation]` | `[role or purpose, evidence basis, requested decision or next owner, limitations, or omitted reason]` | `[project extension, platform surface, owner role, pending, or omitted reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` | `[local evidence pointer, confirmation reference, or limitation]` |

## Command And Structured Body Handling

Record local policy for command snippets, command bodies, body files, standard
input, structured API fields, platform-surface fields, or equivalent safe
artifact boundaries.

| Body type | Safe boundary | Local handling rule | Unavailable or sensitive handling |
| --- | --- | --- | --- |
| `[command snippet, command body, issue body, change-proposal body, prompt, report, or other structured body]` | `[body file, stdin, structured field, surface-owned field, pending, or omitted reason]` | `[copyable boundary, quoting rule, storage locator, or confirmation requirement]` | `[pending, skipped, not_required, omitted, redacted, or maintainer_confirmed handling]` |

## Platform Surface Mapping

Record local decisions about platform surface fields without making them
portable doctrine. If the project does not use a platform surface, record
`not_required` or an omitted reason.

| Surface field or mechanism | Mapped local output | Owner layer | Local handling | Status |
| --- | --- | --- | --- | --- |
| `[label placeholder, status placeholder, checkbox placeholder, template field placeholder, reviewer request placeholder, milestone placeholder, release field placeholder, or omitted reason]` | `[parent issue, child issue, change proposal, change message, release note, validation report, readiness report, or omitted reason]` | `[project extension, platform surface, platform, maintainer, or unknown]` | `[required, optional, forbidden, surface-owned, pending, omitted, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` |
| `[assignee placeholder or omitted reason]` | `[parent issue, child issue, change proposal, review surface, or omitted reason]` | `[project extension, platform surface, platform, maintainer, or unknown]` | `[required, optional, forbidden, surface-owned, pending, omitted, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` |
| `[reviewer request placeholder or omitted reason]` | `[change proposal, review surface, release change, or omitted reason]` | `[project extension, platform surface, platform, maintainer, or unknown]` | `[required, optional, forbidden, surface-owned, pending, omitted, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` |
| `[project-field placeholder or omitted reason]` | `[parent issue, child issue, change proposal, readiness report, or omitted reason]` | `[project extension, platform surface, platform, maintainer, or unknown]` | `[required, optional, forbidden, surface-owned, pending, omitted, or not_required reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` |

## Output Boundaries

- Local output policy MUST identify whether a rule is confirmed, pending,
  omitted, unknown, `not_required`, or `maintainer_confirmed`.
- Local policy MAY specialize exact headings, fields, references, trailers,
  message conventions, body handling, language choices, and platform-surface
  mapping.
- Local policy MUST NOT claim validation success without evidence that satisfies
  the portable validation contract.
- Static output bodies MUST NOT mirror changing review, CI, deployment, or
  external state as always-current truth.
- Command text that is meant to be copied or executed should be separated from
  unrelated narrative.
- Surface-owned fields MUST remain platform-surface or platform mappings, not
  durable portable-core doctrine.
