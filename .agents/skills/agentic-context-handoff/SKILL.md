---
name: agentic-context-handoff
description: "Reusable context-save, context-restore, learning, and retrospective workflow. Use when pausing work, resuming saved context, handing off to another agent, recording durable learning, or summarizing delivery lessons."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: context-save
    - garrytan/gstack :: context-restore
    - garrytan/gstack :: learn
    - garrytan/gstack :: retro
---

# agentic-context-handoff: Context Handoff

| Field | Value |
| --- | --- |
| Skill ID | `agentic-context-handoff` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: context-save; garrytan/gstack :: context-restore; garrytan/gstack :: learn; garrytan/gstack :: retro |

Use this skill with `SESSION_HANDOFF.md`.

## Save Context

Record:

- Branch and worktree state.
- Objective and accepted scope.
- Decisions and rejected alternatives that matter.
- Changed/relevant files.
- Checks run and their outcomes.
- Remaining risks and approval gates.
- Next concrete step.

## Restore Context

Before acting on saved context:

1. Verify branch and dirty state.
2. Re-read changed files and current instructions.
3. Refresh drift-prone external facts.
4. Reconcile saved decisions with newer user messages.
5. Continue from the next concrete step.

## Learn

Persist durable lessons only after user approval. Generic lessons go to framework directives, standards, skills, or workflows. Project facts go to project documentation or project-tier helpers.

Never persist secrets, raw customer data, tokens, or one-off ticket details.

## Retro

After substantial work, identify what should improve in the framework and what should remain local. Treat retros as candidates, not automatic edits.
