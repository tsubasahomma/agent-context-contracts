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

## EVAL-007 Output Default Template Drift

| Field | Evaluation |
| --- | --- |
| Risk | Portable output defaults become mandatory platform templates, default-installed platform payload, or local workflow doctrine. |
| Governing contract | [outputs.md](outputs.md), [ownership.md](ownership.md), [core.md](core.md), and [sources.md](sources.md). |
| Input or condition | Parent Issue defaults, Child Issue defaults, change-proposal defaults, platform-surface examples, installer payload changes, or proposed template files. |
| Pass condition | Portable output guidance is framed as reusable defaults that apply when no project-local policy or consumer-owned platform surface is more specific. Platform-native issue forms, pull request templates, labels, reviewer assignment, closure syntax, and field mappings remain optional consumer-owned surfaces. |
| Fail condition | A portable contract or default payload requires a platform template, installs platform collaboration surfaces by default, makes local headings or platform fields mandatory for every consumer, or treats a platform-native form as portable core doctrine. |
| Expected evidence | Diff review of portable contracts and payload paths, installer payload inspection, and targeted checks that no default platform issue or pull request template was introduced. |

## EVAL-008 Issue And Proposal Evidence Completeness

| Field | Evaluation |
| --- | --- |
| Risk | Durable issue or change-proposal bodies look complete while omitting material motivation, evidence basis, validation status, scope boundary, risk, rollback, mitigation, or out-of-scope information. |
| Governing contract | [outputs.md](outputs.md), [validation.md](validation.md), [workflows.md](workflows.md), and [artifacts.md](artifacts.md). |
| Input or condition | Parent Issue body, Child Issue body, change-proposal body, pull request body, readiness report, or change summary. |
| Pass condition | When material to the output role, the body states why the work exists, what scope it accepts and excludes, which evidence or inspected state supports material claims, which validation status applies, and what residual risk, rollback, mitigation, or next decision remains. |
| Fail condition | The body substitutes generated boilerplate, unchecked boxes, or unsupported assertions for evidence; omits material motivation or scope boundaries; reports validation as decoration rather than a claim; or hides risk, rollback, mitigation, unavailable evidence, or out-of-scope findings needed for review. |
| Expected evidence | Body review against its output role, validation-claim evidence, inspected-state notes for material claims, and reviewer notes for omissions or non-findings. |

## EVAL-009 Change Message Local Doctrine Drift

| Field | Evaluation |
| --- | --- |
| Risk | Portable commit or change-message guidance hard-requires project-local syntax, tracker references, release-note fields, trailers, Conventional Commits, merge-message policy, branch-derived subjects, or strict numeric line-length gates. |
| Governing contract | [outputs.md](outputs.md), [ownership.md](ownership.md), [sources.md](sources.md), and [validation.md](validation.md). |
| Input or condition | Commit-message guidance, changeset guidance, version-control message examples, release note mapping, merge-message mapping, lint rules, or fixtures. |
| Pass condition | Portable guidance treats concise resulting-change subjects, subject/body separation, and practical line wrapping as reviewability defaults with exceptions. Project-local syntax, tracker references, trailers, Conventional Commits decisions, release-note fields, merge-message rules, branch conventions, and hard validation gates remain local policy or platform-surface concerns. |
| Fail condition | Portable core requires a named commit convention, concrete tracker syntax, issue-closing keywords, local release fields, trailers, merge-message structure, branch-derived subject format, or absolute 50/72 validity gates for all consumers. |
| Expected evidence | Diff review of message guidance and fixtures, portability-lint output when relevant, and manual review that examples do not make local conventions portable doctrine. |

## EVAL-010 Missing-Only Output Policy Starter Drift

| Field | Evaluation |
| --- | --- |
| Risk | A missing-only local output-policy starter leaks concrete local facts, converts placeholders into local policy, or makes local platform fields portable doctrine before a consumer owns them. |
| Governing contract | [outputs.md](outputs.md), [ownership.md](ownership.md), [sources.md](sources.md), and [validation.md](validation.md). |
| Input or condition | `payload/missing-only/docs/project/output-policy.md`, adjacent missing-only local policy starters, vendor shims, or starter examples. |
| Pass condition | Starter text uses placeholders, explicit decision states, and local ownership language. It leaves concrete field names, tracker syntax, platform mappings, release rules, commit conventions, and validation commands unsettled until the consumer records evidence or confirmation in its local context. |
| Fail condition | Starter text names a concrete repository, command, host, reviewer, label, tracker value, platform field, release rule, commit convention, or validation result as if it were already local policy or portable doctrine. |
| Expected evidence | Portability-lint output when applicable, manual review of starter placeholders and decision states, and missing-only boundary inspection showing existing consumer-owned files would not be overwritten. |

## EVAL-011 Durable Repository Process Debris

| Field | Evaluation |
| --- | --- |
| Risk | Durable repository files retain stale process notes, worker narration, migration notes, issue-plan narration, dead comments, obsolete compatibility guidance, or historical scaffolding that no longer helps current consumers. |
| Governing contract | [outputs.md](outputs.md), [workflows.md](workflows.md), [ownership.md](ownership.md), and [validation.md](validation.md). |
| Input or condition | Portable contracts, root documentation, missing-only starters, vendor shims, fixtures, scripts, comments, examples, or proposed durable repository text. |
| Pass condition | Durable repository text describes steady-state behavior for its owning layer. Historical process context stays in issue bodies, change proposals, change messages, validation reports, or other change records unless it is required for current operation. |
| Fail condition | Repository files include temporary migration narration, worker self-reporting, issue execution plans, obsolete compatibility promises, stale selected-entrypoint or lifecycle language, dead comments, dead fixtures, or historical explanations that conflict with the current contract model. |
| Expected evidence | Targeted text searches, diff review of changed durable files, manual review that process context belongs to a change record, and validation notes for any intentionally retained historical reference. |

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
