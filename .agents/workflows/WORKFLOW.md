# Workflow

## Purpose And Use

This file owns repeatable this project task and Git workflow steps. Read it before implementing, staging, committing, branching, opening PRs, or preparing release handoff. Put ordered process guidance, branch conventions, PR expectations, merge rules, release handoff steps, and recurring task sequences here.

## Current Notes

- For pull request, final commit, back-merge, and review-readiness gates, read [Pull Request Workflow](PULL_REQUEST.md).
- Until a more detailed development workflow is documented here, follow the root `AGENTS.md` default work pattern and the confirmation gates in `.agents/directives`.

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
