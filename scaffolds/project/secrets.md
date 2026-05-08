# Project Secrets Policy

Use this file to record the consumer repository's local secrets and sensitive
data handling policy. This template describes classification, storage,
redaction, and handling boundaries. It must not contain actual secrets.

Do not include tokens, credentials, private keys, passwords, private personal
data, production data samples, or secret-adjacent values in this file.

## Classification

Define the local sensitivity classes agents may encounter. Keep class names and
handling rules safe to share.

| Classification | Examples to describe, not reveal | Allowed handling |
| --- | --- | --- |
| `[classification name]` | `[safe category examples only]` | `[inspect, summarize, redact, omit, or escalate]` |

## Storage Boundaries

Record where sensitive material may be stored or referenced. Do not reveal the
material itself.

| Sensitive material class | Approved storage or locator type | Agent boundary |
| --- | --- | --- |
| `[class]` | `[approved storage category, not a secret value]` | `[may inspect metadata, must not open, ask maintainer, or omitted reason]` |

## Redaction Rules

| Evidence type | Redaction requirement | Allowed summary |
| --- | --- | --- |
| `[command output, file content, CI output, manual evidence, or other type]` | `[mask, omit, paraphrase, aggregate, or maintainer confirmation required]` | `[what can be reported safely]` |

## Forbidden Content

The project extension MUST NOT include:

- actual secrets, tokens, credentials, passwords, private keys, or recovery
  material;
- unredacted private personal data or regulated data;
- production data samples unless the local policy explicitly permits a safe
  redacted form;
- host-absolute paths or private infrastructure identifiers when they are not
  safe to share;
- instructions that ask agents to expose, print, exfiltrate, or weaken secrets.

## Handling Boundaries

| Situation | Required behavior | Validation or confirmation |
| --- | --- | --- |
| `[suspected secret in source]` | `[stop, redact, avoid quoting, ask maintainer, or follow local incident path]` | `[pending, skipped, maintainer_confirmed, or evidence pointer]` |
| `[secret needed for validation]` | `[use existing environment, ask maintainer, mark unavailable, or omit]` | `[validation status and limit]` |
| `[sensitive evidence needed in report]` | `[summarize safely, redact, or omit]` | `[redaction evidence or confirmation]` |

## Escalation And Confirmation

Use maintainer confirmation when a local policy decision could expose sensitive
data, weaken a boundary, or rely on an exception.

| Question | Required confirmer role | Evidence pointer | Scope limit |
| --- | --- | --- | --- |
| `[policy question]` | `[role, not private personal detail]` | `[local evidence pointer]` | `[exact scope and expiration if any]` |

## Unknown Or Omitted Policy

Do not guess secrets policy. If a policy fact is unknown, pending, or omitted,
record that state explicitly and use the matching validation status in reports.

| Policy area | State | Reason | Next safe action |
| --- | --- | --- | --- |
| `[policy area]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[why the state applies]` | `[ask maintainer, mark validation pending, or not required]` |
