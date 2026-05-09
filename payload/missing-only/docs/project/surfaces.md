# Project Surfaces

Use this file to map the consumer repository surfaces that agents should inspect
or protect. Keep the map factual, repository-local, and reviewable.

Do not add these local surface facts to portable core files.

## Source Surfaces

| Surface | Path or locator | Owner or steward | Notes |
| --- | --- | --- | --- |
| `[source surface name]` | `[repository-relative path or omitted reason]` | `[role or unknown]` | `[purpose, generated status, or limits]` |

## Artifact Surfaces

Record durable artifacts that agents may create, update, or review.

| Artifact surface | Path or locator | Artifact kind | Evidence expectations |
| --- | --- | --- | --- |
| `[artifact surface name]` | `[repository-relative path or local artifact locator]` | `[contract, report, generated output, release artifact, or other kind]` | `[evidence pointer expectations]` |

## Output Artifact Surfaces

Record durable text output surfaces separately when local policy, review,
validation, or platform-surface mapping depends on where the output is stored or
posted.

| Output surface | Path, locator, or owner layer | Output role | Handling notes |
| --- | --- | --- | --- |
| `[change proposal, change message, issue body, worker prompt, evaluator prompt, validation report, readiness report, command body, release note, rollback note, or evidence summary]` | `[repository-relative path, local artifact locator, surface-owned field, platform-owned field, or omitted reason]` | `[proposal, message, prompt, finding, report, command, summary, or other role]` | `[output-policy link, validation expectation, sensitivity limit, or pending decision]` |

## Entry Points

Entry points are files, commands, documents, or interfaces that shape how agents
orient themselves in the project. Command details belong here only when they are
safe local facts.

| Entry point | Purpose | Handling notes |
| --- | --- | --- |
| `[entry point]` | `[how it is used]` | `[unknown, pending, omitted, or maintainer_confirmed]` |

## Generated Outputs

Generated outputs should be identified so agents know when to edit sources
instead of generated artifacts.

| Output | Generated from | Regeneration owner | Edit policy |
| --- | --- | --- | --- |
| `[generated output]` | `[source or process]` | `[role, command placeholder, or unknown]` | `[edit source, regenerate, manual edit allowed, or omitted reason]` |

## Sensitive Surfaces

Sensitive surfaces are areas requiring extra care because they may contain
secrets, private data, regulated data, credentials, production operations data,
or other restricted material. Do not include the sensitive values themselves.

| Surface | Sensitivity | Handling boundary | Evidence rule |
| --- | --- | --- | --- |
| `[sensitive surface]` | `[classification]` | `[allowed inspection, redaction, or escalation boundary]` | `[what can be quoted, summarized, or omitted]` |

## Unknown Or Omitted Surfaces

| Surface question | State | Reason | Next safe action |
| --- | --- | --- | --- |
| `[surface needing clarification]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[why the state applies]` | `[ask maintainer, inspect path, skip, or not required]` |
