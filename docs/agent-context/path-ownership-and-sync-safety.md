# Path Ownership and Sync Safety Contract

This document defines the v0.1 path ownership and sync safety contract for a
portable agent context package.

v0.1 sync is a safe vendored-snapshot updater. It is not a semantic merge engine.
It MUST make conservative file-level decisions from explicit ownership state,
checksums, selected adapters, and destination-path collisions.

## Terms

- **Source package**: the reusable package tree that provides portable contracts,
  local-extension templates, optional adapter payloads, and sync tooling.
- **Consumer repository**: the destination repository where a package snapshot is
  installed or updated.
- **Managed file**: a destination file recorded in `agent-context.lock.json` with
  an ownership kind and checksum state.
- **Unowned file**: an existing destination file that is not recorded as managed
  in `agent-context.lock.json`.
- **Selected adapter**: an adapter explicitly requested for installation or
  update in the current sync operation.
- **Project extension**: consumer-owned local context under `docs/project/**`.

## Ownership Categories

| Category | Owner | Description | Sync responsibility |
| --- | --- | --- | --- |
| Package-managed portable file | Source package | Reusable, repository-agnostic contract content copied into the consumer repository. | MAY create or update only when safe by checksum. |
| Consumer-owned project extension file | Consumer repository | Repository-local identity, surfaces, validation commands, workflow exceptions, and local policy. | MAY create from a template during initial adoption only; MUST NOT overwrite after creation. |
| Source-package template | Source package | Template content used to seed consumer-owned project extension files. | MUST remain source-only unless explicitly materialized into a missing destination path. |
| Optional adapter payload | Source package adapter | Tool-specific or platform-specific payload stored under an adapter `files/` tree. | MUST NOT install unless the adapter is explicitly selected. |
| Adapter-installed managed file | Selected adapter through sync | Destination file created from a selected adapter payload and tracked in the lock file. | MAY create or update only when selected and checksum-safe. |
| Sync-tool-managed metadata | Sync tooling | Metadata used to record package version, source, adapter selection, managed paths, and checksums. | MUST be written only after a successful apply-mode run. |
| Unmanaged pre-existing destination file | Consumer repository | Existing destination file not recorded in the lock file for the relevant ownership kind. | MUST be preserved; sync MUST refuse conflicting overwrites. |

## Path Ownership Matrix

| Path | Source-package meaning | Consumer-repository destination meaning | Ownership kind | v0.1 sync behavior |
| --- | --- | --- | --- | --- |
| `AGENTS.md` | Portable entry point template, if present in the source package. | Short generic root entry point routing agents to portable contracts and the project extension. | Package-managed portable file when tracked; otherwise unmanaged pre-existing destination file. | MAY create when missing. MAY update only when tracked and checksum-safe. MUST refuse to overwrite an existing unowned root `AGENTS.md`. |
| `agent-context.lock.json` | Not portable contract content. | Sync-tool-managed metadata for the installed snapshot. | Sync-tool-managed metadata. | MUST be created or updated only after a successful apply-mode run. MUST NOT be edited as a portable source file. |
| `docs/agent-context/**` | Portable core contract documentation. | Package-managed portable contract documentation. | Package-managed portable file. | MAY create missing files and update tracked files when checksum-safe. MUST refuse to overwrite unowned destination collisions. |
| `docs/project/**` | No source-package managed content. | Consumer-owned local project extension. | Consumer-owned project extension file. | MAY be seeded from `templates/project-extension/**` during initial adoption when missing. MUST NOT overwrite existing or previously created project extension files. |
| `templates/project-extension/**` | Source-package templates for consumer-owned local extension files. | SHOULD NOT be installed as a managed destination tree by default. | Source-package template. | MAY be read by sync as source material. MUST NOT be tracked as consumer-owned managed content unless a future version explicitly defines that behavior. |
| `adapters/<adapter>/README.md` | Adapter documentation explaining optional payloads and boundaries. | Package-managed documentation only if copied into the consumer repository. | Package-managed portable file or adapter documentation, depending on packaging choice. | MAY be included in a vendored package snapshot. MUST NOT cause adapter payload installation by itself. |
| `adapters/<adapter>/files/**` | Optional adapter payload source tree. | SHOULD NOT remain at this path as installed runtime content unless the consumer intentionally vendors adapter sources. | Optional adapter payload. | MUST be skipped unless `<adapter>` is selected. Selected payload files map to their declared destination paths and become adapter-installed managed files if created. |
| Adapter-installed destination files in a consumer repository | Declared by the selected adapter payload mapping. | Tool-specific or platform-specific entry points, configuration, or templates. | Adapter-installed managed file when tracked; otherwise unmanaged pre-existing destination file. | MAY create missing files for selected adapters. MAY update tracked files only when selected and checksum-safe. MUST refuse to overwrite existing unowned destination files. |
| `tools/sync-agent-context.sh` | Source-package sync implementation, if present. | Optional package-managed tool copied for local execution, if included. | Package-managed portable file or sync tooling artifact. | This issue defines its contract only. A future implementation MAY manage the file by checksum. |
| `tools/lint-portability.sh` | Source-package portability lint implementation, if present. | Optional package-managed tool copied for local execution, if included. | Package-managed portable file or portability lint artifact. | This issue defines its contract only. A future implementation MAY manage the file by checksum. |

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

