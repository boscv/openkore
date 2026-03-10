# Dataset Summary

## Purpose
This dataset provides an LLM-oriented knowledge layer for OpenKore architecture, runtime flow, debugging, and practical usage.

## Coverage areas
- **Architecture core**: context, subsystem boundaries, dependency map, code index.
- **Runtime flows**: AI loop, packet receive flow, NPC interaction, routing/movement, command and plugin hook flows.
- **Networking**: packet pipeline and XKore mode behavior.
- **Debugging**: playbook, decision trees, and common pitfalls.
- **Practical usage**: code recipes, FAQ, glossary, learning path, and user prompt examples.

## Main artifact groups
1. **Foundational architecture docs** (`01`-`05`, `20`)
2. **Flow/diagram docs** (`06`-`10`, `26`, `27`)
3. **Troubleshooting docs** (`15`, `16`, `22`)
4. **Developer enablement docs** (`17`, `18`, `19`, `24`, `29`)

## Intended users
- Developers onboarding to OpenKore internals.
- Maintainers debugging runtime and packet issues.
- LLM assistants that need stable structural context for responses.

## Strengths
- Grounded in likely module and directory references from the repository.
- Organized by numbered, task-oriented documents.
- Includes actionable diagnostics and reusable snippet patterns.

## Known limits
- Documentation is descriptive and may lag upstream implementation changes.
- Server-specific packet behavior can change rapidly after game updates.
- Mermaid diagrams prioritize clarity over exhaustive edge-case detail.

## Maintenance recommendations
- Re-validate packet/XKore docs after serverType or recvpackets updates.
- Update recipe snippets when plugin/hook APIs evolve.
- Keep FAQ and pitfalls synced with recurring issue reports.
