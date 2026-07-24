# Implementation Plan

## Purpose And Use

This file owns reusable implementation-planning workflow guidance. Read it before sequencing multi-part work, resolving dependencies, planning metadata/Apex/Flow/Login changes, or preparing rollout steps. Put dependency-ordering rules, planning templates, milestone structure, and recurring implementation decision points here.

## Current Notes

For multi-part Salesforce work, start by ordering metadata dependencies before Apex, automation, UI, login, and post-deploy verification.

## Requirement Discovery Gate

Before planning non-trivial work:

1. Read the ticket, requirement, user instruction, and relevant project docs.
2. Identify the business/process outcome and the user or system affected.
3. Search for existing source, metadata, platform features, or workflows that already cover the need.
4. Use `agentic-requirement-discovery` when the request is vague, broad, stakeholder-facing, or likely to be a proxy for a deeper outcome.
5. Record accepted scope, explicit non-scope, open questions, and assumptions before implementation.

Do not plan from the literal request alone when the outcome is unclear.

## Plan Review Gate

Use `agentic-plan-review` before implementation when any of these are true:

- More than one metadata family or application layer changes.
- A deploy, data migration, permission/access change, integration, or production-like workflow is involved.
- The change affects UI, error handling, security, observability, or rollback.
- The implementation has meaningful alternatives with different risk or effort.

The plan must name:

- Components/files expected to change.
- Existing code or metadata reused.
- Data flow and failure paths.
- Security and permission impact.
- Test and QA scenarios.
- Deploy, rollback, or manual steps.
- Decisions still needed from the user.

## Dependency Order

Prefer this order unless the project defines a narrower sequence:

1. Requirement and scope decision.
2. Schema, Custom Metadata, labels, permissions, and other prerequisites.
3. Apex/data-access logic.
4. Automation such as Flow or async processing.
5. LWC/UX surfaces.
6. Tests and test data factories.
7. Documentation, diagrams, and handoff.
8. Deploy validation, manual steps, and post-deploy verification.