## Sync Modes

Dry-run is the default mode. A dry-run MUST report planned creates, updates,
skips, refusals, removals or preserves, and lock-file changes without writing to
the consumer repository.

Apply mode is required for writes. Apply mode MUST perform the same safety
checks as dry-run before changing files. The sync tool MUST update
`agent-context.lock.json` only after every planned write for the operation has
succeeded. If any planned write fails or is refused, the lock file MUST NOT be
advanced for that failed operation.

Apply mode MUST also protect destination content from partial write failures.
The implementation MUST use atomic apply, staged writes, rollback, or explicit
recovery behavior that is validated by executable evidence. Merely leaving the
old lock file in place after a partial write is not sufficient protection.

## Sync Decision Table

| Scenario | Safe v0.1 decision |
| --- | --- |
| Initial adoption with no lock file and no destination collision | In dry-run, report files that would be created. In apply mode, create package-managed portable files, selected adapter files, requested missing project extension files, and a new lock file. |
| Initial adoption with no lock file and existing destination collision | Treat existing files as unowned. MUST refuse overwrites for root `AGENTS.md`, `docs/project/**`, adapter destination files, and any package-managed destination path whose ownership cannot be established. |
| Subsequent update with matching managed-file checksums | MAY update tracked managed files when the current checksum equals the lock entry previous checksum. MUST record the new target checksum after successful apply. |
| Subsequent update with modified managed files | MUST refuse to overwrite when the current checksum differs from the lock entry previous checksum. SHOULD report the path and expected/current checksum evidence. |
| Existing unowned root `AGENTS.md` | MUST preserve and refuse overwrite. SHOULD report that manual adoption or an explicit backup/remediation step is required. |
| Existing unowned project extension files | MUST preserve and refuse overwrite. Project extension files are consumer-owned even if their content resembles a source template. |
| Existing unowned adapter destination files | MUST preserve and refuse overwrite, even when the adapter is selected. The destination file MAY become managed only through an explicit future adoption operation that verifies ownership intent. |
| Explicitly selected adapter install | MAY create missing adapter destination files and MAY update existing tracked files for that adapter when checksum-safe. MUST record the adapter in `installed_adapters[]`. |
| Unselected adapter payloads | MUST skip payload files and MUST NOT create, update, remove, or record their destination files. |
| Missing lock file after prior adoption is suspected | MUST treat destination files as unowned unless ownership can be re-established by an explicit future recovery workflow. v0.1 sync SHOULD refuse unsafe updates. |
| Unreadable, malformed, or unsupported lock file | MUST refuse apply-mode writes. SHOULD report the lock-file error and leave destination files unchanged. |
| Stale or inconsistent lock file state | MUST refuse affected paths when recorded checksums, ownership kinds, adapter state, or normalized paths conflict with current destination evidence. Unaffected paths MAY be reported as safe in dry-run, but apply SHOULD require a consistent lock state for the operation. |
| Source package file removal or rename | MUST NOT delete a managed destination file by default. MAY report the file as removed-from-source and preserve it. A future remove operation MUST be explicit, checksum-safe, and reflected in the lock file only after successful apply. |

## Managed Updates

A package-managed portable file or adapter-installed managed file MAY be updated
only when all of the following are true:

1. The path is present in `managed_files[]`.
2. The normalized destination path matches the lock entry path.
3. The lock entry ownership kind allows the update.
4. The current destination checksum matches the lock entry previous checksum.
5. The source target checksum is known for the package version being applied.
6. For adapter-installed files, the source adapter is selected in the current
   operation and recorded in `installed_adapters[]`.

If any condition is false, sync MUST skip or refuse the update according to the
decision table. It MUST NOT attempt to merge user edits into managed files.

## Project Extension Preservation

