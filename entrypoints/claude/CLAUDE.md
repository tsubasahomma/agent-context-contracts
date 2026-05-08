# Claude Entrypoint Routing

This file is an optional Claude-specific entry point. It does not replace the
durable operating contracts.

Use this routing order before making or reviewing changes:

1. Start with the root `AGENTS.md`.
2. Read `docs/agent-context/README.md` and the relevant portable contracts.
3. If `docs/project/**` exists, read the relevant local extension files for
   repository-local identity, surfaces, validation commands, workflow
   exceptions, and policy.
4. If `docs/project/**` is absent or incomplete, report the missing local
   evidence instead of inventing local facts.

For validation and readiness reporting, follow
`docs/agent-context/validation.md` and `docs/agent-context/workflows.md`.

Do not put repository identity, maintainer names, host paths, local commands,
secrets, tokens, private identifiers, or durable portable-core rules in this
file. Local facts belong in the project extension.
