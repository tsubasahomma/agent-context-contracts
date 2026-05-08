# Agent-Authored Output Contracts

This document defines portable expectations for durable text outputs that agents
author or update during collaboration.

Output rules describe how to make durable text reviewable, evidence-backed, and
safe to route across roles. They do not define project-local headings, branch
rules, issue-reference policy, trailers, release notes, merge-message policy,
command conventions, platform templates, or selected entrypoint or surface
payload syntax.

## Terms

- **Agent-authored output**: durable text created or updated by an agent for a
  collaboration, review, implementation, validation, or evidence-routing
  purpose.
- **Output role**: the job an output is meant to perform, such as proposing a
  change, recording validation, transferring worker scope, or reporting a review
  finding.
- **Structured body**: long or field-sensitive text whose line breaks, headings,
  lists, code blocks, or machine-consumed fields are material to correct use.
- **Safe artifact boundary**: a body file, standard input stream, structured API
  field, selected surface-owned field, or equivalent mechanism that preserves a
  structured body without fragile inline quoting or command construction.
- **Static body claim**: a durable claim recorded in text at a specific
  observation point. It may become stale when repository state, validation
  results, review status, or external state changes.

## Output Categories

Agent-authored output categories include, but are not limited to:

| Output category | Portable purpose | Primary consumers |
| --- | --- | --- |
| Change summary | Summarizes what changed, why it changed, and what evidence supports the summary. | Maintainers, reviewers, later agents, release or readiness consumers. |
| Change-proposal or pull request body | Presents a reviewable evidence packet for a proposed change without becoming platform doctrine. | Reviewers, maintainers, orchestrators, selected collaboration surfaces. |
| Commit or version-control change message | Names a source change concisely and, when useful, records rationale, risk, or validation context. | Maintainers, reviewers, history readers, release tooling. |
| Issue body | Defines a durable work item, defect, proposal, acceptance criteria, or evidence request. | Maintainers, planners, orchestrators, workers, evaluators. |
| Worker prompt | Transfers bounded implementation scope, evidence pointers, constraints, validation expectations, and deliverables. | Worker Threads or equivalent implementation roles. |
| Evaluator prompt | Transfers the exact review question, artifact under review, criteria, validation evidence, and known risks. | Evaluator Threads or equivalent review roles. |
| Review finding | Reports a defect, risk, unsupported claim, missing validation, or non-finding against explicit evidence and criteria. | Authors, reviewers, maintainers, orchestrators. |
| Validation report | Records validation claims with the portable status vocabulary and evidence references. | Maintainers, reviewers, workers, evaluators, release or readiness consumers. |
| Readiness report | Summarizes deliverables, validation claims, residual risks, out-of-scope findings, and next-decision readiness. | Orchestrators, maintainers, reviewers, next-role recipients. |
| Command snippet or command body | Provides command text, invocation intent, or a reusable body for a tool or shell-like interface. | Operators, agents, selected entrypoint or surface layers, automation or tooling consumers. |
| Generated evidence-pack summary | Summarizes generated or packed evidence while preserving source, freshness, omission, and limitation metadata. | Workers, evaluators, reviewers, maintainers, evidence consumers. |

These categories may be materialized as files, comments, messages, form fields,
reports, commit metadata, selected entrypoint or surface payloads, or other
durable records. The artifact's ownership layer determines whether the output
belongs to portable core, project-local extension, selected entrypoint, selected
surface, validation, evidence-packing, workflow, or another layer under
[artifacts.md](artifacts.md).

## Minimum Portable Expectations

An agent-authored output MUST make its role clear enough that later consumers do
not need to infer whether it is a proposal, validation claim, review finding,
handoff, command body, or readiness decision.

When material to the output role, durable text outputs MUST state:

- purpose or output role;
- scope and out-of-scope boundaries;
- intended consumer or consumer class;
- evidence basis, inspected-state basis, or source pointers;
- validation status using [validation.md](validation.md) when validation is
  claimed, missing, `skipped`, `pending`, `failed`, `not_required`, or
  `maintainer_confirmed`;
- limitations, uncertainty, unavailable evidence, and residual risks;
- freshness or observation point for claims that may become stale;
- next action or requested decision when the output asks a consumer to act.

An output MAY satisfy these expectations through headings, prose, structured
fields, an adjacent manifest, or the owning artifact contract. Human-readable
outputs SHOULD stay concise enough for review while preserving the evidence
needed to audit material claims later.

An output MUST NOT claim current repository state, validation success, review
state, or external state unless the claim is backed by current inspected
evidence, observed validation evidence, exact maintainer confirmation, or a
clearly stated limitation. Source-class boundaries are defined in
[sources.md](sources.md).

