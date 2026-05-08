# Project Validation

Use this file to record validation commands, manual checks, CI checks,
environment assumptions, output-artifact validation routing, evidence
expectations, and unavailable checks for a consumer repository.

Portable validation status tokens are `passed`, `failed`, `pending`, `skipped`,
`not_required`, and `maintainer_confirmed`. Use them in local validation reports
and readiness summaries when making claims about checks.

Do not copy local commands or environment assumptions into portable core files.
Durable output body requirements belong in `output-policy.md`; this file records
how validation for those outputs is run, evidenced, skipped, or marked
unavailable.

## Local Validation Commands

Record only commands that are safe to document for this repository. Use
placeholders or omitted states when command details are sensitive or undecided.

| Check | Command or procedure | Covers | Evidence expected |
| --- | --- | --- | --- |
| `[check name]` | `[local command, procedure, pending, or omitted reason]` | `[paths, artifacts, or behaviors]` | `[exit status, output summary, inspected artifact, or limitation]` |

## Environment Assumptions

Local runtime, dependency, service, data, and credential assumptions belong here
or in another consumer-owned local file. Do not treat them as portable baseline
requirements.

| Assumption | Required for | Status | Notes |
| --- | --- | --- | --- |
| `[environment assumption]` | `[validation command, manual check, CI check, or workflow]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[safe setup notes or limitation]` |

## Manual Checks

| Check | Criteria | Evidence expected | When unavailable |
| --- | --- | --- | --- |
| `[manual check]` | `[review criteria]` | `[reviewed files, rendered output, comparison, or maintainer confirmation]` | `[pending, skipped, not_required, or escalation rule]` |

## CI Checks

Use generic CI check names or local identifiers that are safe to record. Do not
add platform-specific requirements unless they are truly local project facts.

| Check | Covers | Required status | Evidence pointer |
| --- | --- | --- | --- |
| `[CI check name or omitted reason]` | `[scope covered]` | `[passed, failed, pending, skipped, not_required, or maintainer_confirmed]` | `[run locator, summary location, or unavailable reason]` |

## Evidence Expectations

Validation claims should cite evidence that later reviewers can inspect.

| Evidence type | Local expectation | Redaction or limit |
| --- | --- | --- |
| Command evidence | `[exit status, relevant output, subject coverage]` | `[redaction or omitted reason]` |
| Inspected-state evidence | `[paths, diffs, rendered artifacts, or source state]` | `[redaction or omitted reason]` |
| CI evidence | `[check result, covered revision, output summary]` | `[redaction or omitted reason]` |
| Manual review evidence | `[criteria, reviewer role, inspected artifacts]` | `[redaction or omitted reason]` |
| Maintainer confirmation | `[exact confirmation and evidence pointer]` | `[scope limits]` |

## Output Validation Routing

Use this section to record which validation or review checks apply to durable
outputs such as change-proposal bodies, change messages, issue bodies, worker
prompts, evaluator prompts, validation reports, readiness reports, command
bodies, release notes, rollback notes, or evidence summaries.

| Output type | Required check | Evidence expected | When unavailable |
| --- | --- | --- | --- |
| `[output type]` | `[local command, manual review, adapter check, maintainer confirmation, pending, or omitted reason]` | `[status, output summary, inspected body, rendered artifact, or limitation]` | `[pending, skipped, not_required, maintainer_confirmed, or escalation rule]` |

## Unavailable Checks

Unavailable validation MUST NOT be reported as passed. Use this section to make
missing evidence explicit.

| Check | State | Reason | Residual risk | Next action |
| --- | --- | --- | --- | --- |
| `[unavailable check]` | `[pending, skipped, or not_required]` | `[why evidence is unavailable]` | `[risk if any]` | `[rerun, ask maintainer, defer, or no action]` |

## Validation Boundaries

- Local validation commands and procedures MUST stay in consumer-owned files.
- Unavailable checks MUST use `pending`, `skipped`, or `not_required`; they MUST
  NOT be reported as `passed`.
- Output validation MUST preserve the output role. A validation report records
  evidence and status; it does not become a readiness report unless the workflow
  readiness requirements are also satisfied.
- Static output bodies SHOULD cite observed validation evidence and freshness
  instead of mirroring changing CI, review, deployment, or external state.
