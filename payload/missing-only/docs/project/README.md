# Project Extension

This directory is a consumer-owned local policy memory layer for one
repository. It may be seeded from `payload/missing-only/docs/project/**` during
adoption, and it becomes consumer-owned after materialization.

Use it to record reusable repository-local facts, decisions, exceptions, and
evidence pointers that portable contracts cannot own. It is not a human-filled
onboarding form, and adoption does not require humans to complete every starter
file before agents can use the portable contracts.

## Purpose

The materialized project extension helps future agents avoid rediscovering local
policy that is reusable across work items. It may describe local identity,
surfaces, output policy, validation expectations, workflow exceptions, secrets
policy, and durable evidence pointers for the repository that owns it.

Local facts MUST NOT be copied into portable core files under
`docs/agent-context/**`. Portable core files should continue to describe reusable
contracts only.

Project memory is useful for orientation and policy routing, but it does not
itself prove validation. A validation claim still needs evidence that satisfies
the portable validation contract, such as observed command output, inspected
state, CI evidence, manual review evidence, or exact maintainer confirmation.

## Ownership

Files under `payload/missing-only/docs/project/**` are missing-only starter
files. Materialized files under `docs/project/**`, or another declared project
extension path, are consumer-owned after creation.

After materialization, project extension files MUST NOT be treated as
source-owned portable files. Installer refreshes MAY seed missing files, but
they MUST NOT overwrite existing project extension files or previously
materialized project extension files.

If a consumer uses another project extension path, record that path in the
package metadata or local adoption notes. The alternate path has the same
consumer-owned status as `docs/project/**`.

## Local Memory Layers

Use these primary layers when recording reusable local memory:

| Layer | Use when | Authority |
| --- | --- | --- |
| `Observed Case Study` | Concrete repository work revealed a reusable pattern, risk, exception, or example that may inform future work. Record what was observed, the evidence pointer, the outcome, and limits. | Non-authoritative. It is an observation, not local policy. |
| `Pending Local Decision` | A local rule, exception, workflow, or mapping is proposed or appears needed, but authority has not confirmed it. Record the question, candidate decision, evidence, needed owner, and blocker. | Non-authoritative until promoted by an authority source. |
| `Confirmed Local Decision` | A local policy, exception, owner, command, workflow rule, or mapping is confirmed for a bounded scope. Record the exact decision, scope, authority source, evidence pointer, and limits. | Authoritative only for the recorded scope and only when it preserves portable boundaries. |

AI collaborators may observe concrete repository work, summarize reusable case
studies, and place them in the appropriate project-extension file. They may also
record pending proposals. They MUST NOT promote inferred facts, repeated
examples, or their own observations into confirmed local policy by themselves.

## Promotion Authority

A `Confirmed Local Decision` requires one of these authority sources:

- explicit maintainer confirmation for the exact claim and scope;
- a materialized local authority rule that delegates the decision for the
  affected repository and scope;
- another recorded authoritative local evidence pointer whose ownership,
  freshness, and scope are clear.

When authority is absent, record the information as an `Observed Case Study`,
`Pending Local Decision`, `unknown`, `pending`, `omitted`, or `not_required`.
Do not infer confirmation from issue text, pull request text, labels,
checkboxes, project fields, historical examples, successful validation output,
or repeated agent behavior unless an authority source explicitly makes that
surface decisive for the exact claim.

Confirmed decisions MUST name the evidence pointer and limits. A narrow
confirmation MUST NOT be generalized to unrelated paths, future work,
validation status, irreversible publication, or portable core policy.

## Reusable Update Criteria

Update project memory only when the information is reusable. A good entry:

- helps future agents handle recurring repository-specific work;
- belongs to local policy, local facts, local surfaces, or local evidence
  routing rather than portable doctrine;
- is safe to record without secrets, sensitive values, host-private details, or
  unnecessary personal identifiers;
- includes an evidence pointer, confirmation pointer, or explicit uncertainty
  state;
