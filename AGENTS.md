# AI Agent Operating Guide

## Purpose And Use

`AGENTS.md` is the first file AI-assisted coding agents must read in this repository. Use it as the router for mandatory directives, project facts, workflow steps, quality standards, and skill-routing guidance before changing source, metadata, documentation, org state, or Git state.

## Project Guidance

- For instruction-file maintenance, start with [Agentic framework](.agents/directives/AGENTIC_FRAMEWORK.md).
- For requirement analysis, read [Specification rules](.agents/project/SPECIFICATION.md) before implementation feasibility.
- For Salesforce source work, read [Project structure](.agents/project/PROJECT_STRUCTURE.md), [Salesforce project best practices](.agents/standards/SALESFORCE_PROJECT_BEST_PRACTICES.md), and the relevant workflow file.
- For Apex work, read [Salesforce Apex standards](.agents/standards/SALESFORCE_APEX_STANDARDS.md) and [PMD Apex ruleset guide](.agents/standards/PMD_APEX_RULESET.md).
- For tool or skill routing, read [Salesforce skills](.agents/skills/SALESFORCE_SKILLS.md).
- For writing or updating project technical documentation (`docs/` describing implemented Apex, LWC, or config), read [Documentation standards](.agents/standards/DOCUMENTATION.md) first — never document anything without verifying it against source per that file.

## Required Reading Order

1. [Agentic framework](.agents/directives/AGENTIC_FRAMEWORK.md)
2. [Agent guardrails](.agents/directives/AGENT_GUARDRAILS.md)
3. [Trust, data, and security rules](.agents/directives/TRUST_DATA_SECURITY.md)
4. [Manual confirmation gates](.agents/directives/MANUAL_CONFIRMATION_GATES.md)
5. [Project structure](.agents/project/PROJECT_STRUCTURE.md)
6. [Workflow](.agents/workflows/WORKFLOW.md)
7. [Deployment workflow](.agents/workflows/DEPLOYMENT.md)
8. [Pull request workflow](.agents/workflows/PULL_REQUEST.md)
9. [Requirement and specification rules](.agents/project/SPECIFICATION.md)
10. [Salesforce project best practices](.agents/standards/SALESFORCE_PROJECT_BEST_PRACTICES.md)
11. [Salesforce skills](.agents/skills/SALESFORCE_SKILLS.md)
12. [Salesforce Apex standards](.agents/standards/SALESFORCE_APEX_STANDARDS.md)
13. [PMD Apex ruleset guide](.agents/standards/PMD_APEX_RULESET.md)
14. [Lean code standards](.agents/standards/LEAN_CODE_STANDARDS.md)
15. [Apex trigger framework](.agents/standards/APEX_TRIGGER_FRAMEWORK.md)
16. [Apex constants framework](.agents/standards/APEX_CONSTANTS_FRAMEWORK.md)
17. [Documentation standards](.agents/standards/DOCUMENTATION.md)

## Documentation Layout

- `.agents/directives` contains mandatory rules agents must obey: safety, trust, confirmation, and framework governance.
- `.agents/standards` contains reusable quality expectations for Salesforce, Apex, metadata, PMD, naming, and review.
- `.agents/skills` contains capability-routing guidance and local adaptations of reusable skills or tools.
- `.agents/workflows` contains repeatable task processes such as implementation, testing, and Git/workflow handoff.
- `.agents/project` contains durable this project facts: structure, environment, requirements, schema, integrations, glossary, and UX context.

## Agent Framework

The governing framework for this repository's instruction files is [AGENTIC_FRAMEWORK.md](.agents/directives/AGENTIC_FRAMEWORK.md). Before adding, moving, renaming, or expanding `.agents` files, classify the content as a directive, standard, skill, workflow, or project fact and avoid duplicating an instruction already owned elsewhere.

## Master Framework Repository

