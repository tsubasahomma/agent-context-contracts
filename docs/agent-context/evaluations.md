# Evaluation Contracts

## Purpose

This document defines portable evaluation cases for checking whether agent
context contracts are followed. Evaluation cases are reviewable pass/fail checks
that apply to durable artifacts, handoffs, validation reports, adapter
boundaries, and sync-safety claims.

## Owns

Evaluation contracts own:

- the expectation that evaluations are stated as reviewable pass/fail checks;
- the boundary between portable evaluation criteria and project-local acceptance
  checks;
- concrete portable evaluation cases covering contract adherence, portability,
  validation claims, adapter boundaries, and sync safety;
- expected evidence for those portable cases.

## Must Not Own

Evaluation contracts MUST NOT own:

- repository-local acceptance criteria or release gates;
- portability-lint implementation details;
- adapter-specific test payloads;
- sync-tool implementation behavior;
- generated evidence packs, project-local datasets, or tool-specific scoring
  rubrics.

## Case Format

Each portable evaluation case MUST state:

- the case name or identifier;
- the risk being tested;
- the governing contract reference;
- the input or condition under review;
- the pass condition;
- the fail condition;
- the expected evidence.

Project-specific acceptance checks should live in `docs/project/**`. Tool,
adapter, sync-tool, or lint implementation tests should live with the relevant
implementation.

## Portable Evaluation Cases

### EVAL-001 Validation Hallucination

| Field | Requirement |
| --- | --- |
| Risk | A report claims validation passed without command output, inspected state, CI evidence, manual review evidence, or maintainer confirmation. |
| Governing contract | [validation.md](validation.md) success claim rules and status vocabulary. |
| Input or condition | A validation report, readiness report, change summary, or PR body claims a required check is complete. |
| Pass condition | Every required success claim is `passed` or `maintainer_confirmed` and cites evidence that covers the exact subject and scope. Missing, unavailable, skipped, or unrun checks are reported as `pending`, `skipped`, or `not_required` with reasons. |
| Fail condition | The artifact says or implies validation passed from expectation, memory, intent, stale evidence, omitted output, or evidence for a different subject. |
| Expected evidence | Validation claim table or prose containing subject references, status, evidence references, evidence summary, limitations, and residual risk. |

### EVAL-002 Local-Fact Leakage

| Field | Requirement |
| --- | --- |
| Risk | Portable files contain repository identity, private identifiers, host-specific assumptions, local commands, secrets, tool-specific baseline assumptions, or legacy-only facts. |
| Governing contract | [core.md](core.md), [artifacts.md](artifacts.md), [validation.md](validation.md), and the root `AGENTS.md` portability boundary. |
| Input or condition | Portable core files, root entry point, adapters, templates, lint fixtures, or proposed contract changes. |
| Pass condition | Portable core and generic entry points contain only repository-agnostic contract content. Project-local facts are absent from portable files or are represented only as clearly synthetic fixtures for negative lint validation. |
| Fail condition | Reusable contract content embeds concrete repository names, personal identifiers, host paths, local service addresses, local commands, secret-like values, copied legacy facts, or unsupported local operational assumptions. |
| Expected evidence | Portability lint output for the default portable surface, text searches over changed files, secret-pattern search results, and manual review notes for any synthetic fixtures. |

### EVAL-003 Adapter/Core Boundary Drift

| Field | Requirement |
| --- | --- |
| Risk | Optional adapter behavior becomes portable-core doctrine, or adapter payloads replace durable portable contracts. |
| Governing contract | [core.md](core.md), [path-ownership-and-sync-safety.md](path-ownership-and-sync-safety.md), [evidence-packing.md](evidence-packing.md), and adapter boundary documentation. |
| Input or condition | Portable contracts, adapter README files, adapter payloads, or proposed cross-links. |
| Pass condition | Portable core may discuss adapter boundaries but does not require a named platform, agent, evidence-packing tool, payload, runtime, or command as a baseline. Adapter payloads route back to portable contracts and remain optional, explicit, and tool-specific. |
| Fail condition | Portable core requires a named adapter, platform, agent, evidence-packing tool, payload file, runtime, or command as universal behavior, or an adapter payload becomes the source of durable operating-contract rules. |
| Expected evidence | Diff review of portable and adapter files, portability lint results for tool-as-baseline patterns, and manual review that allowed adapter-boundary discussion was not treated as a failure. |

