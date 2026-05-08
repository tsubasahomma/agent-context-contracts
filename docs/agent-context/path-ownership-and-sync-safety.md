# Path Ownership And Sync Safety Contract

This document defines the v0.3 lifecycle, path ownership, lock metadata, and
sync-safety contract for a portable agent context package.

v0.3 is a curl-first adoption and update model. It is not a heavy local package
manager and it is not a semantic merge engine. It MUST make conservative
file-level decisions from explicit ownership state, selected optional groups,
source resolution evidence, lock metadata, and destination checksums.

## Terms

- **Source package**: the reusable package tree that provides portable
  contracts, source-owned optional content, project scaffolds, and
  source-package tooling.
- **Source channel**: the mutable source selector requested by a consumer or
  maintainer, such as a branch, tag, release channel, or local-development
  selector.
- **Resolved source commit**: the immutable full commit SHA resolved from the
  source channel for an apply-mode operation.
- **Dirty source**: a source package checkout or source material whose resolved
  commit does not fully describe the bytes being applied.
- **Consumer repository**: the destination repository where package-managed
  files and consumer-owned local context are materialized.
- **Single source of truth (SSOT)**: the resolved source package revision used
  to create, update, or delete package-managed content.
- **Managed file**: a destination file recorded in `agent-context.lock.json`
  with an ownership kind, selected group when applicable, source path, and
  checksum state.
- **Unowned file**: an existing destination file that is not recorded as
  managed in `agent-context.lock.json`.
- **Portable core**: `AGENTS.md` plus `docs/agent-context/**`.
- **Selected entrypoint**: a thin routing payload selected from
  `entrypoints/<name>/**` and installed at a tool- or platform-specific
  destination path.
- **Selected collaboration surface**: a platform-native work, proposal, review,
  validation, or collaboration form selected from `surfaces/<name>/**`.
- **Detached surface**: a formerly package-managed collaboration surface that a
  consumer has explicitly made consumer-owned.
- **Project scaffold**: source-owned starter content under
  `scaffolds/project/**` that may materialize missing consumer-owned files
  under `docs/project/**` during initial adoption.
- **Project extension**: consumer-owned local context under `docs/project/**`.
- **Sync metadata**: root `agent-context.lock.json`, owned by sync tooling.
- **Source-package tooling**: tooling used to perform distribution, lint,
  diagnostics, or sync. Source-package tooling is not part of the default
  consumer managed payload.

## Public Lifecycle

The target public lifecycle is:

```sh
agent-context init
agent-context sync
```

The invocation mechanism may be a curl-fetched script, a local wrapper, or an
equivalent distribution entry point. The portable contract owns the lifecycle
semantics, not a concrete transport command.

`init` performs initial adoption. It MAY create package-managed portable core,
MAY install selected entrypoints and selected collaboration surfaces, MAY seed
missing project scaffold files into `docs/project/**`, and MUST create
`agent-context.lock.json` only after a successful apply-mode operation.

`sync` updates package-managed content from the SSOT. It MUST update portable
core, lock-selected entrypoints, and lock-selected collaboration surfaces when
checksum-safe. It MUST delete clean package-managed files removed from the
resolved source. It MUST preserve consumer-owned project files and detached
surfaces.

Dry-run is the default mode. A dry-run MUST report planned creates, updates,
deletions, skips, refusals, scaffold materializations, detach effects, and lock
changes without writing to the consumer repository.

Apply mode is required for writes. Writes require an explicit `--apply` or an
equivalent unambiguous apply signal. Apply mode MUST perform the same safety
checks as dry-run before changing files.

## Ownership Categories

