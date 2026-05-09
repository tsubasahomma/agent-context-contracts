# Project Profile

Use this file to record local project identity and decision context for a
consumer repository. Keep it concise and safe to share with agents that work in
this repository.

Do not include secrets, private personal details, host-absolute paths, or facts
that belong in portable core contracts.

## Local Identity

| Field | Local value |
| --- | --- |
| Project name | `[project name or unknown]` |
| Project purpose | `[short product, service, library, research, or operations purpose]` |
| Domain context | `[domain terms, user groups, regulated areas, or omitted reason]` |
| Primary artifact types | `[source, documentation, data, generated assets, or other artifact classes]` |
| Project extension path | `[docs/project or declared alternate path]` |

## Owning Roles

Record roles, not private personal details.

| Role | Responsibility | Confirmation state |
| --- | --- | --- |
| `[role name]` | `[what this role owns]` | `[unknown, pending, omitted, or maintainer_confirmed]` |

## Decision Sources

Use this section to tell agents where durable local decisions are recorded.
Prefer repository-relative paths or stable local artifact names.

| Source | Owns | Notes |
| --- | --- | --- |
| `[decision source]` | `[policy, architecture, product, release, operations, or other scope]` | `[freshness, limits, or confirmation state]` |

## Local Assumptions

Local assumptions are allowed here because this file is consumer-owned. They
MUST NOT be copied into `docs/agent-context/**`.

| Assumption | Status | Evidence or limit |
| --- | --- | --- |
| `[local assumption]` | `[unknown, pending, omitted, or maintainer_confirmed]` | `[evidence pointer or limitation]` |

## Maintainer Confirmation

Use this section only for explicit confirmations. Do not infer broad permission
from a narrow confirmation.

| Confirmed item | Scope | Evidence pointer | Limits |
| --- | --- | --- | --- |
| `[what was confirmed]` | `[exact scope]` | `[local evidence pointer]` | `[what is not covered]` |
