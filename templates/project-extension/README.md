# Project Extension Templates

These files are source-package templates for a consumer repository's local
project extension. They help a consumer record local identity, surfaces,
validation expectations, workflow exceptions, and secrets policy while keeping
portable contracts free of local facts.

## Purpose

Use this template set when adopting the portable agent context contracts into a
consumer repository. The materialized project extension is the place for facts
that are true only for that repository, team, product, environment, or operating
process.

Local facts MUST NOT be copied into portable core files under
`docs/agent-context/**`. Portable core files should continue to describe reusable
contracts only.

## Ownership

Files under `templates/project-extension/**` are source-package templates.
Materialized files under `docs/project/**`, or another declared project
extension path, are consumer-owned after creation.

After materialization, project extension files MUST NOT be treated as
package-managed files. Sync or update tooling MAY seed missing files during
initial adoption, but it MUST NOT overwrite existing project extension files or
previously materialized project extension files.

If a consumer uses another project extension path, record that path in the
package metadata or local adoption notes. The alternate path has the same
consumer-owned status as `docs/project/**`.

## Adoption

1. Choose the project extension path, usually `docs/project/`.
2. Copy or seed these template files into that path.
3. Replace bracketed prompts with local information that is safe to record.
4. Leave unknown, pending, omitted, and maintainer-confirmed facts explicit
   instead of guessing.
5. Review the materialized files for local-fact leakage before changing
   portable core files.

Recommended materialized layout:

```text
docs/project/
  README.md
  profile.md
  surfaces.md
  validation.md
  workflows.md
  secrets.md
```

## Local Fact States

Use explicit state markers when a local fact is not a plain confirmed fact:

| State | Use when | Suggested representation |
| --- | --- | --- |
| `unknown` | The fact has not been inspected or confirmed. | `[unknown: describe what is missing and who can clarify]` |
| `pending` | The fact is expected but waiting on evidence, access, or a decision. | `[pending: describe the blocker and expected evidence]` |
| `omitted` | The fact is intentionally not recorded because it is unnecessary, sensitive, or outside scope. | `[omitted: give the reason and safe boundary]` |
| `maintainer_confirmed` | A maintainer explicitly confirmed the fact or exception. | `[maintainer_confirmed: summarize exactly what was confirmed and the evidence pointer]` |

When these states support a validation claim, map them to the portable
validation vocabulary:

- `unknown` and unresolved `pending` facts usually support `pending` claims.
- intentionally omitted checks or facts usually support `skipped` or
  `not_required` claims, depending on whether the item was relevant.
- maintainer-confirmed facts support only the exact scope recorded with
  `maintainer_confirmed`.

## Update Safety

Template updates in the source package do not automatically change a consumer's
materialized project extension. Consumers MAY manually compare new template
versions and copy useful wording, but they retain ownership of the local files.

Do not replace a materialized project extension file just because the source
template changed. Preserve local edits, local policy decisions, and local
validation evidence unless the consumer intentionally revises them.