| Category | Source path | Destination path | Owner after materialization | Sync responsibility |
| --- | --- | --- | --- | --- |
| Portable core | `AGENTS.md`, `docs/agent-context/**` | Same path | Source package | Package-managed. MAY create, update, or delete only when lock and checksum evidence permits. |
| Optional entrypoint | `entrypoints/<name>/**` | Tool- or platform-specific routing path | Source package when selected and lock-recorded | Package-managed only when selected. MAY create, update, or delete selected managed files when checksum-safe. |
| Optional collaboration surface | `surfaces/<name>/**` | Platform-native template, form, or collaboration path | Source package when selected and lock-recorded | Package-managed until explicitly detached. MAY create, update, or delete selected managed files when checksum-safe. |
| Detached collaboration surface | No active source ownership | Previously materialized platform-native path | Consumer repository | MUST NOT update or delete. MAY be recorded as detached metadata for diagnostics, but MUST NOT remain in `managed_files[]`. |
| Project scaffold | `scaffolds/project/**` | `docs/project/**` | Consumer repository after creation | MAY create missing files during `init` when scaffold seeding is requested. MUST NOT update, overwrite, delete, or manage after creation. |
| Sync metadata | None | `agent-context.lock.json` | Sync tooling | MUST be created or updated only after a successful apply-mode operation. MUST be refused when malformed, unsupported, symlinked, or inconsistent. |
| Source-package tooling | `tools/**` or equivalent source-only tooling paths | Not installed by default | Source package | MUST NOT be part of the default consumer managed payload. A future explicit opt-in tool-install mode would need its own ownership contract. |
| Unowned destination file | None | Any destination path not recorded as managed | Consumer repository or unknown | MUST be preserved. Sync MUST refuse conflicting overwrites or deletions. |

## Path Ownership Matrix

| Path | Source-package meaning | Consumer-repository destination meaning | v0.3 behavior |
| --- | --- | --- | --- |
| `AGENTS.md` | Portable root routing entry point. | Package-managed portable core when tracked; otherwise unowned pre-existing root entry point. | `init` MAY create when missing. `init` and `sync` MAY update only when tracked and checksum-safe. Existing unowned collisions MUST be refused. Clean source removal MUST delete only when tracked and checksum-safe. |
| `docs/agent-context/**` | Portable contract documentation. | Package-managed portable core when tracked. | MAY create, update, or delete only when tracked or being newly adopted safely. Existing unowned collisions and dirty managed files MUST be refused. |
| `entrypoints/<name>/**` | Source-owned thin routing payload for a selected tool or platform entry point. | SHOULD NOT be installed at this source path as ordinary consumer content. Payload files map to declared destination paths only when selected. | Unselected entrypoints MUST NOT affect the consumer repository. Selected entrypoint destination files are package-managed only when recorded in the lock. |
| Entrypoint destination files | Declared by selected entrypoint mapping. | Thin routing files that point agents back to portable contracts and local extensions. | MAY create or update only when selected, lock-recorded, and checksum-safe. MUST refuse unowned collisions and dirty managed files. Clean source removal MUST delete when checksum-safe. |
| `surfaces/<name>/**` | Source-owned platform-native collaboration surfaces. | SHOULD NOT be installed at this source path as ordinary consumer content. Payload files map to declared destination paths only when selected. | Unselected surfaces MUST NOT affect the consumer repository. Selected surface destination files are package-managed until detached. |
| Surface destination files | Declared by selected collaboration surface mapping. | Platform-native templates, forms, or collaboration records used for work, proposal, review, or validation routing. | MAY remain common SSOT content. MAY create or update only when selected, lock-recorded, and checksum-safe. Clean source removal MUST delete when checksum-safe unless the surface has been detached. |
| `scaffolds/project/**` | Source-owned starter content for local project context. | No managed destination at this source path. | MAY be read during `init` to create missing `docs/project/**` files. MUST NOT be installed as a managed tree by default. |
| `docs/project/**` | No package-managed portable content. | Consumer-owned project extension. | MAY be materialized from project scaffolds only when missing during initial adoption. Sync MUST never overwrite, update, delete, or list these files in `managed_files[]`. |
| `agent-context.lock.json` | No portable contract content. | Visible root sync metadata. | MUST NOT be symlinked. MUST be created or updated only after successful apply. Unsupported, malformed, symlinked, or inconsistent locks MUST refuse apply-mode writes. |
| Source-package tooling paths | Distribution, sync, lint, diagnostics, or development tooling. | Not default consumer managed payload. | MUST NOT be copied or tracked by default. A future explicit opt-in tool-install mode MUST define how those files are selected, owned, updated, and removed. |
| Legacy source paths from earlier package versions | Historical or transitional source-package structure. | Not active v0.3 taxonomy. | Earlier `templates/project-extension/**` content is superseded by `scaffolds/project/**`. Earlier `adapters/**` content must be split into entrypoints, surfaces, and any remaining tool-specific source areas rather than preserved as v0.3 doctrine. |

