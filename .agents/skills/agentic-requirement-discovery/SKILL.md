---
name: agentic-requirement-discovery
description: "Reusable requirement discovery and specification workflow. Use when a request is vague, high-impact, product-facing, stakeholder-driven, or needs conversion from intent into a precise implementation-ready spec before code or metadata changes."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: office-hours
    - garrytan/gstack :: spec
---

# agentic-requirement-discovery: Requirement Discovery

| Field | Value |
| --- | --- |
| Skill ID | `agentic-requirement-discovery` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: office-hours; garrytan/gstack :: spec |

Use this skill before implementation when the literal request may not be the real requirement.

## Workflow

1. Ground in the repo, ticket, docs, and current source before asking questions.
2. Restate the goal as an outcome, not as a requested implementation.
3. Identify the user, business process, pain, status quo, and success signal.
4. Challenge whether the requested artifact is the smallest correct path.
5. Produce two or three implementation approaches with effort, risk, and reuse.
6. Convert the accepted approach into a spec with scope, acceptance criteria, open questions, and validation.

## Question Discipline

Ask one high-value question at a time when answers materially change scope. Prefer evidence-seeking questions:

- Who experiences the problem and what do they do today?
- What would fail or stay painful if this is not built?
- What is the smallest version that proves the outcome?
- What existing workflow, object, automation, or code path already handles part of this?
- What behavior is explicitly out of scope?

For internal Salesforce work, replace startup demand questions with sponsor, process, compliance, support, reporting, and release-readiness questions.

## Output

Produce a concise spec:

- Outcome and user/process.
- Accepted scope and excluded scope.
- Existing source or platform capability reused.
- Proposed implementation approach.
- Acceptance criteria.
- Required tests or verification.
- Approval-gated actions.
- Open questions that block implementation.

Do not implement while using this skill unless the user separately asks to proceed after the spec is accepted.