- stays stable beyond the immediate work item, or clearly records why it is only
  a bounded case study;
- fits one of the local files instead of becoming a broad workflow framework.

Do not record transient task notes, one-off planning narration, temporary
investigation prose, stale migration context, outdated compatibility notes,
commented-out instructions, or one-off command output unless a durable local
decision or reusable case study depends on it.

## Adoption And Maintenance

1. Choose the project extension path, usually `docs/project/`.
2. Copy or seed the missing-only starter files that are useful for the
   repository. Leave unused starters absent or sparse when local policy does not
   need them yet.
3. Record safe local facts, observed case studies, pending local decisions, and
   confirmed local decisions in the owning file.
4. Leave `unknown`, `pending`, `omitted`, `not_required`, and
   `maintainer_confirmed` facts explicit instead of guessing.
5. Review materialized files for local-fact leakage before changing portable
   core files.

Recommended materialized layout:

```text
docs/project/
  README.md
  profile.md
  surfaces.md
  output-policy.md
  validation.md
  workflows.md
  secrets.md
```

Recommended files:

| File | Local ownership |
| --- | --- |
| `README.md` | Memory model, materialized layout, state vocabulary, and update-safety reminders. |
| `profile.md` | Local identity, owning roles, decision sources, assumptions, maintainer confirmations, and confirmed identity policy. |
| `surfaces.md` | Local source, artifact, output, entry-point, generated-output, sensitive-surface maps, and reusable case studies about surfaces. |
| `output-policy.md` | Local durable output policy, language choices, references, trailers, safe body handling, and pending output decisions. |
| `validation.md` | Local validation commands, manual checks, CI checks, unavailable-check handling, evidence expectations, and reusable validation case studies. |
| `workflows.md` | Local workflow exceptions, branch policy, review gates, release or rollback routing, handoff additions, and confirmed mutation authority. |
| `secrets.md` | Local secrets and sensitive-data classification, redaction, storage, escalation boundaries, and pending sensitive-data decisions. |

Local policy MAY specialize repository facts after adoption. It MUST NOT
silently replace portable source, output, artifact, workflow, validation,
evidence-packing, ownership, or installer-safety boundaries from
`docs/agent-context/**`.

## Local Fact States

Use explicit state markers when a local fact is not a plain confirmed fact.
These states may appear inside any memory layer:

| State | Use when | Suggested representation |
| --- | --- | --- |
| `unknown` | The fact has not been inspected or confirmed. | `[unknown: describe what is missing and who can clarify]` |
| `pending` | The fact is expected but waiting on evidence, access, or a decision. | `[pending: describe the blocker and expected evidence]` |
| `omitted` | The fact is intentionally not recorded because it is unnecessary, sensitive, or outside scope. | `[omitted: give the reason and safe boundary]` |
| `not_required` | The fact, file, check, field, or mechanism is not needed for the stated local scope. | `[not_required: state the scope and why it is not needed]` |
| `maintainer_confirmed` | A maintainer explicitly confirmed the fact or exception. | `[maintainer_confirmed: summarize exactly what was confirmed and the evidence pointer]` |

When these states support a validation claim, map them to the portable
validation vocabulary:

- `unknown` and unresolved `pending` facts usually support `pending` claims.
- intentionally omitted checks or facts usually support `skipped` or
  `not_required` claims, depending on whether the item was relevant.
- `not_required` facts support only the scoped non-applicability recorded with
  the state.
- `maintainer_confirmed` facts support only the exact scope recorded with
  `maintainer_confirmed`.

Project-memory entries may point to validation evidence, but the entry itself is
not validation evidence unless it records the qualifying evidence and the
validation claim cites that evidence directly.

## Update Safety

Missing-only starter updates in the source package do not automatically change a
consumer's materialized project extension. Consumers MAY manually compare new
starter versions and copy useful wording, but they retain ownership of the local
files.

Do not replace a materialized project extension file just because the
missing-only starter changed. Preserve local edits, local policy decisions, and
local validation evidence unless the consumer intentionally revises them.