## Path Normalization

Sync decisions and lock-file matching MUST use normalized repository-relative
paths:

- Paths MUST use `/` as the separator.
- Paths MUST be relative to the consumer repository root.
- Paths MUST NOT be absolute.
- Paths MUST NOT contain empty segments, `.` segments, or `..` segments after
  normalization.
- A leading `./` MUST be removed.
- Directory paths MUST NOT use a trailing slash in lock entries.
- Matching MUST be case-sensitive and MUST preserve the path spelling recorded
  in the lock file.
- Checksums MUST be computed from file bytes at the normalized path. Line-ending
  conversion, text decoding, or semantic normalization MUST NOT change checksum
  input.

## Source Resolution

Apply mode MUST use a resolved, clean source package.

Before apply-mode writes, sync MUST resolve the requested source channel to a
full commit SHA and MUST record both the mutable channel and immutable resolved
commit in `agent-context.lock.json`.

Apply mode MUST refuse when:

- the source channel cannot be resolved to a full commit SHA;
- the source package is dirty or otherwise not fully represented by the
  resolved commit;
- the source bytes being applied cannot be associated with the resolved commit;
- the lock records a source state that conflicts with the requested operation.

An explicit local-development mode MAY allow applying from local dirty or
unresolved source only when the mode is unmistakable, reported in dry-run and
apply output, and represented in sync metadata so consumers do not mistake it
for reproducible SSOT state. The normal v0.3 lifecycle MUST refuse dirty or
unresolved source.

Official or vendor documentation and research may support lifecycle and routing
design decisions. They MUST NOT be copied into portable doctrine as universal
tool behavior, source ownership, or local policy.

## Sync Decision Table

| Scenario | Safe v0.3 decision |
| --- | --- |
| `init` with no lock and no destination collision | Dry-run reports planned portable-core creates, selected optional creates, requested scaffold materializations, and lock creation. Apply creates those files and writes the lock only after all writes succeed. |
| `init` with existing destination collision | Treat existing files as unowned unless an explicit future adoption workflow proves otherwise. MUST refuse conflicting overwrites for portable core, selected entrypoint destinations, selected surface destinations, `docs/project/**`, and lock metadata. |
| `sync` with matching managed-file checksums | MAY update tracked package-managed files when current destination checksum matches the lock guard checksum and source target checksum is known. MUST record the new checksum after successful apply. |
| `sync` with dirty managed files | MUST refuse apply-mode writes for the operation before changing files. SHOULD report expected and current checksum evidence for affected paths. |
| Clean package-managed source removal | MUST report planned deletion in dry-run. Apply MUST delete the tracked destination file when the current checksum matches the lock guard checksum and the resolved source no longer contains that managed source path. The lock MUST remove or update the entry only after deletion succeeds. |
| Dirty package-managed source removal | MUST refuse deletion and leave destination content and lock state unchanged. |
| Existing unowned root `AGENTS.md` | MUST preserve and refuse overwrite. SHOULD report that manual adoption or an explicit future recovery workflow is required. |
| Existing unowned entrypoint or surface destination | MUST preserve and refuse overwrite, even when the entrypoint or surface is selected. The destination MAY become managed only through an explicit future adoption workflow that verifies ownership intent. |
| Existing or previously materialized `docs/project/**` | MUST preserve. MUST NOT overwrite, update, delete, or list as managed, even if content resembles a scaffold. |
| Selected entrypoint install | MAY create missing entrypoint destination files and MAY update tracked files when selected, lock-recorded, and checksum-safe. MUST record the selected entrypoint in lock metadata. |
| Unselected entrypoint | MUST NOT create, update, delete, or record destination files. Existing managed files for a previously selected entrypoint require an explicit deselect, detach, or removal rule before sync changes ownership. |
| Selected collaboration surface install | MAY create missing surface destination files and MAY update tracked files when selected, lock-recorded, and checksum-safe. MUST record the selected surface in lock metadata. |
| Detached collaboration surface | MUST NOT remain in `managed_files[]`. Sync MUST preserve the destination path and MUST NOT reattach or overwrite it without explicit adoption. |
| Unselected collaboration surface | MUST NOT create, update, delete, or record destination files. |
| Project scaffold materialization | MAY create missing `docs/project/**` files during `init` when requested. MUST NOT manage those files after creation. Future scaffold changes MAY be shown as advisory diffs but MUST NOT be automatically merged. |
| Missing lock after prior adoption is suspected | MUST treat destination files as unowned unless ownership is re-established by an explicit future recovery workflow. |
| Symlinked lock file | MUST refuse apply-mode writes. MUST NOT replace the symlink. |
| Unreadable, malformed, or unsupported lock file | MUST refuse apply-mode writes. SHOULD report the lock-file error and leave destination files unchanged. |
| Inconsistent lock file state | MUST refuse apply-mode writes when recorded checksums, ownership kinds, selected groups, source paths, normalized paths, duplicate entries, project-extension paths, or source metadata conflict with current evidence. |
| Partial write failure | MUST leave destination content and lock state recoverable through atomic apply, staged writes, rollback, or explicit recovery behavior validated by executable evidence. Merely leaving the old lock file in place after partial writes is not sufficient protection. |

