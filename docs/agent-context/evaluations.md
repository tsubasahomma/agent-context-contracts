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

### EVAL-007 Stale Source-Precedence Drift

| Field | Requirement |
| --- | --- |
| Risk | A durable artifact, handoff, review, or readiness report treats an older issue body, pull request body, prompt, transcript, snapshot, or prior report as proof that current files, artifacts, validation, or repository state still match. |
| Governing contract | [sources.md](sources.md) current inspected state baseline, collaboration artifact boundary, and conflict resolution by claim type; [workflows.md](workflows.md) worker and evaluator pre-inspection rules. |
| Input or condition | An agent-authored output, handoff, evaluation report, readiness report, or review finding makes a factual claim about files, artifacts, validation, or repository state while citing older collaboration text, a stale snapshot, or prior report. |
| Pass condition | The artifact treats older collaboration records and snapshots as scope or orientation evidence only, re-inspects current direct evidence for factual claims, reports freshness and contradictions, and proceeds only where scope and current evidence remain clear. |
| Fail condition | The artifact says or implies current files, artifacts, validation, or repository state match an older record without current inspected evidence or exact maintainer confirmation for the claim. |
| Expected evidence | Current inspected-state references, observation point or freshness note, contradiction or limitation notes when sources differ, and explicit separation between scope evidence and factual evidence. |

### EVAL-008 Generated Evidence Treated As Current Truth

| Field | Requirement |
| --- | --- |
| Risk | A generated evidence pack, summary, model output, snapshot, or transcript is treated as current direct evidence without source references, freshness, omitted-surface notes, or limitation metadata. |
| Governing contract | [sources.md](sources.md) generated and derived evidence boundary; [evidence-packing.md](evidence-packing.md) non-purpose, minimum metadata, and evidence state rules; [outputs.md](outputs.md) generated evidence-pack summary rules. |
| Input or condition | A worker prompt, evaluator prompt, validation report, readiness report, review finding, change summary, or generated evidence-pack summary relies on generated or packed evidence for a material claim. |
| Pass condition | The output identifies the derived evidence subject, source references, observation point, included and omitted surfaces, freshness, redaction notes, limitations, and intended consumer. Material claims that require current state are backed by fresh direct evidence, scoped maintainer confirmation, or an explicit limitation. |
| Fail condition | The output uses the existence, content, or confidence of generated evidence as proof of current source state, validation status, local policy, or portable doctrine when the required metadata or direct evidence is missing, stale, partial, or contradicted. |
| Expected evidence | Evidence-pack metadata or summary fields, direct inspected-state or validation references for material claims, and limitation notes for stale, partial, redacted, unavailable, generated, or tool-produced evidence. |

### EVAL-009 Change-Proposal Evidence-Packet Drift

| Field | Requirement |
| --- | --- |
| Risk | A change-proposal or pull request body stops being a reviewable evidence packet and becomes vague narrative, unsupported readiness assertion, local template policy, or copied historical convention. |
| Governing contract | [outputs.md](outputs.md) minimum portable expectations, change-proposal body default, and artifact-mixing boundaries; [validation.md](validation.md) success claim rules; [sources.md](sources.md) collaboration artifact boundary. |
| Input or condition | A change-proposal body, pull request body, review packet, or proposed template for such a body. |
| Pass condition | The body states the proposed change, accepted scope, included surfaces, important exclusions, material changes, validation statuses with evidence, residual risks, rollback or mitigation notes when relevant, review notes, out-of-scope findings, and linked evidence or work. It presents portable headings only as defaults and routes exact local fields to project extension or adapter layers. |
| Fail condition | The body omits material scope, evidence, validation status, limitations, or risks; claims readiness without validation evidence; treats body text as proof of current repository state; or encodes local headings, closure syntax, reviewer conventions, or historical defaults as portable requirements. |
| Expected evidence | The body under review, validation claim evidence, inspected diff or artifact references, source and limitation notes, and manual review notes showing local-policy fields remain owned by project extension or adapters. |

### EVAL-010 Dynamic Status Mirroring Drift

