# Artifact Contracts

## Purpose

This document reserves the portable surface for durable artifacts produced,
reviewed, or consumed during agent collaboration. It keeps artifact expectations
discoverable without defining schemas before the schema contract exists.

## Owns

Artifact contracts own:

- the distinction between durable artifacts and transient conversation context;
- the expectation that artifacts identify their purpose and intended consumer;
- the boundary between portable artifact expectations and project-local artifact
  conventions;
- the extension point for future artifact schema, lifecycle, and compatibility
  rules.

## Must Not Own

Artifact contracts MUST NOT own:

- concrete artifact schemas, field names, or validation vocabulary;
- repository-local artifact names, commands, storage locations, or release
  processes;
- adapter-specific payloads or platform-specific templates;
- sync metadata such as lock-file entries or checksums.

## Extension Path

Later detailed artifact work should extend this file with schema definitions,
versioning rules, required fields, lifecycle expectations, and compatibility
rules. Project-specific artifact conventions should live in `docs/project/**`.
Adapter-specific artifact formats should live with the relevant adapter.
