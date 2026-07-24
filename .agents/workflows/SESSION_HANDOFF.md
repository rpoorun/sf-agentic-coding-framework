# Session Handoff

## Purpose And Use

This file owns reusable session handoff, context-save, context-restore, learning, and retrospective guidance. Read it before pausing long work, resuming a saved context, handing work to another agent, recording durable lessons, or summarizing a completed delivery cycle.

This workflow is synthesized from the useful methodology behind gstack's `context-save`, `context-restore`, `learn`, and `retro` skills. It does not introduce a separate runtime, database, or cross-machine sync system.

## Context Save

Save context when work spans multiple sessions, another agent will continue, the user pauses before implementation, or the remaining work has important decisions that are not obvious from the diff.

Capture:

- Current branch and whether it is ahead, behind, or dirty.
- Objective and accepted scope.
- Decisions made, including rejected alternatives when they matter.
- Files intentionally changed and files intentionally left alone.
- Commands and checks run, with pass/fail status.
- Open risks, blockers, and approval-gated actions.
- Next concrete step.

Do not capture:

- Secrets, tokens, credentials, full payloads, cookies, or private IDs.
- Raw customer data or production records.
- Temp paths unless the exact path is required to resume.
- Speculation that was not accepted by the user.

## Context Restore

When restoring context:

1. Read the saved handoff and then verify it against current repo state.
2. Run `git status --short --branch` before relying on old file lists.
3. Re-read files that will be edited or reviewed.
4. Re-check any drift-prone fact, including branch position, Jira status, org state, PR status, or test results.
5. State which saved assumptions still hold and which need refresh.

Memory helps resume faster, but current source and current user instructions always win.

## Durable Learnings

Persist a learning only when it is reusable beyond the current moment:

- A project convention the repo already follows.
- A repeatable debugging, QA, deploy, or documentation pattern.
- A safety rule that prevents a realistic mistake.
- A user preference that changes future behavior.

Before writing a learning, ask permission and name the destination file. Route generic framework learning to directives, standards, skills, or workflows. Route project facts to `.agents/documentation/` or `{PROJECT_AGENTS}/`.

Never persist credentials, transient run IDs, one-off ticket facts, private data, raw stack traces with sensitive values, or unreviewed hypotheses.

## Retrospective

After a substantial delivery, summarize:

- What shipped or was completed.
- What slowed the work down.
- What safety gate, test, or review found real value.
- What should change in the framework, project helper, or docs.
- What should stay intentionally local to the ticket and not become a framework rule.

Treat retrospectives as improvement input, not as permission to edit framework files automatically.

## Handoff Template

```text
Objective:
-

Current state:
- Branch:
- Dirty files:
- Related ticket/PR:

Decisions:
-

Changed or relevant files:
-

Checks:
-

Open risks:
-

Next step:
-
```
