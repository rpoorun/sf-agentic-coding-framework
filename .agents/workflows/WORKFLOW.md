# Workflow

## Purpose And Use

This file owns repeatable this project task and Git workflow steps. Read it before implementing, staging, committing, branching, opening PRs, or preparing release handoff. Put ordered process guidance, branch conventions, PR expectations, merge rules, release handoff steps, and recurring task sequences here.

## Current Notes

- For pull request, final commit, back-merge, and review-readiness gates, read [Pull Request Workflow](PULL_REQUEST.md).
- For context-save, context-restore, learnings, and retrospectives, read [Session Handoff](SESSION_HANDOFF.md).

## Task Lifecycle

Use this lifecycle for non-trivial work:

1. **Discover** - read the request, ticket, docs, and current source. Use `agentic-requirement-discovery` when intent is vague or outcome-driven.
2. **Review the plan** - use `agentic-plan-review` for multi-file, high-risk, UI, security, integration, or release-sensitive work.
3. **Implement narrowly** - make the smallest correct change using the most specific `sf-*` or `agentic-*` skill.
4. **Verify** - follow [Testing](TESTING.md), [Development Gate](DEVELOPMENT_GATE.md), and [Deployment](DEPLOYMENT.md) as applicable.
5. **Review for landing** - follow [Pull Request Workflow](PULL_REQUEST.md), including diff review and scoped staging.
6. **Hand off** - capture durable decisions, checks, risks, and next steps through [Session Handoff](SESSION_HANDOFF.md) when work spans sessions or needs another reviewer.

Do not create a parallel lifecycle inside a skill. Skills sharpen the matching phase; workflow files own the ordered process.

## Scoped Staging Workflow

Use this workflow before staging source or metadata:

1. Run `git status --short` and identify staged, unstaged, and untracked changes separately.
2. Read the requirement, ticket part, or approved implementation scope being staged.
3. Inspect the diffs for every candidate file before adding it to the index.
4. Stage only the file, hunk, or line that is directly related to the current requirement.
5. For noisy Salesforce metadata files, prefer partial staging when only one field, FLS block, layout item, route, view, or setting belongs to the approved scope.
6. Leave unrelated retrieve output, generated files, local settings, and adjacent ticket changes unstaged.
7. Re-run `git diff --cached --name-only` and `git diff --cached --stat` to prove the staged set matches the requirement.
8. If the index and working tree both modify the same file, report that explicitly so reviewers know the staged hunk is intentionally narrower than the full local file.
