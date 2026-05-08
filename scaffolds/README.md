# Scaffolds

Scaffolds are source-owned starter files for consumer-owned local context.

The active v0.3 project scaffold source is `scaffolds/project/**`. During
initial adoption, tooling may materialize missing files from this source tree
into `docs/project/**` or another declared project extension path. After
materialization, those destination files are consumer-owned. Sync must preserve
them and must not list them as managed files.

## Active Scaffold Groups

| Group | Source path | Intended destination |
| --- | --- | --- |
| `project` | `scaffolds/project/**` | `docs/project/**` |

## Legacy Source Mapping

The earlier project extension template source `templates/project-extension/**`
is replaced by `scaffolds/project/**`. The new name reflects that source files
only seed local project context; they do not continue to own materialized
consumer files.
