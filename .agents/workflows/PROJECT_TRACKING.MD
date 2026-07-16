# Project Tracking Workflow

## Purpose and Use

This workflow owns local ticket management: creating and updating ticket Markdown files, managing the agile board, and routing ticket-scoped commands to the framework's existing workflows. It is source-agnostic — ticket data can come from the [Jira skill](../skills/jira-management/SKILL.md), another integration, or manual input.

This workflow does **not** own:
- Jira API access → owned by the [Jira skill](../skills/jira-management/SKILL.md) and [JIRA.MD](JIRA.MD)
- Requirements validation → owned by [SPECIFICATION.md](../project/SPECIFICATION.md)
- Implementation planning → owned by [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
- Deployment and conflict checks → owned by [DEPLOYMENT.md](DEPLOYMENT.md)
- Testing strategy → owned by [TESTING.md](TESTING.md)

## Single File Principle

**One ticket = one file = one source of truth.**

Every ticket is represented by exactly one Markdown file at `{REPO_STATE}/project/tickets/{KEY}.md`, where `{REPO_STATE}` is the per-repo project state location resolved via the [layered resolution chain](../../AGENTS.md#layered-resolution) (on local developer machines this is `{USER_AGENTS}/{repo_name}/` — `~/.agents/{repo_name}/` on Unix or `%USERPROFILE%\.agents\{repo_name}\` on Windows; `{repo_name}` is the basename of `git rev-parse --show-toplevel`). On local machines this file lives **outside the repo** so it persists across branches and sessions. In sandboxed/remote environments, persistence is limited to what the resolved state location provides — do not assume state survives between sandbox sessions. Every operation — regardless of which skill, workflow, or framework layer performs it — reads from and writes back to this same file:

- The **Jira skill** initialises the file with ticket metadata, description, acceptance criteria, solution, dependencies, and comments.
- The **`analyse` command** writes the implementation plan, impact assessment, file scope, and test scenarios into the same file.
- The **`build` command** updates the file with the deployment manifest, pre/post steps, the Development Gate (Gate A) checklist record, and build status.
- The **`test` command** writes test results and coverage data to the QA Notes section of the same file.
- The **`deploy` command** records the deployment outcome and timestamp in the same file.
- The **`comment` command** reads the same file to compose a review summary.

No operation creates a separate file for its output. No workflow splits ticket context across multiple locations. The ticket file accumulates all context progressively — each step enriches what the previous step wrote — so any agent or developer opening the file sees the complete picture: what the ticket asks for, how it was analysed, what was built, how it was tested, and whether it was deployed.

When re-syncing from Jira (or any source), incoming data is merged into the existing file. Manually-written sections (Implementation Plan, QA Notes, Handoff Notes, etc.) are always preserved — they are never overwritten by a sync.

## Command Routing

When the user says a command followed by a ticket key (e.g. `analyse DTT-115`), this workflow receives the request and delegates to the appropriate framework workflow. The ticket key acts as a **context anchor** — it tells the workflow which local ticket file to read/write, but the execution logic belongs to the framework.

| User Command | This Workflow Does | Then Delegates To |
| --- | --- | --- |
| `fetch {KEY}` | Invokes the [Jira fetch workflow](JIRA.MD), then creates/updates the local ticket file and board | [JIRA.MD](JIRA.MD) (API call) |
| `analyse {KEY}` | Ensures ticket is synced, reads ticket context | [SPECIFICATION.md](../project/SPECIFICATION.md) (requirement validation) → [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) (plan production) |
| `build {KEY}` | Ensures analysis exists, reads implementation plan from ticket file | Framework standards (code generation) → [DEPLOYMENT.md](DEPLOYMENT.md) (dry deploy + coverage gate) → [DEVELOPMENT_GATE.md](DEVELOPMENT_GATE.md) (Gate A, pre-manifest) |
| `deploy {KEY}` | Reads deployment manifest from ticket file, presents to user | [DEVELOPMENT_GATE.md](DEVELOPMENT_GATE.md) (Gate B, pre-deploy) → [DEPLOYMENT.md](DEPLOYMENT.md) (full deploy with confirmation) |
| `test {KEY}` | Reads ticket scope for targeted test run | [DEPLOYMENT.md](DEPLOYMENT.md) (dry deploy) → [TESTING.md](TESTING.md) (test strategy) |
| `comment {KEY}` | Reads ticket file, composes review comment, outputs to chat | None — self-contained, local-only |

---

## Ticket Sync

When ticket data arrives (from the Jira fetch workflow or any other source):

### If a local ticket file exists at `{REPO_STATE}/project/tickets/{KEY}.md`:
1. Read the local file
2. Compare the incoming `updated` timestamp against the local `Last Synced`
3. Identify changes: field updates, new comments, status changes
4. Summarise what changed since last sync in chat
5. Ask the user to approve the update
6. On approval, merge new data into the local file **preserving manually-written sections** (Implementation Plan, QA Notes, Handoff Notes, etc.)

### If no local file exists:
1. Present the ticket summary in chat
2. Create a new ticket file using the template below
3. Populate all available sections from the incoming data
4. Leave implementation-specific sections as placeholders

### After any create/update:
Update the agile board lane to match the ticket's current status.

---

## Local Ticket Files

### File Location

One self-contained Markdown file per ticket:
```
{REPO_STATE}/project/tickets/{KEY}.md
```
`{REPO_STATE}` is resolved via the [per-repo project state chain](../../AGENTS.md#layered-resolution).

### Ticket File Template

```markdown
# {KEY}: {Title}

## Metadata

| Field | Value |
| --- | --- |
| Jira Key | {KEY} |
| Status | {status} |
| Assignee | {assignee} |
| Reporter | {reporter} |
| Priority | {priority} |
| Issue Type | {type} |
| Labels | {labels} |
| Components | {components} |
| Fix Versions | {fixVersions} |
| Story Points | {storyPoints} |
| Created | {created} |
| Updated | {updated} |
| Last Synced | {sync timestamp} |

## Description

{Parsed description in Markdown}

## Acceptance Criteria

{Parsed from ticket, or "Not specified"}

## Solution

{Parsed from ticket, or "Not specified"}

## Rules & Conditions

{Parsed from ticket, or "Not specified"}

## Scope

{Parsed from ticket, or "Not specified"}

## Dependencies

| Relationship | Ticket | Summary |
| --- | --- | --- |
| Blocks | {KEY} | {summary} |
| Blocked by | {KEY} | {summary} |
| Relates to | {KEY} | {summary} |

## Comments Summary

{Latest comments — author, date, brief content. Omit sensitive data.}

## Implementation Plan

{Populated by the `analyse` command via IMPLEMENTATION_PLAN.md workflow.}

## File Scope

{List of files expected to be created or modified. Populated during analysis.}

## Repo/Org Evidence

{Links to related PRs, branches, commits, or other tickets.}

## Deployment & Validation Plan

{Populated by the `build` command. Deployment manifest, pre/post steps, Development Gate checklist record ([DEVELOPMENT_GATE.md](DEVELOPMENT_GATE.md)).}

## QA Notes

{Populated by the `test` command. Test results, coverage, edge cases.}

## Pending Work

- [ ] {Remaining tasks}

## Handoff Notes

{Context for the next person picking up this ticket.}
```

### Rules for Ticket Files

- Do not store raw API responses or sensitive payloads
- Do not include auth tokens, headers, or credentials
- Keep comments summarised — full comment history stays in the source system
- Update `Last Synced` whenever re-syncing from the source
- Preserve manually added sections when re-syncing

---

## Ticket-Scoped Commands

### `analyse {KEY}`

1. **Ensure ticket is synced** — if the local file is missing or stale, run `fetch {KEY}` first.
2. **Run requirement validation** — apply the gates in [SPECIFICATION.md](../project/SPECIFICATION.md): verify base objects, field definitions, metadata members, and flag ambiguities.
3. **Delegate to [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** — using the validated requirements and ticket context, produce:
   - Implementation plan with ordered steps and file-level scope
   - Impact assessment — components affected, potential overrides, conflicts
   - Manual steps — pre-deploy and post-deploy actions
   - Test scenarios — derived from acceptance criteria
   - Risk assessment — deployment conflicts, data migration, permission changes
4. **Diff local repo against dev org** — retrieve relevant metadata into `{REPO_TEMP}/retrieve-{KEY}/` (the resolved temp workspace — see [Temp Workspace](../directives/AGENT_GUARDRAILS.md#temp-workspace)), diff against local source, document affected metadata.
5. **Save to ticket file** — write the implementation plan, file scope, and impact assessment into the local ticket file.
6. **Report in chat** — summarise the analysis and flag blockers or questions.
7. **Do not modify any source files** — analysis only.

### `build {KEY}`

1. **Ensure analysis exists** — if no Implementation Plan in the ticket file, run `analyse {KEY}` first.
2. **Check dependencies** — read issue links from the ticket file. If blocking tickets are unresolved, warn the user.
3. **Implement** — follow the Implementation Plan step by step. Generate or modify Salesforce metadata and Apex code locally following the framework's existing standards ([Salesforce Apex Standards](../standards/SALESFORCE_APEX_STANDARDS.md), [Lean Code Standards](../standards/LEAN_CODE_STANDARDS.md), [Trigger Framework](../standards/APEX_TRIGGER_FRAMEWORK.md), etc.).
4. **Build test classes** — create or extend Apex tests to cover new/modified code.
5. **Delegate to [DEPLOYMENT.md](DEPLOYMENT.md)** — run a dry deploy with the framework's full deployment workflow:
   - Pre-deploy conflict check (mandatory)
   - `sf project deploy start --dry-run` with test execution
   - 95% coverage gate (mandatory)
   - If errors occur, fix locally and re-run
6. **Run the Development Gate (Gate A)** — complete the self-checklist in [DEVELOPMENT_GATE.md](DEVELOPMENT_GATE.md) for every applicable section, with evidence. Any applicable item that fails blocks manifest generation — fix and re-run the gate first.
7. **Build deployment manifest** — save to the ticket file: components, dependencies, deployment order, pre/post manual steps, test classes, expected coverage, and the completed Gate A checklist record.
8. **Stop — do not deploy.** If deployment conflicts were detected, advise the user in chat.

### `deploy {KEY}`

1. **Read deployment manifest** from the ticket file. If none exists, tell the user to run `build {KEY}` first.
2. **Run the Development Gate (Gate B)** — per [DEVELOPMENT_GATE.md](DEVELOPMENT_GATE.md): re-verify any Gate A item whose subject changed since the manifest was built, and run the Manifest Integrity checks. Any failure blocks the deploy — do not proceed to confirmation.
3. **Present manifest in chat** — components, dependencies, pre-deploy manual steps, post-deploy manual steps, expected test coverage, and the Gate B result.
4. **Delegate to [DEPLOYMENT.md](DEPLOYMENT.md)** — execute the full deployment workflow:
   - Environment config check
   - Pre-deploy conflict check
   - User confirmation (required by [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md))
   - `sf project deploy start` to the default dev org
   - 95% coverage gate
   - Reporting
5. **Update ticket file** — record deployment outcome, timestamp, and post-deploy observations.

### `test {KEY}`

1. **Identify test scope** from the ticket file — test classes associated with the ticket's implementation.
2. **Delegate to [DEPLOYMENT.md](DEPLOYMENT.md)** — run a dry deploy with test execution only:
   - `sf project deploy start --dry-run` with relevant test classes
   - 95% coverage gate
3. **Do not persist** any changes to the org.
4. **Update ticket file** — write test results to the QA Notes section.
5. Follow any project-specific testing guidance in [TESTING.md](TESTING.md) when populated.

### `comment {KEY}`

This command is self-contained — it does not delegate to another workflow.

1. Read the local ticket file.
2. Compose a structured review comment:
   ```
   ## Implementation Summary
   - Components: {list of created/modified files}
   - Branch: {current branch name}

   ## Testing
   - Test classes: {list}
   - Coverage: {percentage}
   - All tests passing: {yes/no}

   ## Manual Setup Required
   - {permission set assignments, custom settings, etc.}

   ## How to Verify
   1. {step-by-step verification instructions}

   ## Notes
   - {known limitations, follow-up items}
   ```
3. Output the comment in chat as a copyable text block.
4. **Do not post to Jira or any external system.** Remind the user to paste it manually.

---

## Local Agile Board

### Board Structure

The board lives under `{REPO_STATE}/project/board/` (resolved via the [per-repo project state chain](../../AGENTS.md#layered-resolution)) with these lane files (created during project bootstrap if they don't exist):

| File | Purpose |
| --- | --- |
| `INDEX.MD` | Board overview and usage instructions |
| `BACKLOG.MD` | Tickets not yet started |
| `IN-PROGRESS.MD` | Tickets actively being worked on |
| `BLOCKED.MD` | Tickets blocked by dependencies or issues |
| `CODE-REVIEW.MD` | Tickets in code review |
| `DONE.MD` | Completed tickets |

### Lane File Format

```markdown
| Ticket | Title | Jira Status | Local Status | Owner | Last Checked | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| PROJECT-123 | Fix login bug | In Progress | Active | Jane | 2025-06-20 | Blocked on API key |
```

### Board Update Rules

- When a ticket is fetched for the first time, add it to the lane matching its status
- When a ticket's status changes, remove it from the old lane and add it to the new one
- `Local Status` can differ from the source system status — it reflects local developer context
- `Last Checked` is the date the ticket was last synced
- Keep `Notes` concise — one line max

### Status to Lane Mapping

| Status (case-insensitive) | Board Lane |
| --- | --- |
| To Do, Open, Backlog, New | BACKLOG |
| In Progress, In Development, Active | IN-PROGRESS |
| Blocked, On Hold, Waiting | BLOCKED |
| In Review, Code Review, Review, PR Open | CODE-REVIEW |
| Done, Closed, Resolved, Complete | DONE |

For unrecognised statuses, default to `BACKLOG` and add a note.
