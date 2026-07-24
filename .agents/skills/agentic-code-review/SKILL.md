---
name: agentic-code-review
description: "Reusable staff-engineer code review workflow. Use to review a diff, branch, pull request, or proposed change for bugs, regressions, missing tests, scope drift, security risks, and release readiness."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: review
    - garrytan/gstack :: codex
---

# agentic-code-review: Code Review

| Field | Value |
| --- | --- |
| Skill ID | `agentic-code-review` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: review; garrytan/gstack :: codex |

Use this skill with a review mindset: findings first, ordered by severity, with exact file and line references.

## Review Workflow

1. Identify the base branch and changed files.
2. Read the requirement, ticket, or accepted plan.
3. Inspect the diff and nearby existing behavior.
4. Look for production bugs, regressions, missing tests, security gaps, and scope drift.
5. Separate defects from optional improvements.
6. Recommend fixes only after proving the issue from source.

## Finding Criteria

Report issues that can break behavior, data integrity, deployment, security, accessibility, or maintainability. Include:

- Incorrect logic or changed contract.
- Missing null, empty, permission, sharing, or bulk cases.
- Tests that do not cover the changed behavior.
- Hidden dependencies, race conditions, stale state, or rollback gaps.
- Over-broad commits, generated artifacts, or unrelated metadata.

Do not pad the review with style comments unless style creates real risk.

## Output

Format:

- Findings first, highest severity first.
- Each finding includes file, line, impact, and concrete fix direction.
- Then open questions or assumptions.
- Then brief positive/summary notes only if useful.

If no findings are found, say so and name residual risk or checks not run.