### EVAL-004 Context Overpacking

| Field | Requirement |
| --- | --- |
| Risk | A worker or evaluator receives an unbounded planning transcript, broad repository snapshot, generated pack dump, or unrelated history instead of bounded evidence. |
| Governing contract | [workflows.md](workflows.md) handoff rules and [evidence-packing.md](evidence-packing.md) scope boundaries. |
| Input or condition | Worker handoff, evaluator handoff, evidence pack, readiness packet, or review packet. |
| Pass condition | The handoff or pack has a bounded subject, relevant evidence pointers, included and omitted surfaces, freshness, limitations, and role-specific scope. It summarizes necessary decisions without copying broad history. |
| Fail condition | The packet includes broad planning history, unrelated tool output, whole-repository context, or generated evidence merely because it is available, and the recipient cannot tell which evidence supports the active question. |
| Expected evidence | Handoff artifact or evidence-pack metadata showing subject, intended consumer, included surfaces, omitted surfaces, evidence pointers, freshness, and limitations. |

### EVAL-005 Unsafe Sync Overwrite Behavior

| Field | Requirement |
| --- | --- |
| Risk | Sync behavior overwrites consumer-owned or modified files, advances lock state after a refused or failed write, or treats refusal as an error to bypass. |
| Governing contract | [path-ownership-and-sync-safety.md](path-ownership-and-sync-safety.md). |
| Input or condition | Sync design, future sync dry-run output, future sync apply output, or review of sync-related claims. |
| Pass condition | Expected behavior refuses existing unowned root entry points, project extension files, adapter destination files, modified managed files, malformed lock files, and unsupported ownership state. Refusal leaves destination content and lock state unchanged. |
| Fail condition | Expected or implemented behavior overwrites unowned or modified destination files, creates adapter payloads without explicit selection, overwrites project extension files after creation, deletes preserved files by default, or updates the lock file after a refused or failed operation. |
| Expected evidence | Until sync tooling exists, contract review showing the expected pass/fail behavior. After sync tooling exists, dry-run and apply/refusal evidence with path, ownership, checksum, selected-adapter, and lock-state details. Do not claim executable sync validation passed without actual sync evidence. |

### EVAL-006 Context Handoff Dilution

| Field | Requirement |
| --- | --- |
| Risk | A handoff drops accepted scope, out-of-scope boundaries, required validation, known risks, or current evidence pointers, causing the recipient to rely on memory or broaden scope silently. |
| Governing contract | [workflows.md](workflows.md) worker and evaluator handoff contracts. |
| Input or condition | Worker handoff, evaluator handoff, orchestration note, or readiness packet. |
| Pass condition | Worker handoffs include active work item, parent scope, accepted scope, in-scope references, out-of-scope boundaries, evidence pointers, required validation, known risks, and deliverables. Evaluator handoffs include the artifact or change under review, relevant state references, acceptance criteria, validation evidence, known risks or disputed assumptions, and the exact evaluation question. |
| Fail condition | The handoff says only to continue from prior discussion, omits material boundaries or validation expectations, loses known risks, fails to identify the artifact under review, or treats handoff text as factual proof of current source state. |
| Expected evidence | Handoff artifact or orchestration note containing the required fields, plus recipient report showing current evidence was re-inspected before editing, reviewing, or claiming readiness. |

## Extension Path

Later evaluation work SHOULD add cases only when they remain portable,
reviewable, and evidence-backed. Project-specific gates and datasets belong in
`docs/project/**`. Adapter tests, lint fixtures, and sync fixtures belong with
the relevant adapter or tool implementation.