This `AGENTS.md` + `.agents/` framework is mirrored from a master repository: **https://github.com/rpoorun/sf-agentic-coding-framework**. If this install needs the latest framework updates, or has learned a generally-applicable improvement worth contributing back upstream, follow [Master Framework Repository And Sync Workflow](.agents/directives/AGENTIC_FRAMEWORK.md#master-framework-repository-and-sync-workflow) — it defines the pull/merge-with-approval procedure for updates and the isolate-and-fork procedure for contributing learned skills/instructions back, both of which require explicit user confirmation before any Git action.

## Directive Reference Files

| File | Intended purpose |
| --- | --- |
| [AGENTIC_FRAMEWORK.md](.agents/directives/AGENTIC_FRAMEWORK.md) | Governing framework for classifying, maintaining, and reusing agent instructions. |
| [AGENT_GUARDRAILS.md](.agents/directives/AGENT_GUARDRAILS.md) | Mandatory repo-wide behavioral guardrails, source-control safety, org safety, and communication rules. |
| [TRUST_DATA_SECURITY.md](.agents/directives/TRUST_DATA_SECURITY.md) | Trust boundaries, data handling, security, sanitization, logging, and mutation rules. |
| [MANUAL_CONFIRMATION_GATES.md](.agents/directives/MANUAL_CONFIRMATION_GATES.md) | Actions that require human approval before proceeding. |

## Standards Reference Files

| File | Intended purpose |
| --- | --- |
| [SALESFORCE_PROJECT_BEST_PRACTICES.md](.agents/standards/SALESFORCE_PROJECT_BEST_PRACTICES.md) | [Org] Salesforce baseline for naming, metadata, architecture, tests, and configuration. |
| [SALESFORCE_APEX_STANDARDS.md](.agents/standards/SALESFORCE_APEX_STANDARDS.md) | Apex class, trigger, async, security, test, and review standards. |
| [PMD_APEX_RULESET.md](.agents/standards/PMD_APEX_RULESET.md) | PMD Apex static-analysis guidance, command shape, suppression policy, and agent requirements. |
| [LEAN_CODE_STANDARDS.md](.agents/standards/LEAN_CODE_STANDARDS.md) | Lean-coding decision ladder and token-efficient collaboration rules, refactored for Apex/LWC from general-purpose sources. |
| [APEX_TRIGGER_FRAMEWORK.md](.agents/standards/APEX_TRIGGER_FRAMEWORK.md) | Mandatory `TriggerHandler` base-class pattern, recursion control, and bypass API for every Apex trigger. |
| [APEX_CONSTANTS_FRAMEWORK.md](.agents/standards/APEX_CONSTANTS_FRAMEWORK.md) | Mandatory `Consts`/`{SObject}Consts` singleton pattern for picklist values and other Apex constants. |
| [DOCUMENTATION.md](.agents/standards/DOCUMENTATION.md) | How to write and maintain project technical documentation describing actual Apex, LWC, and configuration — source-verification rules, doc-tree structure, style, and content inclusion/exclusion. |

## Skill Reference Files

| File | Intended purpose |
| --- | --- |
| [SALESFORCE_SKILLS.md](.agents/skills/SALESFORCE_SKILLS.md) | Naming convention, synthesis procedure, and routing rules for the `sf-{cloud}-{name}` agent skills. |

## Workflow Reference Files

| File | Intended purpose |
| --- | --- |
| [WORKFLOW.md](.agents/workflows/WORKFLOW.md) | Git workflow, task flow, branch conventions, PR expectations, and release handoff process. |
| [DEPLOYMENT.md](.agents/workflows/DEPLOYMENT.md) | Mandatory pre-deploy org-conflict check/merge and the 95% Apex coverage gate for every sandbox/org deploy, dry-run included. |
| [PULL_REQUEST.md](.agents/workflows/PULL_REQUEST.md) | Pull request template usage, final commit, back-merge, and review-readiness checklist. |
| [TESTING.md](.agents/workflows/TESTING.md) | Verification protocols, test commands, mocking strategies, coverage expectations, and acceptance checks. |
| [IMPLEMENTATION_PLAN.md](.agents/workflows/IMPLEMENTATION_PLAN.md) | Delivery sequencing, dependency ordering, implementation planning, rollout steps, and open task tracking. |

## Project-Specific Reference Files

