# Evaluation Contracts

## Purpose

This document reserves the portable surface for evaluating whether agent context
contracts are followed. It keeps evaluation rules reviewable without adding
concrete cases before the evaluation contract is defined.

## Owns

Evaluation contracts own:

- the expectation that evaluations are stated as reviewable pass/fail checks;
- the boundary between portable evaluation criteria and project-local acceptance
  checks;
- the extension point for future evaluation cases covering contract adherence,
  portability, validation claims, adapter boundaries, and sync safety.

## Must Not Own

Evaluation contracts MUST NOT own:

- concrete evaluation cases, fixtures, scoring rubrics, or datasets;
- repository-local acceptance criteria or release gates;
- portability-lint implementation details;
- adapter-specific test payloads;
- sync-tool implementation behavior.

## Extension Path

Later detailed evaluation work should extend this file with concrete pass/fail
cases, expected evidence, review procedures, and regression coverage.
Project-specific acceptance checks should live in `docs/project/**`. Tool or
adapter tests should live with the relevant implementation.
