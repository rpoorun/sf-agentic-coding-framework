# Local Agile Board

## Overview

This board tracks Jira tickets locally as simple Markdown tables. Each lane file contains tickets in a specific workflow state.

## Lanes

| Lane | File | Description |
| --- | --- | --- |
| Backlog | [BACKLOG.MD](BACKLOG.MD) | Tickets not yet started |
| In Progress | [IN-PROGRESS.MD](IN-PROGRESS.MD) | Tickets actively being worked on |
| Blocked | [BLOCKED.MD](BLOCKED.MD) | Tickets blocked by dependencies or issues |
| Code Review | [CODE-REVIEW.MD](CODE-REVIEW.MD) | Tickets in code review |
| Done | [DONE.MD](DONE.MD) | Completed tickets |

## Usage

- Run `fetch Jira ticket {KEY}` to pull a ticket and auto-place it on the board
- Tickets are placed in lanes based on their Jira status
- Local status can diverge from Jira status to reflect local developer context
- See `.agents/workflows/PROJECT_TRACKING.MD` for lane mapping and update rules