`docs/project/**` is consumer-owned. Sync MAY create project extension files from
`templates/project-extension/**` only when the destination path is missing and
the operation explicitly includes project extension seeding. Once created, those
files MUST NOT be package-managed portable files and MUST NOT be overwritten by
subsequent sync operations.

The lock file MAY record `project_extension_path` so tooling can find the local
extension. That record is a pointer, not ownership over the files below that
path.

## Adapter Installation

Adapters are opt-in. The presence of `adapters/<adapter>/README.md` or
`adapters/<adapter>/files/**` in the source package MUST NOT install adapter
payloads by default.

When an adapter is selected, sync MUST map payload files from
`adapters/<adapter>/files/**` to declared consumer-repository destination paths.
Created files become adapter-installed managed files and MUST include the source
adapter in their lock entries.

Unselected adapters MUST NOT affect the consumer repository.

## Lock-File Ownership Model

`agent-context.lock.json` is sync-tool-managed metadata. The sync tool owns its
structure and checksum updates. Consumers MAY inspect it, but manual edits make
the next sync operation responsible for validating consistency before any apply.

The minimal v0.1 model is:

```json
{
  "schema_version": "0.1",
  "package_version": "0.1.0",
  "source_ref": "package-source-ref",
  "project_extension_path": "docs/project",
  "managed_files": [
    {
      "path": "docs/agent-context/README.md",
      "ownership": "package-managed",
      "checksum": {
        "algorithm": "sha256",
        "previous": "sha256:previous-file-digest",
        "target": "sha256:target-file-digest"
      },
      "source_adapter": null
    },
    {
      "path": "adapter/destination/path.md",
      "ownership": "adapter-installed",
      "checksum": {
        "algorithm": "sha256",
        "previous": "sha256:previous-file-digest",
        "target": "sha256:target-file-digest"
      },
      "source_adapter": "adapter"
    }
  ],
  "installed_adapters": [
    {
      "name": "adapter",
      "source_ref": "package-source-ref"
    }
  ],
  "created_by": {
    "tool": "sync-agent-context",
    "version": "0.1.0"
  }
}
```

Field responsibilities:

| Field | Responsibility |
| --- | --- |
| `schema_version` | Defines the lock-file schema. Unsupported versions MUST cause apply-mode refusal. |
| `package_version` | Records the package snapshot version installed or targeted by the last successful apply. |
| `source_ref` | Records the source package reference used for the installed snapshot. It SHOULD be immutable enough for audit and checksum reproduction. |
| `project_extension_path` | Points to the consumer-owned project extension root. It MUST NOT imply package ownership of files below that path. |
| `managed_files[]` | Lists only files owned by package sync or selected adapters. Consumer-owned project extension files MUST NOT be listed as managed files. |
| Managed file `path` | Stores the normalized consumer-repository destination path used for checksum matching. |
| Managed file `ownership` | Identifies whether the file is `package-managed`, `adapter-installed`, or another future explicit managed kind. Unknown kinds MUST cause refusal for that path. |
| Checksum `algorithm` | Names the digest algorithm. v0.1 SHOULD use `sha256`. Unsupported algorithms MUST cause refusal for that path. |
| Checksum `previous` | Records the digest that the destination file must match before update. It is the guard against overwriting local edits. |
| Checksum `target` | Records the digest expected after a successful apply for the target package snapshot. |
| `source_adapter` | Records the adapter name for adapter-installed files. It MUST be null or absent for package-managed portable files. |
| `installed_adapters[]` | Records explicitly installed adapters. It MUST NOT include unselected adapters merely present in the source package. |
| `created_by` | Records the sync tool identity and version that wrote the lock file. |

## Remove Or Preserve Behavior

v0.1 sync MUST preserve destination files by default when a source package file is
removed or renamed. It MAY report that a tracked destination file no longer has a
source counterpart. It MUST NOT delete that file unless a future explicit remove
operation is defined and the destination checksum still matches the lock entry
previous checksum.

When a file is preserved after source removal or rename, the lock file MUST NOT
pretend the file was updated to a new target checksum. A future implementation
SHOULD make the preserved state visible in dry-run output.

## Refusal Reporting

When sync refuses a path, it SHOULD report:

- the normalized path;
- the relevant ownership category;
- whether the path is unowned, modified, unsupported, inconsistent, or blocked by
  adapter selection;
- expected and current checksums when available;
- the next safe manual action, such as backing up a collision or intentionally
  adopting a file in a future recovery workflow.

Refusal is a successful safety outcome. It MUST leave destination content and
lock-file state unchanged for the refused operation.