| Field | Requirement |
| --- | --- |
| Risk | A static durable output manually mirrors dynamic CI, review, deployment, release, external, or platform status as always-current truth. |
| Governing contract | [outputs.md](outputs.md) static body claim and artifact-mixing boundaries; [validation.md](validation.md) CI evidence and success claim rules; [sources.md](sources.md) factual claim boundary. |
| Input or condition | A change-proposal body, readiness report, validation report, issue body, template, adapter payload, or review note includes status claims about checks, reviews, deployments, releases, external systems, or platform state. |
| Pass condition | Static text records only observed status with an observation point, subject, evidence reference, and limitation, or it points consumers to the authoritative dynamic system without restating the changing status as durable truth. Required validation still uses the portable status vocabulary. |
| Fail condition | Static text says a dynamic status is passing, approved, deployed, released, current, or complete without observed evidence and freshness, or it asks agents to manually keep dynamic platform state synchronized inside durable body text. |
| Expected evidence | Status claim table or prose with subject, status, observation point, evidence reference, limitations, and clear routing to the dynamic source when the static output is only a pointer. |

### EVAL-011 Change-Message Policy Drift

| Field | Requirement |
| --- | --- |
| Risk | A commit, changeset, or version-control message turns project-local issue references, closure syntax, trailers, release fields, merge-message rules, or branch-derived conventions into portable change-message doctrine. |
| Governing contract | [outputs.md](outputs.md) commit or change message default and artifact-mixing boundaries; [sources.md](sources.md) local policy and adapter mapping boundaries. |
| Input or condition | A portable contract, project-extension template, adapter payload, change-message proposal, commit body, or review finding defines or evaluates change-message content. |
| Pass condition | Portable guidance stays limited to reviewable message qualities such as concise subject, useful affected surface, rationale or risk when needed, and no unsupported validation claims. Concrete issue references, closure keywords, trailers, release notes, merge-message policy, scopes, and branch-derived syntax are explicitly local-extension or adapter decisions. |
| Fail condition | Portable guidance requires, forbids, or assumes a concrete tracker syntax, issue-closing phrase, trailer, scope taxonomy, release field, branch naming rule, merge-message convention, or host-specific message behavior without local policy or selected-adapter ownership. |
| Expected evidence | Diff or artifact review showing the message rule under evaluation, source references for any local policy or selected adapter mapping, and manual review notes confirming portable defaults do not encode local conventions. |

### EVAL-012 Output Role Mixing Drift

| Field | Requirement |
| --- | --- |
| Risk | One durable output merges incompatible roles so consumers cannot tell whether it is a proposal, validation report, readiness decision, review finding, command body, evidence summary, prompt, or local policy artifact. |
| Governing contract | [outputs.md](outputs.md) output categories, minimum portable expectations, artifact-mixing boundaries, and validation and readiness outputs; [artifacts.md](artifacts.md) audience and consumer expectations; [workflows.md](workflows.md) readiness reporting. |
| Input or condition | An agent-authored durable text output, template, adapter payload, or evaluation report that combines multiple output roles. |
| Pass condition | The output identifies its primary role and intended consumers. When multiple roles are needed, it separates sections or artifacts, identifies the governing contract for each role, preserves validation statuses and readiness criteria, and avoids assigning implementation scope, review authority, or local policy ownership to the wrong layer. |
| Fail condition | The output blends validation with readiness, review findings with implementation authorization, command text with unrelated narrative, prompts with factual proof, or evidence summaries with direct source evidence in a way that makes claims hard to audit or broadens responsibility silently. |
| Expected evidence | Output artifact under review, role or purpose statement, separated sections or linked artifacts when roles differ, validation/readiness evidence when claimed, and manual review notes for any role boundary risk. |

### EVAL-013 Structured Body Boundary Drift