## Artifact-Mixing Boundaries

Each durable output SHOULD perform one primary role. It MAY reference related
artifacts, but it MUST NOT merge incompatible roles in a way that makes claims
hard to audit or assigns responsibility to the wrong layer.

| Mixing risk | Required boundary |
| --- | --- |
| Static change-proposal body claims and dynamic CI, review, deployment, or external state. | Record only observed static evidence and freshness. Do not manually mirror changing status as durable truth unless the output states the observation point and limitation. Dynamic status belongs to the platform, validation report, or current inspected evidence. |
| Commit subjects and issue-closing, tracker, or release policy. | Keep the portable commit subject focused on the change. Issue references, closure keywords, release links, trailers, and merge-message policy belong to project extension or selected collaboration surfaces. |
| Command text and unrelated narrative. | Keep command snippets or command bodies separate from explanatory prose when copying or execution is expected. Put rationale, warnings, and validation notes outside the command boundary. |
| Review findings and implementation scope. | A finding reports evidence, severity, impact, and suggested direction. It does not authorize unrelated implementation changes or broaden accepted scope. |
| Validation reports and unsupported readiness claims. | A validation report records claim statuses and evidence. Readiness requires the workflow readiness criteria in [workflows.md](workflows.md) and MUST disclose failed, pending, skipped, and residual-risk claims. |
| Issue bodies and proof of current repository state. | Issue text may define scope, acceptance criteria, and evidence pointers. It is not proof that current files, checks, or artifacts still match without current inspected evidence. |
| Worker or evaluator prompts and durable source facts. | Prompts transfer role scope and evidence pointers. Recipients still re-inspect current evidence required by [workflows.md](workflows.md). |
| Generated evidence-pack summaries and direct evidence. | A generated summary may support orientation, but it remains derived evidence under [evidence-packing.md](evidence-packing.md) until source, freshness, omissions, and limitations are explicit. |

When an output needs multiple roles, it SHOULD separate them into distinct
sections or artifacts and identify which contract governs each role.

## Structured Body Handling

Long structured bodies SHOULD pass through a safe artifact boundary when inline
command construction, quoting, escaping, truncation, or field interpolation would
make the output fragile.

Safe boundaries MAY include:

- a body file whose contents are supplied to the relevant operation;
- standard input or another stream that preserves the body exactly;
- a structured API field, form field, or selected surface-owned field;
- a generated artifact referenced by stable locator;
- another project-approved mechanism that preserves line breaks, code fences,
  lists, and structured fields.

Long issue bodies, change-proposal bodies, commit bodies, worker prompts,
evaluator prompts, validation reports, command bodies, generated evidence-pack
summaries, or similar structured text MUST NOT be embedded in a fragile inline
command when quoting or shell interpretation could change the content.

Command snippets and command bodies MUST make the executable or copyable boundary
clear. Explanatory text, warnings, expected output, validation status, and
rollback notes SHOULD be outside the command body unless the command language
itself treats them as comments and the target consumer expects them there.

Portable core does not require a specific command interface, shell, API, or
hosting platform. Concrete local command conventions and selected entrypoint or
surface mechanisms belong to `docs/project/**` or the relevant entrypoint or
surface layer.

## Change-Proposal Body Default

A change-proposal or pull request body SHOULD be a reviewable evidence packet.
The following shape is a portable default, not a mandatory universal template:

- `Summary`: concise statement of the proposed change and reviewer-relevant
  effect.
- `Scope`: the accepted work item, included surfaces, and important exclusions.
- `Changes`: the material implementation, documentation, artifact, or policy
  changes.
- `Validation`: validation claims using `passed`, `failed`, `pending`,
  `skipped`, `not_required`, or `maintainer_confirmed` with evidence summaries.
- `Risks`: residual risks, uncertainty, missing evidence, and affected
  consumers.
- `Rollback`: safe reversal, fallback, or mitigation notes when relevant.
- `Review Notes`: reviewer attention points, assumptions, non-obvious decisions,
  or comparison notes.
- `Out of Scope`: adjacent findings or deferred work that the change does not
  implement.
- `Linked Work`: related work items, handoffs, reports, or evidence pointers.

Exact headings, required local fields, closure syntax, labels, checkboxes,
reviewer assignment conventions, release-note fields, and platform template
mapping belong to project extension or selected collaboration surfaces.

A static change-proposal body MUST report only validation the producer actually
ran, inspected, or had exactly confirmed. It MUST NOT mirror changing CI or
review status as if the body were an always-current source of truth.

## Commit Or Change Message Default

