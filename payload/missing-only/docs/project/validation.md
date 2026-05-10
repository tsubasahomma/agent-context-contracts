# Project Validation

Use this file to record reusable local validation memory for one consumer
repository. It may cover local commands, manual checks, CI checks, environment
assumptions, output validation routing, evidence expectations, unavailable
checks, and validation-specific case studies.

Portable validation status tokens are `passed`, `failed`, `pending`, `skipped`,
`not_required`, and `maintainer_confirmed`. Use them in validation reports and
readiness summaries when making validation claims.

Local validation memory extends the portable validation contract. It MUST NOT
silently replace the portable claim model, status vocabulary, evidence
requirements, success-claim rules, or reporting boundaries.

Do not use this file as a complete validation questionnaire. Leave it sparse
until concrete repository work reveals reusable validation knowledge.

Durable output body rules belong in `output-policy.md`. Workflow gates and
handoff routing belong in `workflows.md`.

## Validation Memory Rules

Use the local memory layers below. Observed cases and pending validation
decisions are non-authoritative. They may guide future checks, but they do not
make validation `passed`, authorize a skipped check, or prove readiness.

`Confirmed Local Decisions` are authoritative only for their recorded scope. A
confirmed validation decision requires explicit maintainer confirmation, a
materialized local authority rule, or another recorded authoritative local
evidence pointer whose ownership, freshness, and scope are clear.

When authority is missing, keep the entry in `Observed Validation Case Studies`,
`Pending Local Validation Decisions`, or an explicit state such as `unknown`,
`pending`, `omitted`, or `not_required`.

`maintainer_confirmed` is an explicit state or evidence marker for the exact
confirmed claim. It is not a synonym for every `Confirmed Local Decision`;
confirmed decisions may also be authorized by a materialized local authority
rule or another authoritative local evidence pointer.

Project-memory entries may describe which checks are expected and what evidence
is useful, but the entry itself is not validation evidence. A validation claim
must cite observed command output, inspected state, CI evidence, manual review
evidence, exact maintainer confirmation, or another evidence type allowed by the
portable validation contract.

## Observed Validation Case Studies

Record concrete validation cases that may help future agents choose or report
checks. These entries are evidence pointers and examples, not policy.

| Case | Validation area | Observation | Evidence pointer | Outcome or limit |
| --- | --- | --- | --- | --- |
| `[case name]` | `[command, manual check, CI check, environment assumption, output validation, unavailable check, evidence handling, or other area]` | `[what was checked, unavailable, surprising, flaky, sensitive, or useful]` | `[command output, local file, CI run, issue, pull request, maintainer note, or omitted reason]` | `[reusable lesson, residual risk, pending decision, not_required scope, or limit]` |

## Pending Local Validation Decisions

Use this section when a local validation rule appears needed but authority has
not confirmed it. Pending entries are proposals or open questions only.

| Decision question | Candidate validation rule | Scope | Evidence basis | Needed authority or blocker | State |
| --- | --- | --- | --- | --- | --- |
| `[question]` | `[proposed command, manual check, CI expectation, environment assumption, output check, unavailable-check handling, evidence rule, or omitted reason]` | `[paths, artifacts, behavior, output type, risk class, release scope, or not_required reason]` | `[observed case, current source, CI evidence, maintainer question, or limitation]` | `[maintainer confirmation, local authority rule, platform owner, unavailable evidence, sensitive-data boundary, or blocker]` | `[unknown, pending, omitted, or not_required]` |

## Confirmed Local Validation Decisions

Use this section only for scoped local validation policy with authority. Do not
promote an observed check, successful run, issue text, pull request text, label,
checkbox, project field, or repeated agent behavior into confirmed policy unless
an authority source explicitly makes that surface decisive for the recorded
scope.

| Decision | Scope | Required evidence | Authority source | Evidence pointer | Limits |
| --- | --- | --- | --- | --- | --- |
| `[confirmed validation rule or exception]` | `[exact paths, artifacts, behavior, output type, risk class, release scope, or other boundary]` | `[command output, inspected state, CI result, manual review, maintainer confirmation, redacted summary, or not_required reason]` | `[maintainer confirmation, materialized local authority rule, or authoritative local evidence pointer]` | `[where the authority and supporting evidence are recorded]` | `[what is not validated, freshness limit, required recheck, redaction limit, or portable boundary]` |

## Common Validation Decision Areas

Record an entry above only when it is reusable. Common validation decisions
include:

- local commands, procedures, fixtures, generated-output checks, and safe
  command documentation boundaries;
- environment, dependency, service, data, credential, and runtime assumptions
  that are safe to record in a consumer-owned file;
- manual review criteria, CI checks, output validation routing, evidence
  expectations, and unavailable-check handling;
- redaction or omission rules for sensitive validation evidence;
- handling for checks that are `pending`, `skipped`, `not_required`, or
  `maintainer_confirmed`.

## Validation Boundaries

- Unavailable validation MUST NOT be reported as `passed`; use `pending`,
  `skipped`, or `not_required` with a reason.
- `passed` and `maintainer_confirmed` claims require evidence for the exact
  subject and scope being reported.
- A local command or CI expectation recorded here is not proof of a later
  command result or CI result.
- Output validation MUST preserve the output role. A validation report records
  evidence and status; it is not a readiness report unless workflow readiness
  requirements are also satisfied.
- Do not copy local commands, runtime assumptions, CI names, or environment
  facts into portable core files.
- Do not record secrets, sensitive values, transient task details, stale
  historical prose, role-specific scratch narration, commented-out
  instructions, or obsolete guidance.
