# Evidence-Packing Contracts

## Purpose

This document defines the portable, tool-neutral surface for preparing evidence
that agents use during planning, implementation, review, and evaluation. It
keeps evidence packing separate from any specific context-packing tool or
adapter.

## Owns

Evidence-packing contracts own:

- the expectation that packed evidence is scoped to the active task;
- the expectation that evidence is current, relevant, and traceable to its
  source;
- the boundary between portable evidence principles and tool-specific packing
  formats;
- the extension point for future packing guidance, handoff inputs, and adapter
  boundaries.

## Must Not Own

Evidence-packing contracts MUST NOT own:

- required packing tools, command lines, generated file formats, or adapter
  payloads;
- project-local source maps, secret handling procedures, or context budgets;
- detailed workflow handoff contracts;
- evaluation cases or lint implementation.

## Extension Path

Later detailed evidence-packing work should extend this file with portable
packing criteria, freshness rules, redaction boundaries, and handoff evidence
requirements. Tool-specific packing behavior should live in adapters.
Project-local evidence sources should live in `docs/project/**`.