| File | Intended purpose |
| --- | --- |
| [PROJECT_STRUCTURE.md](.agents/project/PROJECT_STRUCTURE.md) | Repository topology, source folders, metadata locations, and orientation checklist. |
| [ARCHITECTURE.md](.agents/project/ARCHITECTURE.md) | System topology, modules, services, dependencies, data flows, and ownership boundaries. |
| [ENVIRONMENT.md](.agents/project/ENVIRONMENT.md) | Local setup, required tools, org aliases, environment matrix, secrets handling, and bootstrap steps. |
| [SCHEMA.md](.agents/project/SCHEMA.md) | Data models, Salesforce object relationships, schema diagrams, field ownership, and data constraints. |
| [INTEGRATIONS.md](.agents/project/INTEGRATIONS.md) | API connections, external systems, named credentials, payload contracts, and integration constraints. |
| [GLOSSARY.md](.agents/project/GLOSSARY.md) | Domain vocabulary, business terms, certified datasets, project jargon, and naming constraints. |
| [SPECIFICATION.md](.agents/project/SPECIFICATION.md) | Requirement validity rules, accepted sources, functional assumptions, and client-specific overrides. |
| [PRODUCT_REQUIREMENTS.md](.agents/project/PRODUCT_REQUIREMENTS.md) | Product requirement documents, business goals, user stories, acceptance criteria, and product constraints. |
| [TECHNICAL_REQUIREMENTS.md](.agents/project/TECHNICAL_REQUIREMENTS.md) | Technical requirements, non-functional constraints, platform dependencies, and technical acceptance criteria. |
| [USER_EXPERIENCE.md](.agents/project/USER_EXPERIENCE.md) | App flows, user journeys, design decisions, branding, content rules, and UX constraints. |

## Prime Directive

Understand the requested scope before acting. Make the smallest correct change, preserve unrelated work, and stop for human confirmation before any action that changes an org, shared branch, deployment state, credentials, secrets, production data, or irreversible local state.

The [Org] Salesforce best-practice baseline applies across projects unless the client or project documentation explicitly defines a different standard.

When Salesforce curated agent skills are available, use them as workflow references and routing patterns, but apply this repository's confirmation gates, [Org] conventions, and PMD rules first.

## Default Work Pattern

1. Inspect the current branch and working tree.
2. Read the ticket, requirement, issue, or user instruction before reading implementation details.
3. Compare the requested change against the current source and, when allowed, the target Salesforce org.
4. State the intended files, metadata, and validation approach before editing when the change is non-trivial.
5. Keep edits scoped to the requested behavior.
6. Run the narrowest meaningful local checks available.
7. Report exact changed files, checks run, known risks, and any required manual follow-up.

## Never Assume

- Never assume the local source is newer than the Salesforce org.
- Never assume a deploy, validation, commit, merge, destructive change, data mutation, or permission change is allowed unless the user explicitly approved that action in the current task.
- Never assume generated logs, `.sf`, `.sfdx`, scratch files, retrieved metadata, or package manifests are intended for commit.
- Never broaden a ticket because adjacent code looks imperfect.
- Never expose secrets, access tokens, customer data, org credentials, private keys, or personally identifiable information in chat, commits, logs, tickets, or generated files.

## Manual Confirmation Summary

Human confirmation is required before:

- `sf project deploy start`, quick deploy, destructive deploy, retrieve that overwrites tracked files, or any command that changes Salesforce org metadata or data.
- `git commit`, `git push`, merge, rebase, branch deletion, worktree deletion, reset, restore of user changes, or force operations.
- Running anonymous Apex, data load, data update, data delete, permission assignment, user change, profile or permission set assignment.
- Changing authentication, SSO, named credentials, connected apps, remote site settings, certificates, secrets, encryption, or integration endpoints.
- Installing dependencies, updating package managers, changing CI/CD config, or executing networked scripts.

Dry-run deploys, deploy validations, and Apex test runs may be executed without additional confirmation unless the user explicitly requested strict read-only analysis or no org calls.

For detailed gates, see [Manual confirmation gates](.agents/directives/MANUAL_CONFIRMATION_GATES.md).
