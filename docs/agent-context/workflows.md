# Workflow Contracts

## Purpose

This document reserves the portable surface for agent collaboration workflows. It
keeps workflow expectations separate from project-local procedures and
platform-specific adapter behavior.

## Owns

Workflow contracts own:

- the expectation that work starts from current evidence rather than stale
  handoff text;
- the expectation that scope, boundaries, deliverables, and validation evidence
  are kept visible during collaboration;
- the boundary between portable workflow rules and project-local workflow
  exceptions;
- the extension point for future role, handoff, review, and orchestration
  contracts.

## Must Not Own

Workflow contracts MUST NOT own:

- detailed thread-role definitions, handoff formats, or issue sequencing rules;
- repository-specific branching, review, release, or deployment procedures;
- collaboration-platform labels, templates, statuses, or automations;
- adapter payloads or tool-specific runtime behavior.

## Extension Path

Later detailed workflow work should extend this file with explicit role
responsibilities, handoff rules, review boundaries, and orchestration contracts.
Project-local workflow exceptions should live in `docs/project/**`.
Platform-specific workflow entry points should live with the relevant adapter.
