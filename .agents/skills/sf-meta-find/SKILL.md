---
name: sf-meta-find
description: "Help users discover and select the right Salesforce skill for their task. Lists all available Salesforce development skills with descriptions and usage examples. Use when a user asks "what skills are available", "help me with Salesforce", "which skill should I use", or seems unsure which Salesforce skill to invoke."
metadata:
  version: "1.0"
  cloud: "Meta"
  synthesized: true
  sources:
    - Clientell-Ai/salesforce-skills :: sf-find
---

# sf-meta-find: Skill Discovery

| Field | Value |
| --- | --- |
| Skill ID | `sf-meta-find` |
| Cloud | Meta |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | Clientell-Ai/salesforce-skills :: sf-find |

You help users find the right Salesforce skill for their task.

## Available Skills

| Skill | Use When You Need To... | Invoke With |
|-------|------------------------|-------------|
| **sf-platform-apex** | Write or review Apex classes, triggers, batch jobs | `/sf-platform-apex` |
| **sf-platform-test** | Generate test classes, improve coverage, fix tests | `/sf-platform-test` |
| **sf-platform-flow** | Create Flows, migrate Process Builders | `/sf-platform-flow` |
| **sf-platform-lwc** | Build Lightning Web Components with Jest tests | `/sf-platform-lwc` |
| **sf-platform-soql** | Write or optimize SOQL queries | `/sf-platform-soql` |
| **sf-security-audit** | Audit code for security vulnerabilities | `/sf-security-audit` |
| **sf-platform-deploy** | Deploy code, troubleshoot deployment errors, CI/CD | `/sf-platform-deploy` |
| **sf-platform-data** | Migrate data, seed sandboxes, bulk operations | `/sf-platform-data` |
| **sf-platform-schema** | Create objects, fields, tabs, apps, and metadata XML | `/sf-platform-schema` |
| **sf-platform-debug** | Analyze debug logs, troubleshoot errors, profile performance | `/sf-platform-debug` |
| **sf-agentforce-build** | Build Agentforce agents, topics, actions, Agent Scripts | `/sf-agentforce-build` |
| **sf-platform-permissions** | Audit permissions, manage permission sets, diagnose access | `/sf-platform-permissions` |
| **sf-integration-config** | Configure Named Credentials, Connected Apps, OAuth, Platform Events | `/sf-integration-config` |
| **sf-platform-docs** | Find official Salesforce documentation, Trailhead resources, release notes | `/sf-platform-docs` |
| **sf-tooling-diagram** | Generate Mermaid ERDs, class diagrams, sequence diagrams from metadata | `/sf-tooling-diagram` |
| **sf-omnistudio-build** | OmniStudio: OmniScripts, FlexCards, Integration Procedures, Data Mappers | `/sf-omnistudio-build` |
| **sf-meta-eval** | Benchmark skill quality, compare with/without skills | `/sf-meta-eval` |
| **agentic-requirement-discovery** | Clarify ambiguous requirements, office-hours questions, specs | `/agentic-requirement-discovery` |
| **agentic-plan-review** | Review implementation plans from product, engineering, design, security, QA, rollout angles | `/agentic-plan-review` |
| **agentic-root-cause** | Investigate non-Salesforce-specific failures before selecting a fix | `/agentic-root-cause` |
| **agentic-code-review** | Run skeptical second-opinion review and ship-readiness checks | `/agentic-code-review` |
| **agentic-design-review** | Review UX flows, visual hierarchy, states, and UI evidence before Salesforce-specific SLDS validation | `/agentic-design-review` |
| **agentic-devex-review** | Review developer onboarding, tooling, setup, docs friction, and workflow ergonomics | `/agentic-devex-review` |
| **agentic-qa** | Build QA matrices, regression checks, canary/health/benchmark evidence | `/agentic-qa` |
| **agentic-documentation** | Generate source-grounded docs and release notes | `/agentic-documentation` |
| **agentic-context-handoff** | Save/restore context, durable lessons, and retro handoffs | `/agentic-context-handoff` |
| **agentic-diagram** | Create generic Mermaid diagrams or diagram-ready explanations from source-grounded facts | `/agentic-diagram` |
| **agentic-skill-eval** | Evaluate generic skill quality and compare model/review outputs | `/agentic-skill-eval` |

## Decision Guide

1. **Writing Apex code?** Use `sf-platform-apex` for classes/triggers, `sf-platform-lwc` for components
2. **Need tests?** Use `sf-platform-test`; it reads your class and generates comprehensive tests
3. **Building automation?** Use `sf-platform-flow` for Flow XML generation and PB migration
4. **Querying data?** Use `sf-platform-soql` for optimized, secure queries
5. **Ready to deploy?** Use `sf-platform-deploy` for orchestrated deployments with error diagnosis
6. **Pre-review check?** Use `sf-security-audit` for AppExchange security audit
7. **Setting up schema?** Use `sf-platform-schema` for metadata XML generation
8. **Loading data?** Use `sf-platform-data` for migration, seeding, and bulk operations
9. **Debugging issues?** Use `sf-platform-debug` for log analysis and governor limit troubleshooting; add `agentic-root-cause` for broader failure investigation
10. **Building AI agents?** Use `sf-agentforce-build` for Agentforce agents, topics, and actions
11. **Permission problems?** Use `sf-platform-permissions` for access auditing and permission set management
12. **Setting up integrations?** Use `sf-integration-config` for Named Credentials, OAuth, Platform Events
13. **Need Salesforce docs?** Use `sf-platform-docs` to find the right documentation
14. **Visualizing architecture?** Use `sf-tooling-diagram` for Salesforce metadata-grounded diagrams; use `agentic-diagram` for non-Salesforce diagrams
15. **Working with OmniStudio?** Use `sf-omnistudio-build` for OmniScripts, FlexCards, Integration Procedures
16. **Evaluating skills?** Use `sf-meta-eval` for Salesforce skill benchmarking and `agentic-skill-eval` for generic skill-quality evaluation
17. **Requirement or plan unclear?** Use `agentic-requirement-discovery` and `agentic-plan-review` before selecting a build skill

## Prerequisites

All skills require:
- Salesforce CLI v2+ (`sf`)
- Authenticated org (`sf org login web --alias myOrg`)

Recommend the most relevant skill based on the user's description and offer to invoke it.
