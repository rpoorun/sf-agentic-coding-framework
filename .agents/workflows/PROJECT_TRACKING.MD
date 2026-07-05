# Project Tracking Workflow

## Purpose and Use

This workflow defines how Jira tickets are tracked locally as Markdown files and managed on a local agile board. Local tracking provides offline access to ticket context and a persistent record of implementation decisions.

## Local Ticket Files

### File Location

One self-contained Markdown file per ticket:
```
.agents/project/tickets/{KEY}.md
```

Example: `.agents/project/tickets/PROJECT-123.md`

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

{Parsed ADF description in Markdown}

## Acceptance Criteria

{Parsed from custom field, or "Not specified"}

## Solution

{Parsed from custom field, or "Not specified"}

## Rules & Conditions

{Parsed from custom field, or "Not specified"}

## Scope

{Parsed from custom field, or "Not specified"}

## Dependencies

| Relationship | Ticket | Summary |
| --- | --- | --- |
| Blocks | {KEY} | {summary} |
| Blocked by | {KEY} | {summary} |
| Relates to | {KEY} | {summary} |

## Comments Summary

{Latest comments — author, date, brief content. Omit sensitive data.}

## Implementation Plan

{Agent or developer notes on how to implement. Updated as work progresses.}

## File Scope

{List of files expected to be created or modified for this ticket.}

## Repo/Org Evidence

{Links to related PRs, branches, commits, or other tickets.}

## Deployment & Validation Plan

{Steps to deploy and verify the change.}

## QA Notes

{Testing observations, edge cases found, test results.}

## Pending Work

- [ ] {Remaining tasks}

## Handoff Notes

{Context for the next person picking up this ticket.}
```

### Rules for Ticket Files

- Do not store raw API responses or sensitive payloads
- Do not include auth tokens, headers, or credentials
- Keep comments summarized — full comment history stays in Jira
- Update `Last Synced` whenever re-fetching from Jira
- Preserve manually added sections (Implementation Plan, QA Notes, etc.) when re-syncing

## Local Agile Board

### Board Structure

The board lives under `.agents/project/board/` with these lane files:

| File | Purpose |
| --- | --- |
| `INDEX.MD` | Board overview and usage instructions |
| `BACKLOG.MD` | Tickets not yet started |
| `IN-PROGRESS.MD` | Tickets actively being worked on |
| `BLOCKED.MD` | Tickets blocked by dependencies or issues |
| `CODE-REVIEW.MD` | Tickets in code review |
| `DONE.MD` | Completed tickets |

### Lane File Format

Each lane file uses a Markdown table:

```markdown
| Ticket | Title | Jira Status | Local Status | Owner | Last Checked | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| PROJECT-123 | Fix login bug | In Progress | Active | Jane | 2025-06-20 | Blocked on API key |
```

### Board Update Rules

- When a ticket is fetched for the first time, add it to the lane matching its Jira status
- When a ticket's status changes, move it from the old lane to the new one (remove from old, add to new)
- `Local Status` can differ from `Jira Status` — it reflects what the local developer sees
- `Last Checked` is the date the ticket was last synced from Jira
- Keep `Notes` concise — one line max
- The `INDEX.MD` file provides an overview and does not duplicate lane contents

### Jira Status to Lane Mapping

| Jira Status (case-insensitive) | Board Lane |
| --- | --- |
| To Do, Open, Backlog, New | BACKLOG |
| In Progress, In Development, Active | IN-PROGRESS |
| Blocked, On Hold, Waiting | BLOCKED |
| In Review, Code Review, Review, PR Open | CODE-REVIEW |
| Done, Closed, Resolved, Complete | DONE |

For unrecognized statuses, default to `BACKLOG` and add a note.
