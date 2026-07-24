---
name: agentic-qa
description: "Reusable QA and verification workflow. Use to plan or run manual QA, browser/UI verification, report-only QA, regression testing, performance benchmarking, health checks, canary checks, and acceptance evidence."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: qa
    - garrytan/gstack :: qa-only
    - garrytan/gstack :: browse
    - garrytan/gstack :: canary
    - garrytan/gstack :: benchmark
    - garrytan/gstack :: health
---

# agentic-qa: QA And Verification

| Field | Value |
| --- | --- |
| Skill ID | `agentic-qa` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: qa; garrytan/gstack :: qa-only; garrytan/gstack :: browse; garrytan/gstack :: canary; garrytan/gstack :: benchmark; garrytan/gstack :: health |

Use this skill to prove behavior, not merely to run commands.

## Modes

- **Report-only**: inspect and report defects without editing.
- **Fix-and-verify**: fix approved defects, then re-run the failing scenario.
- **Regression**: focus on affected neighboring behavior.
- **Canary**: verify post-deploy health and obvious production regressions.
- **Benchmark**: compare performance before and after a change.

## QA Workflow

1. Read the accepted requirement and changed scope.
2. Build a scenario matrix covering happy, empty, invalid, permission, bulk, integration, and rollback paths as applicable.
3. Run the narrowest meaningful automated checks first.
4. Add manual/browser checks for workflows automation cannot prove.
5. Record each defect with reproduction steps, expected result, actual result, and evidence.
6. After a fix, re-run the original failing scenario and a focused regression scenario.

## Evidence

Capture enough to make the result reproducible:

- Command and result summary.
- Test class or test method names.
- Browser path, user/profile, prerequisites, and screenshots when relevant.
- Performance numbers only when actually measured.
- Known gaps and why they were not covered.

Do not call a scenario verified when the required user, permission, org state, or data prerequisite was not present.
