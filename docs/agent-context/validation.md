# Validation Contracts

## Purpose

This document reserves the portable surface for validation expectations. It keeps
validation claims evidence-backed while leaving detailed vocabulary, commands,
and tooling to later contracts or project-local extensions.

## Owns

Validation contracts own:

- the requirement that validation claims identify the evidence used to support
  them;
- the high-level expectation that reports identify whether a validation claim is
  passed, failed, pending, skipped, not required, or confirmed by a maintainer,
  without defining detailed status semantics here;
- the boundary between portable validation expectations and repository-local
  validation commands;
- the extension point for future validation vocabulary, reporting structure, and
  lint integration.

## Must Not Own

Validation contracts MUST NOT own:

- concrete command lines, local tool requirements, fixtures, or CI job names;
- detailed validation status vocabulary beyond the high-level evidence boundary;
- artifact schemas or evaluation test cases;
- portability-lint implementation rules;
- sync-tool behavior beyond links to the dedicated sync safety contract.

## Extension Path

Later detailed validation work should extend this file with precise status
definitions, reporting formats, and evidence requirements. Repository-specific
checks should live in `docs/project/**`. Tool implementation details should live
with the relevant tool.