An agent-authored commit or version-control change message SHOULD make the
change understandable in history without importing project-local convention into
portable core.

The portable default is:

- a concise imperative subject;
- an optional scope or affected surface when it improves reviewability;
- a body only when rationale, risk, migration, validation, or behavioral nuance
  is not obvious from the diff;
- no portable issue-closing, tracker-reference, release-note, or branch-derived
  syntax;
- no unsupported validation claims;
- no generated boilerplate that obscures the actual change.

Project extension or selected collaboration surfaces MAY define concrete
conventions such as subject format, allowed scopes, issue references, closure
keywords, co-author trailers, signed-off-by trailers, squash or merge-message
policy, release-note policy, and branch-derived message rules.

## Prompt Outputs

Worker prompts and evaluator prompts are durable collaboration artifacts. They
MUST preserve role boundaries from [workflows.md](workflows.md) and source
boundaries from [sources.md](sources.md).

A worker prompt SHOULD identify accepted scope, out-of-scope boundaries,
evidence pointers, required validation, known risks, and deliverables. It MUST
NOT require the worker to trust stale issue text, conversation memory, generated
summaries, or prior command output as current factual proof.

An evaluator prompt SHOULD identify the artifact or change under review,
relevant state references, acceptance criteria, validation evidence, known risks,
and the exact evaluation question. It MUST NOT convert evaluation into
implementation scope unless the role is explicitly reassigned.

## Review Findings

A review finding MUST be tied to evidence and criteria. It SHOULD state:

- the affected artifact, source state, output, or claim;
- the observed problem or non-finding;
- severity, impact, or affected consumer when relevant;
- the evidence reference or inspected-state basis;
- the contract, acceptance criterion, or expectation being applied;
- suggested next action when useful.

A review finding MUST NOT present speculation as fact. If evidence is missing or
uncertain, the finding SHOULD state the limitation or use the appropriate
validation status when the finding concerns validation.

## Validation And Readiness Outputs

A validation report MUST use the claim model and status vocabulary in
[validation.md](validation.md). This output contract may define how validation
text is separated from other roles, but it does not redefine validation statuses.

A readiness report MUST satisfy the workflow readiness requirements in
[workflows.md](workflows.md). It MAY reference a validation report, change
summary, review finding, or evidence-pack summary, but it MUST NOT claim
readiness from unsupported validation or omitted residual risks.

## Generated Evidence-Pack Summaries

A generated evidence-pack summary is derived evidence. It MUST preserve the
evidence-pack subject, source references, observation point, included and omitted
surfaces, redaction notes, freshness, limitations, and intended consumer required
by [evidence-packing.md](evidence-packing.md).

A generated summary MUST NOT replace direct source inspection, validation
evidence, or maintainer confirmation when the active claim requires those
sources. If the summary is partial, stale, redacted, unavailable, or generated
from incomplete inputs, the output MUST say so.

## Boundary Rules

Agent-authored output contracts own:

- durable text output categories and output-role boundaries;
- minimum portable expectations for purpose, scope, consumer, evidence basis,
  validation status, limitations, and freshness;
- artifact-mixing boundaries for durable text outputs;
- safe structured-body handling for long text;
- portable default expectations for reviewable change-proposal bodies;
- portable default expectations for commit or change messages;
- output-specific routing to artifact, workflow, validation, evidence-packing,
  and source-precedence contracts.

Agent-authored output contracts MUST NOT own:

- durable artifact metadata fields beyond output-specific expectations;
- detailed validation status semantics or project-local validation commands;
- workflow role responsibilities beyond prompt and report output boundaries;
- evidence-packing tool behavior or generated pack formats;
- concrete issue templates, pull request templates, commit conventions, branch
  naming, issue-reference policy, trailers, merge-message policy, release-note
  policy, command conventions, labels, or review gates;
- selected entrypoint or surface payload syntax, platform-specific fields, or
  runtime behavior;
- project-local identity, local source maps, host paths, commands, secrets
  policy details, or operational facts;
- sync-tool behavior, lock-file schemas, portability-lint implementation, or
  evaluation fixtures.

## Extension Path

Later output work SHOULD extend this file when adding portable output
categories, output-role boundaries, safe body handling, or durable text defaults.
Artifact metadata should remain in [artifacts.md](artifacts.md), source
precedence in [sources.md](sources.md), workflow roles and readiness in
[workflows.md](workflows.md), validation statuses in
[validation.md](validation.md), evidence packing in
[evidence-packing.md](evidence-packing.md), selected entrypoints and surfaces in
their source-owned layers, and local output policy under `docs/project/**` or
the configured local extension path.