## Managed Update And Deletion Preconditions

A package-managed portable-core, selected-entrypoint, or selected-surface file
MAY be updated or deleted only when all of the following are true:

1. The path is present in `managed_files[]`.
2. The normalized destination path matches the lock entry path.
3. The lock entry ownership is supported by the v0.3 schema.
4. The current destination checksum matches the lock entry guard checksum.
5. The source channel has been resolved to a full commit SHA.
6. The source package is clean unless an explicit local-development mode is
   active and recorded.
7. The source target checksum is known for updates, or the source path is absent
   from the resolved source for deletion.
8. For entrypoint and surface files, the relevant selected group is recorded in
   the lock and has not been detached.

If any condition is false, sync MUST skip or refuse according to the decision
table. It MUST NOT attempt to merge user edits into managed files.

## Project Scaffold Preservation

`docs/project/**` is consumer-owned. `init` MAY create missing project extension
files from `scaffolds/project/**` only when scaffold materialization is
requested and the destination path is missing.

Once created, project extension files MUST NOT be package-managed portable
files, selected entrypoint files, selected surface files, or sync metadata. Sync
MUST NOT overwrite or delete them. The lock MAY record
`project_extension_path` so tooling can find the local extension. That record is
a pointer, not ownership over files below that path.

Future changes to `scaffolds/project/**` MAY be reported as advisory diffs
against local files when a tool supports that diagnostic. Advisory scaffold
diffs MUST NOT be applied automatically by `sync`.

## Entrypoints And Collaboration Surfaces

Entrypoints and collaboration surfaces are separate ownership classes.

Entrypoints are thin routing files. Their job is to help a selected tool or
platform find the root entry point, portable contract index, and materialized
project extension. Entrypoints MUST NOT become the durable source of portable
doctrine or local facts.

Collaboration surfaces are platform-native templates, forms, or similar durable
work surfaces. They may contain common SSOT content derived from portable
contracts. When selected and lock-recorded, they are package-managed by default
and are updated by `sync` when checksum-safe. If a consumer needs local workflow
rules in a surface, the surface MUST be explicitly detached or handled by a
documented manual workflow before local ownership is assumed.

The presence of optional source content MUST NOT install anything by itself.
Selection and lock metadata are required for package-managed optional content.

## Sync Tooling Boundary

Source-package tooling is distribution machinery. It is not ordinary consumer
content.

`init` and `sync` MUST NOT install source-package tooling as default
package-managed payload. Tooling paths MUST NOT appear in `managed_files[]`
unless a future explicit opt-in tool-install contract defines the selection,
ownership kind, checksum behavior, update behavior, and removal behavior.

## Lock-File Ownership Model

`agent-context.lock.json` is sync-tool-managed metadata at the consumer
repository root. Consumers MAY inspect it, but manual edits make the next sync
operation responsible for validating consistency before any apply-mode writes.

The minimal v0.3 model is:

```json
{
  "schema_version": "0.3",
  "source": {
    "repository": "package-source-id",
    "channel": "source-channel",
    "resolved_commit": "0123456789abcdef0123456789abcdef01234567"
  },
  "project_extension_path": "docs/project",
  "selected_entrypoints": [
    {
      "name": "entrypoint-name",
      "source_path": "entrypoints/entrypoint-name"
    }
  ],
  "selected_surfaces": [
    {
      "name": "surface-name",
      "source_path": "surfaces/surface-name",
      "detached": false
    }
  ],
  "managed_files": [
    {
      "path": "docs/agent-context/README.md",
      "source_path": "docs/agent-context/README.md",
      "ownership": "package-managed",
      "group": {
        "kind": "portable-core",
        "name": null
      },
      "checksum": {
        "algorithm": "sha256",
        "previous": "sha256:previous-file-digest",
        "target": "sha256:target-file-digest"
      }
    },
    {
      "path": "tool-or-platform/path",
      "source_path": "entrypoints/entrypoint-name/path",
      "ownership": "package-managed",
      "group": {
        "kind": "entrypoint",
        "name": "entrypoint-name"
      },
      "checksum": {
        "algorithm": "sha256",
        "previous": "sha256:previous-file-digest",
        "target": "sha256:target-file-digest"
      }
    }
  ],
  "created_by": {
    "tool": "agent-context",
    "version": "0.3"
  }
}
```

Field responsibilities:

| Field | Responsibility |
| --- | --- |
| `schema_version` | Defines the lock-file schema. Unsupported versions MUST cause apply-mode refusal. |
| `source.repository` | Identifies the source package origin at the level needed for audit without adding consumer-local facts to portable contracts. |
| `source.channel` | Records the mutable channel requested for the operation. |
| `source.resolved_commit` | Records the immutable full commit SHA actually applied. Missing, abbreviated, unresolved, or conflicting commits MUST cause apply-mode refusal. |
| `project_extension_path` | Points to the consumer-owned project extension root. It MUST NOT imply package ownership of files below that path. |
| `selected_entrypoints[]` | Records explicitly selected optional entrypoints. It MUST NOT include unselected source content. |
| `selected_surfaces[]` | Records explicitly selected collaboration surfaces and detach state when represented by the lock. Detached surfaces MUST NOT remain in `managed_files[]`. |
| `managed_files[]` | Lists only files owned by package sync. Consumer-owned project extension files, detached surfaces, unowned files, and default source-package tooling MUST NOT be listed. |
| Managed file `path` | Stores the normalized consumer-repository destination path used for checksum matching. |
| Managed file `source_path` | Stores the normalized source-package path used to compute the target checksum or source-removal decision. |
| Managed file `ownership` | Identifies package-managed ownership. Unknown ownership values MUST cause refusal for the affected operation. |
| Managed file `group.kind` | Distinguishes `portable-core`, `entrypoint`, and `surface` managed files. Unknown group kinds MUST cause refusal. |
| Managed file `group.name` | Names the selected entrypoint or surface for optional managed files. It MUST be null or absent for portable core. |
| Checksum `algorithm` | Names the digest algorithm. v0.3 SHOULD use `sha256`. Unsupported algorithms MUST cause refusal for the affected operation. |
| Checksum `previous` | Records the digest that the destination file must match before update or deletion. It is the guard against overwriting or deleting local edits. |
| Checksum `target` | Records the digest expected after a successful apply for the target source. For deletion, the successful lock update MUST remove the managed entry or otherwise represent the path as no longer managed. |
| `created_by` | Records the sync tool identity and version that wrote the lock file. |

## Refusal Reporting

When sync refuses a path or operation, it SHOULD report:

- the normalized path;
- the relevant ownership category;
- whether the path is unowned, dirty, unsupported, malformed, symlinked,
  inconsistent, detached, unresolved, dirty-source, or blocked by selection;
- expected and current checksums when available;
- source channel and resolved-commit evidence when source resolution matters;
- the next safe manual action, such as backing up a collision, detaching a
  surface, restoring a clean managed file, fixing the lock, or using a future
  explicit recovery workflow.

Refusal is a successful safety outcome. It MUST leave destination content and
lock-file state unchanged for the refused operation.
