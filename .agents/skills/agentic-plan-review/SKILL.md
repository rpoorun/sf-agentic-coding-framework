---
name: agentic-plan-review
description: "Reusable plan review workflow for scope, product value, architecture, data flow, UX, developer experience, risks, edge cases, observability, and tests. Use before substantial implementation, refactors, multi-file changes, or release plans."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: plan-ceo-review
    - garrytan/gstack :: plan-eng-review
    - garrytan/gstack :: plan-design-review
    - garrytan/gstack :: autoplan
    - garrytan/gstack :: plan-tune
---

# agentic-plan-review: Plan Review

| Field | Value |
| --- | --- |
| Skill ID | `agentic-plan-review` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: plan-ceo-review; garrytan/gstack :: plan-eng-review; garrytan/gstack :: plan-design-review; garrytan/gstack :: autoplan; garrytan/gstack :: plan-tune |

Use this skill to make a plan decision-complete before implementation.

## Review Modes

- **Expand**: surface higher-value options and ask the user to opt in.
- **Selective expand**: keep baseline scope but list optional improvements separately.
- **Hold scope**: make the accepted scope rigorous without widening it.
- **Reduce**: find the smallest version that achieves the core outcome.

Pick the mode from the user's instruction and risk profile. For bug fixes, hotfixes, and refactors, default to hold scope.

## Review Checklist

Evaluate:

- Outcome: is this the right problem and the direct path to it?
- Existing leverage: what source, metadata, workflow, or platform feature already solves part of it?
- Architecture: components, boundaries, data flow, state transitions, and failure paths.
- Security: trust boundaries, auth, CRUD/FLS, secrets, sensitive data, and audit logging.
- UX: loading, empty, error, disabled, responsive, accessibility, and trust states.
- DX: setup, naming, docs, discoverability, test ergonomics, and time to first successful change.
- Tests: positive, negative, empty, bulk, permission, integration, and regression scenarios.
- Observability: how a future operator knows this is broken.
- Rollback: what is reversible, manual, destructive, or approval-gated.

## Output

Produce a review summary with:

- Mode used.
- Strongest challenges.
- Recommended path.
- Accepted scope.
- Deferred items.
- Required decisions before implementation.
- Validation plan.

Do not silently add scope. Every scope change must be explicit.
