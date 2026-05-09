# Project Output Policy

Use this file to record local policy for durable text outputs that agents,
maintainers, tools, vendor shims, or platform surfaces create for this
repository.

Local output policy extends the portable output contract. It MUST NOT silently
replace portable source, artifact, workflow, validation, evidence-packing,
ownership, or safety boundaries.

Do not add concrete local output policy to portable core files. Use explicit
states such as `unknown`, `pending`, `omitted`, and `maintainer_confirmed`
instead of guessing.

## Change-Proposal Bodies

Record local requirements for reviewable change-proposal or pull request bodies.
Use generic field names or placeholders when a consumer-owned platform surface
owns the final template mapping.

| Requirement | Applies to | Local rule or field | Status | Evidence pointer |
| --- | --- | --- | --- | --- |
| `[body requirement]` | `[all changes, risk class, release scope, artifact type, or omitted reason]` | `[required heading, field, evidence, freshness note, or pending decision]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Change Messages

Record local commit, changeset, or version-control message policy. Keep tracker
references, closure syntax, trailers, merge messages, and release conventions
separate so they do not become portable commit-message doctrine.

| Policy area | Local rule | Status | Evidence pointer |
| --- | --- | --- | --- |
| Subject format | `[imperative, structured, scoped, pending, omitted, or maintainer_confirmed rule]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Body expectations | `[when rationale, risk, migration, validation, or behavior notes are required]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Allowed scopes | `[scope list, discovery path, pending decision, or omitted reason]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Issue references | `[allowed, required, forbidden, surface-owned, pending, or omitted reason]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Closure keywords | `[allowed, required, forbidden, surface-owned, pending, or omitted reason]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Trailers | `[allowed, required, forbidden, surface-owned, pending, or omitted reason]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |
| Merge-message policy | `[squash, merge, release, surface-owned, pending, or omitted rule]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[local evidence pointer or limitation]` |

## Issue And Prompt Fields

Record local fields expected in issue bodies, worker prompts, evaluator prompts,
review findings, validation reports, readiness reports, or evidence summaries.
Fields should help consumers review scope and evidence without requiring broad
history.

| Output type | Local field | Required when | Evidence or validation expectation |
| --- | --- | --- | --- |
| `[issue, worker prompt, evaluator prompt, review finding, validation report, readiness report, or evidence summary]` | `[field name or omitted reason]` | `[scope, risk class, artifact type, pending decision, or maintainer confirmation]` | `[evidence pointer, validation status, limitation, or not_required reason]` |

## Command And Structured Body Handling

Record local policy for command snippets, command bodies, body files, standard
input, structured API fields, platform-surface fields, or equivalent safe
artifact boundaries.

| Body type | Safe boundary | Local handling rule | Unavailable or sensitive handling |
| --- | --- | --- | --- |
| `[command snippet, command body, issue body, change-proposal body, prompt, report, or other structured body]` | `[body file, stdin, structured field, surface-owned field, pending, or omitted reason]` | `[copyable boundary, quoting rule, storage locator, or confirmation requirement]` | `[pending, skipped, not_required, omitted, redacted, or maintainer_confirmed handling]` |

## Release, Rollback, And Readiness Notes

Record output requirements for release notes, rollback notes, deployment notes,
readiness reports, and follow-up summaries when those outputs are local policy.

| Output | Required local content | Evidence expectation | Boundary |
| --- | --- | --- | --- |
| `[release, rollback, deployment, readiness, or follow-up output]` | `[field, note, owner role, pending decision, or omitted reason]` | `[validation claim, maintainer confirmation, inspected state, or limitation]` | `[what this output may not decide or claim]` |

## Surface-Owned Platform Fields

Record local decisions about platform surface fields without making them
portable doctrine. If the project does not use a platform surface, record
`not_required` or an omitted reason.

| Field or mechanism | Owner layer | Local handling | Status |
| --- | --- | --- | --- |
| `[label, status, checkbox, template field, reviewer request, milestone, release field, or omitted reason]` | `[project extension, platform surface, platform, maintainer, or unknown]` | `[required, optional, forbidden, surface-owned, pending, or omitted reason]` | `[unknown, pending, omitted, not_required, or maintainer_confirmed]` |

## Output Boundaries

- Local output policy MUST identify whether a rule is confirmed, pending,
  omitted, unknown, or `maintainer_confirmed`.
- Local policy MAY specialize exact headings, fields, references, trailers,
  message conventions, body handling, and platform-surface mapping.
- Local policy MUST NOT claim validation success without evidence that satisfies
  the portable validation contract.
- Static output bodies MUST NOT mirror changing review, CI, deployment, or
  external state as always-current truth.
- Command text that is meant to be copied or executed should be separated from
  unrelated narrative.
- Surface-owned fields MUST remain platform-surface or platform mappings, not
  durable portable-core doctrine.
