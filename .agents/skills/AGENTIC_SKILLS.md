# Agentic Skills

## Purpose And Use

This file maps generally reusable agentic work patterns to synthesized `agentic-*` skill folders installed under `.agents/skills/`. Read it when the task is about requirement discovery, plan review, code review, root-cause debugging, QA, release handoff, documentation, diagrams, developer experience, or skill evaluation rather than a Salesforce-specific metadata type.

These skills are generic and parameterized. In an installed project they belong at the user tier (`{USER_AGENTS}/skills/`) and can be adapted by project-level helpers under `{PROJECT_AGENTS}/skills/{skill-name}/`.

## Naming Convention

Every generic workflow skill folder is named `agentic-{name}`:

- `agentic-` identifies a reusable agent workflow capability that is not tied to Salesforce metadata.
- `{name}` is a short verb-led or capability-led name, such as `requirement-discovery`, `plan-review`, or `qa`.
- Skills must remain self-contained and portable; project facts belong in project documentation or project-level helpers, not in the skill body.

## Why These Skills Are Synthesized, Not Copied

The initial `agentic-*` family is synthesized from high-fit methods in [garrytan/gstack](https://github.com/garrytan/gstack), which is MIT licensed. The framework adapts the methodology, attribution, and workflow shape, but does not vendor gstack runtime code, browser daemons, iOS tooling, setup scripts, generated templates, or slash-command folders.

Excluded as standalone framework skills: `ios-*`, `open-gstack-browser`, `setup-browser-cookies`, `pair-agent`, `setup-gbrain`, `sync-gbrain`, `gstack-upgrade`, `setup-deploy`, `scrape`, `skillify`, browser-skill internals, and gstack build/runtime tooling.

## Standard Skill File Format

Every `agentic-*` `SKILL.md` follows this shape:

```markdown
---
name: agentic-{name}
description: "<activation description>"
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: <source-skill>
---

# agentic-{name}: <Title>

| Field | Value |
| --- | --- |
| Skill ID | `agentic-{name}` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: <source-skill> |
```

Keep each `SKILL.md` concise. Move long rubrics or templates to one-level `references/` files only when needed.

## Priority Order

When instructions conflict, apply this order:

1. Current user instruction.
2. Mandatory directives in `AGENT_GUARDRAILS.md`, `TRUST_DATA_SECURITY.md`, and `MANUAL_CONFIRMATION_GATES.md`.
3. Project-specific standards, workflows, ticket instructions, or repo conventions.
4. Salesforce-specific `sf-*` skills when the task touches Salesforce metadata, org state, Apex, LWC, Flow, data, or security.
5. The selected `agentic-*` skill.

Agentic skills may sharpen workflow, review, or discovery behavior, but they never weaken Salesforce safety gates, deploy gates, security requirements, or test-method preservation rules.

## Skill Router

| Work type | Skill folder (`.agents/skills/<name>`) | Local adaptation |
| --- | --- | --- |
| Reframe a vague request, run early product or requirement discovery, convert intent into a backlog-ready spec | `agentic-requirement-discovery` | Use before implementation for ambiguous tickets, stakeholder requests, or features where the real outcome may differ from the literal request. |
| Review a plan for scope, product value, architecture, data flow, UX, DX, risks, tests, and hidden decisions | `agentic-plan-review` | Use before major implementation, refactors, architecture changes, or work that touches multiple components. |
| Review a diff, branch, or proposed PR for defects, regressions, scope drift, missing tests, and readiness | `agentic-code-review` | Use with `PULL_REQUEST.md`; findings first, ordered by severity. |
| Investigate bugs and production-like failures without guessing at fixes | `agentic-root-cause` | Use for debug logs, failing tests, deploy errors, LWC behavior, Flow defects, or integration failures before patching. |
| Review visual design, interaction quality, SLDS fit, accessibility, and UI execution | `agentic-design-review` | For Salesforce UI, combine with `sf-platform-lwc`, `sf-design-slds-apply`, and `sf-design-slds-validate`. |
| Audit developer onboarding, setup, time-to-first-success, docs friction, and project workflow ergonomics | `agentic-devex-review` | Use for framework, repo, CI, bootstrap, or skill usability work. |
| Build a QA plan, run or report verification, map regressions, benchmark performance, and define canaries | `agentic-qa` | Use with `TESTING.md`; report-only mode when the user asks for analysis only. |
| Generate or update source-verified docs, release docs, Diataxis docs, and publishable PDF/doc outputs | `agentic-documentation` | Use with `DOCUMENTATION.md`; never document unverified source or guessed values. |
| Save and restore work context, hand off decisions, preserve learnings, and run retrospectives | `agentic-context-handoff` | Use with `SESSION_HANDOFF.md`; do not persist secrets or one-off noise. |
| Create Mermaid diagrams or diagram-ready explanations from source-grounded facts | `agentic-diagram` | For Salesforce metadata diagrams, `sf-tooling-diagram` remains authoritative. |
| Evaluate skill quality, compare model/review outputs, and produce benchmark reports | `agentic-skill-eval` | Use for framework meta work, not normal Salesforce delivery. |

## Delivery Guidance

For non-trivial work:

1. Start with the most specific domain skill. Use `sf-*` skills when the task is Salesforce-specific.
2. Add one `agentic-*` skill only when it changes the workflow meaningfully.
3. Keep decisions visible: requirement discovery feeds plan review; plan review feeds implementation; QA and code review feed release.
4. Record durable decisions through `SESSION_HANDOFF.md` only when they will help a future session.
5. Keep raw source attribution in the skill metadata and changelog, not in every handoff.
