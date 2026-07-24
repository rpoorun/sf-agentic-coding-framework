---
name: agentic-root-cause
description: "Reusable root-cause investigation workflow. Use when debugging failures, flaky tests, deploy errors, production-like incidents, data issues, LWC/Flow behavior, integration defects, or any bug where a fix should not be guessed."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: investigate
---

# agentic-root-cause: Root Cause Investigation

| Field | Value |
| --- | --- |
| Skill ID | `agentic-root-cause` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: investigate |

Do not patch symptoms before identifying the most likely cause.

## Investigation Loop

1. Reproduce or gather the failing evidence.
2. Trace the data/control flow from entry point to failure.
3. List hypotheses with observable predictions.
4. Test the cheapest hypothesis first.
5. Update the hypothesis list after each result.
6. Fix only after the evidence identifies the cause.
7. Re-run the failing check and a focused regression check.

If three attempted fixes fail, stop and re-open the investigation instead of stacking guesses.

## Evidence To Prefer

- Exact error text and stack trace.
- Debug log segment around the failing transaction.
- Test result with method name and assertion.
- Deployment validation output.
- Source trace through callers, selectors, services, Flows, and components.
- Recent diff or org change that plausibly introduced the behavior.

## Output

Report:

- Symptom.
- Confirmed or best-supported cause.
- Evidence.
- Fix direction.
- Verification run.
- Remaining uncertainty.

When the root cause is not proven, state the uncertainty plainly.