| Field | Requirement |
| --- | --- |
| Risk | A long or field-sensitive structured body is embedded in fragile inline command construction, copied through an unsafe quoting path, or mixed with narrative that changes what is executed, posted, or stored. |
| Governing contract | [outputs.md](outputs.md) structured body handling and command text boundaries; [artifacts.md](artifacts.md) durable artifact model; [validation.md](validation.md) evidence expectations for command evidence when a command claim is made. |
| Input or condition | A command snippet, command body, issue body, change-proposal body, prompt, report, generated summary, adapter field, or local-policy placeholder is prepared for execution, posting, storage, or reuse. |
| Pass condition | The output uses a safe artifact boundary when line breaks, code fences, lists, structured fields, quoting, escaping, truncation, or interpolation are material. Copyable or executable text is clearly separated from rationale, warnings, validation notes, and rollback notes unless the target command language safely treats those notes as comments. |
| Fail condition | The output places a long structured body inside a fragile inline command, relies on shell or tool quoting that can alter the content, omits the copyable boundary, or includes unrelated narrative inside the body in a way that changes execution or durable storage semantics. |
| Expected evidence | Body file, standard-input record, structured API or adapter field, generated artifact locator, or equivalent safe-boundary reference, plus review notes showing narrative and executable or posted content are distinguishable. |

### EVAL-014 Platform Template Manualization Drift

| Field | Requirement |
| --- | --- |
| Risk | A GitHub or other selected platform template is treated as the durable manual for portable operating rules, local policy, validation proof, or adapter behavior instead of an optional entry point that routes to owning contracts. |
| Governing contract | [sources.md](sources.md) adapter boundary; [outputs.md](outputs.md) change-proposal defaults and adapter-owned fields; [core.md](core.md) core boundary; [artifacts.md](artifacts.md) ownership layer expectations. |
| Input or condition | A platform issue template, pull request template, hosted-agent instruction file, adapter README, adapter payload, or portable contract references a platform-specific template. |
| Pass condition | The template remains generic, optional, and adapter-owned; routes durable rules to the root entry point, portable contracts, and materialized local extension when present; and avoids treating labels, checkboxes, reviewer requests, statuses, milestones, issue-linking syntax, or command interfaces as portable requirements. |
| Fail condition | The template duplicates or replaces portable contracts, invents local facts, becomes required for all consumers, treats platform fields as validation proof, or requires a named hosting platform or template mechanism as a portable baseline. |
| Expected evidence | Template or adapter diff review, local link checks to owning contracts, portability review for generic payload content, and manual notes confirming platform-specific fields remain optional adapter mappings. |

### EVAL-015 Portable Default Local-Fact Leakage

| Field | Requirement |
| --- | --- |
| Risk | Portable defaults, project-extension templates, adapter payloads, or evaluation cases leak branch naming rules, repository identity, host paths, local commands, personal identifiers, concrete issue-number assumptions, labels, reviewers, CI names, release policy, or historical local conventions into reusable doctrine. |
| Governing contract | [core.md](core.md), [sources.md](sources.md) local extension and portable boundary, [outputs.md](outputs.md) output boundary rules, and the root `AGENTS.md` portability boundary. |
| Input or condition | A portable contract change, project-extension template, adapter payload, evaluation case, worker prompt, review report, or change-proposal body introduces output, source, workflow, validation, branch, command, or template defaults. |
| Pass condition | Reusable text uses repository-agnostic placeholders or ownership routing. Local facts are absent from portable files, represented only as explicit placeholders in templates, or confined to the project-local or selected-adapter layer that owns them. Historical evidence is used only as a capability inventory and is not copied as structure, wording, local policy, commands, paths, identifiers, branch rules, or assumptions. |
| Fail condition | Reusable doctrine embeds concrete repository names, personal identifiers, host-absolute paths, local commands, branch prefixes, issue-number patterns, labels, reviewers, CI job names, release gates, copied historical wording, or tool/vendor requirements as defaults for all consumers. |
| Expected evidence | Portability lint output when applicable, targeted leakage searches over changed files, diff review of portable/template/adapter surfaces, and manual review notes for historical-evidence handling and placeholder ownership. |

## Extension Path

Later evaluation work SHOULD add cases only when they remain portable,
reviewable, and evidence-backed. Project-specific gates and datasets belong in
`docs/project/**`. Adapter tests, lint fixtures, and sync fixtures belong with
the relevant adapter or tool implementation.
