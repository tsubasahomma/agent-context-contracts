# Evaluation Contracts

This document defines reusable evaluation cases for predictable contract
failures in portable agent-context repositories. The cases are reviewable
questions, not an executable test suite.

Evaluation cases help planners, workers, and evaluators decide whether a change
preserves portable boundaries. They do not define repository-local policy,
project-specific validation commands, platform templates, vendor shim behavior,
installer implementation details, or portability-lint rules.

## Evaluation Case Format

Each evaluation case SHOULD identify:

- a stable case identifier;
- the risk being evaluated;
- the governing contract;
- the input or condition under review;
- pass and fail conditions;
- expected evidence for the evaluation claim.

Evaluation reports SHOULD use the validation status vocabulary in
[validation.md](validation.md).

## EVAL-001 Portable Fact Leakage

| Field | Evaluation |
| --- | --- |
| Risk | Portable contracts or missing-only starters embed repository identity, host paths, local commands, private identifiers, secrets, branch policy, concrete tracker references, or local operational facts. |
| Governing contract | [core.md](core.md), [sources.md](sources.md), [ownership.md](ownership.md), and [validation.md](validation.md). |
| Input or condition | Portable contracts, root routing instructions, missing-only starter files, vendor shims, lint fixtures, or proposed contract changes. |
| Pass condition | Reusable text uses repository-agnostic language or explicit placeholders, and local facts are confined to consumer-owned `docs/project/**` files after installation. |
| Fail condition | Reusable text requires or reveals a concrete repository, host path, command, private identifier, secret-adjacent value, branch convention, tracker number, platform label, reviewer, CI name, release policy, or local workflow fact. |
| Expected evidence | Portability-lint output when applicable, targeted leakage searches, and manual review of changed reusable text. |

## EVAL-002 Routing Shim Boundary Drift

| Field | Evaluation |
| --- | --- |
| Risk | A vendor routing shim becomes the durable source of portable doctrine or local policy. |
| Governing contract | [ownership.md](ownership.md), [sources.md](sources.md), and [core.md](core.md). |
| Input or condition | A missing-only vendor instruction file or proposed routing-shim change. |
| Pass condition | The shim routes readers to `AGENTS.md`, `docs/agent-context/README.md`, and relevant `docs/project/**` files without duplicating portable doctrine or inventing local facts. |
| Fail condition | The shim contains standalone operating rules, local project facts, validation claims, platform requirements, or durable policy that belongs to portable contracts or the project extension. |
| Expected evidence | Diff review of the shim and link checks to the owning contracts. |

## EVAL-003 Installer Ownership Behavior

| Field | Evaluation |
| --- | --- |
| Risk | Installer behavior blurs source-owned portable payload and consumer-owned missing-only payload. |
| Governing contract | [ownership.md](ownership.md). |
| Input or condition | Installer design, fixture output, dry-run output, or implementation diff. |
| Pass condition | `AGENTS.md` and `docs/agent-context/**` are refreshed from one resolved source commit; `payload/missing-only/**` files are created only when absent; existing `docs/project/**` and vendor files are preserved; no consumer-side state file is created. |
| Fail condition | The installer patches, merges, overwrites, deletes, renames, or tracks missing-only files; requires previous state; creates a lock or equivalent state file; installs platform collaboration surfaces by default; or exposes a package-manager lifecycle as public adoption behavior. |
| Expected evidence | Focused installer fixtures, inspected target files, resolved commit output, archive-fetch evidence, and absence of state-file creation. |

## EVAL-004 Handoff Boundedness

| Field | Evaluation |
| --- | --- |
| Risk | A handoff or evidence pack requires a recipient to replay broad history or trust stale facts. |
| Governing contract | [workflows.md](workflows.md), [sources.md](sources.md), and [evidence-packing.md](evidence-packing.md). |
| Input or condition | Worker prompt, evaluator prompt, evidence pack, readiness report, or handoff body. |
| Pass condition | The artifact has bounded scope, evidence pointers, freshness, limitations, and role-specific deliverables. It treats handoff text as scope evidence rather than proof of current repository state. |
| Fail condition | The artifact depends on unbounded conversation history, stale generated summaries, or unsupported claims as factual proof. |
| Expected evidence | Handoff artifact review and source-class analysis for material claims. |

## EVAL-005 Validation Claim Support

| Field | Evaluation |
| --- | --- |
| Risk | A validation or readiness claim reports success without evidence. |
| Governing contract | [validation.md](validation.md), [outputs.md](outputs.md), and [workflows.md](workflows.md). |
| Input or condition | Validation report, readiness report, change-proposal body, review finding, or evaluation report. |
| Pass condition | Each claim uses `passed`, `failed`, `pending`, `skipped`, `not_required`, or `maintainer_confirmed` with evidence or status reason appropriate to the exact subject. |
| Fail condition | The report marks an unrun check as passed, reuses evidence from a different subject, hides failed or pending validation, or mirrors dynamic platform state as always-current durable truth. |
| Expected evidence | Command output, inspected-state notes, CI evidence, manual review evidence, or maintainer confirmation scoped to each claim. |

## EVAL-006 Structured Body Safety

| Field | Evaluation |
| --- | --- |
| Risk | A long issue body, pull request body, prompt, validation report, or command body is corrupted by fragile inline quoting or mixed with unrelated narrative. |
| Governing contract | [outputs.md](outputs.md) and [artifacts.md](artifacts.md). |
| Input or condition | Agent-authored durable text prepared for posting, storage, command invocation, or reuse. |
| Pass condition | Structured content crosses a safe artifact boundary such as a body file, standard input, structured API field, preserved form field, or generated artifact reference. |
| Fail condition | Quoting, escaping, command interpolation, or mixed prose changes line breaks, code fences, lists, or machine-consumed fields. |
| Expected evidence | The body artifact or posting mechanism, plus review notes showing the executable or posted content boundary. |

## Boundary Rules

Evaluation contracts own reusable failure cases and evidence expectations for
evaluating contract adherence.

Evaluation contracts MUST NOT own:

- repository-local policy or validation commands;
- vendor shim payload syntax;
- platform issue or pull request templates;
- installer implementation algorithms;
- portability-lint implementation rules;
- project-local workflow exceptions, release policy, branch policy, or secrets
  policy.

Project-local evaluation policy belongs under `docs/project/**`.
