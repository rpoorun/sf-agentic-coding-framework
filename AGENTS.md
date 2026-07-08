# AI Agent Operating Guide

| Field | Value |
| --- | --- |
| Framework | sf-agentic-coding-framework |
| Version | 0.1.2 |
| Author | Rishikesh Poorun |
| Master repository | https://github.com/rpoorun/sf-agentic-coding-framework |
| Last updated | 2026-07-08 |
| License | Apache License 2.0 |

## Framework Location

This framework uses a **local-first, user-level architecture** with fallbacks for sandboxed and remote-hosted agents. There are three contexts:

1. **Master framework repository** (this repo, `sf-agentic-coding-framework`): contains the full `.agents/` source tree — directives, standards, skills, workflows, and CHANGELOG. This is the canonical source from which installs are cloned. Do not run migration, do not delete `.agents/` folders, do not treat this repo as a local install.
2. **Installed project repository** (a Salesforce project using this framework): contains only `AGENTS.md` (routing document) and `.agents/project/` (team-shared docs). All framework files are installed at the user level.
3. **User-level runtime install** (`{USER_AGENTS}/`): shared framework files (directives, standards, skills, workflows) installed once per machine. Per-repo state (credentials, tickets, board, temp data) is stored in a repo-named subdirectory, persisting across branches and sessions.

| Shorthand | Unix/macOS | Windows | Purpose |
| --- | --- | --- | --- |
| `{USER_AGENTS}` | `~/.agents/` | `%USERPROFILE%\.agents\` | User-level framework root |
| `{USER_AGENTS}/{repo_name}/` | `~/.agents/{repo_name}/` | `%USERPROFILE%\.agents\{repo_name}\` | Per-repo persistent state |
| `{REPO_STATE}` | resolved via chain (see below) | resolved via chain (see below) | Per-repo project state (tickets, board, config) — first writable tier of the state chain |

`{repo_name}` is derived from `basename "$(git rev-parse --show-toplevel)"`.

### Layered Resolution

The user-level path is the **preferred** location for local developer agents but must not be assumed unconditionally. Sandboxed agents (e.g. Codex, cloud-hosted CI agents) may not have write access to `{USER_AGENTS}` or may run in ephemeral containers. The framework resolves locations using the following fallback chains.

**Framework files lookup order:**

| Priority | Location | When to use |
| --- | --- | --- |
| 1 | `SF_AGENTIC_FRAMEWORK_HOME` env var | Explicit override — set by CI, containers, or custom tooling |
| 2 | `{USER_AGENTS}/` (`~/.agents/` or `%USERPROFILE%\.agents\`) | Local developer machines (default) |
| 3 | Repo-local `.agents/` | Master framework repository, or sandboxed agents that cannot write to user-level paths |

Use the first readable location. If none is available, the agent should inform the user and offer to run bootstrap.

**Credential lookup order:**

| Priority | Source | When to use |
| --- | --- | --- |
| 1 | Hosted/CI secret manager or platform-provided credentials | Remote agents, CI pipelines, managed platforms |
| 2 | Environment variables (`JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`, etc.) | Containers, sandboxed agents, automation scripts |
| 3 | OS keychain or platform secret store | Desktop agents with keychain integration |
| 4 | `{USER_AGENTS}/{repo_name}/.local-config.json` | Local developer machines (plaintext convenience — acceptable only for local use) |
| 5 | Interactive prompt | Last resort when no credentials are pre-configured |

Never assume plaintext JSON credentials are available. If the agent is running in a hosted or sandboxed environment, prefer higher-priority sources.

**Temp/output location:**

| Priority | Location | When to use |
| --- | --- | --- |
| 1 | `{USER_AGENTS}/{repo_name}/temp/` | Local developer machines |
| 2 | Agent-provided writable workspace or platform temp path | Sandboxed/remote agents |
| 3 | Repo-local `.agents/temp/` (gitignored) | Fallback when neither of the above is writable |

**Per-repo project state location** (`{REPO_STATE}` — ticket files, board lanes, per-repo config):

| Priority | Location | When to use |
| --- | --- | --- |
| 1 | `SF_AGENTIC_FRAMEWORK_HOME/{repo_name}/` | When the env var override is set |
| 2 | `{USER_AGENTS}/{repo_name}/` | Local developer machines (default) |
| 3 | Agent-provided persistent workspace/state path | Hosted agents that expose a durable state directory |
| 4 | Repo-local `.agents/state/` (gitignored) | Last resort when no external writable state location exists |

Write `{REPO_STATE}` in workflow instructions to mean "the first writable location in this chain". State stored in tiers 3–4 persists only as long as the hosting environment persists it — do not promise cross-session or cross-sandbox persistence unless tier 1 or 2 resolved.

Never assume `{USER_AGENTS}` is writable — probe before writing and fall back gracefully.

## Purpose And Use

`AGENTS.md` is the first file AI-assisted coding agents must read in this repository. It is the **router** that points to framework files — either at `{USER_AGENTS}/` (in an installed project) or at `.agents/` (in the master framework repository itself). Use it before changing source, metadata, documentation, org state, or Git state.

**In the master framework repository** (`sf-agentic-coding-framework`): framework files are read directly from `.agents/` — the same paths that `{USER_AGENTS}/` would resolve to in a local install. Do not run migration, bootstrap, or delete framework source folders.

**In an installed project repository**: if the framework is not resolvable via the [Layered Resolution](#layered-resolution) chain, or `{USER_AGENTS}/{repo_name}/` does not exist for this repo, or `.agents/project/*` is still empty/boilerplate, run [Project Bootstrap]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md) before other work — it initialises the user-level directory (or configures the appropriate fallback), creates the per-repo state, and interviews the user to populate org, VCS, team, and process facts. Also run the [Daily Update Check]({USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) once per calendar day to see whether the master repository has a newer framework version.

## Project Guidance

- For instruction-file maintenance, start with `{USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md`.
- For requirement analysis, read [Specification rules](.agents/project/SPECIFICATION.md) before implementation feasibility.
- For Salesforce source work, read [Project structure](.agents/project/PROJECT_STRUCTURE.md), `{USER_AGENTS}/standards/SALESFORCE_PROJECT_BEST_PRACTICES.md`, and the relevant workflow file.
- For Apex work, read `{USER_AGENTS}/standards/SALESFORCE_APEX_STANDARDS.md` and `{USER_AGENTS}/standards/PMD_APEX_RULESET.md`.
- For tool or skill routing, read `{USER_AGENTS}/skills/SALESFORCE_SKILLS.md`.
- For writing or updating project technical documentation (`docs/` describing implemented Apex, LWC, or config), read `{USER_AGENTS}/standards/DOCUMENTATION.md` first — never document anything without verifying it against source per that file.
- For Jira setup or ticket fetching, read `{USER_AGENTS}/skills/jira-management/SKILL.md` and `{USER_AGENTS}/workflows/JIRA.MD`. For local ticket management, agile board, and ticket-scoped commands (`analyse`, `build`, `deploy`, `test`, `comment`), read `{USER_AGENTS}/workflows/PROJECT_TRACKING.MD` — it routes to the framework's existing workflows. To install Jira, follow the Install / Setup Flow in the Jira skill.

## Required Reading Order

All framework files below are at `{USER_AGENTS}/` unless prefixed with `.agents/` (which means they are in this repo).

1. `{USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md` — Agentic framework
2. `{USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md` — Project bootstrap (only on first install, when `.agents/project/*` is still empty)
3. `{USER_AGENTS}/directives/AGENT_GUARDRAILS.md` — Agent guardrails
4. `{USER_AGENTS}/directives/TRUST_DATA_SECURITY.md` — Trust, data, and security rules
5. `{USER_AGENTS}/directives/MANUAL_CONFIRMATION_GATES.md` — Manual confirmation gates
6. [Project structure](.agents/project/PROJECT_STRUCTURE.md) — in this repo
7. `{USER_AGENTS}/workflows/WORKFLOW.md` — Workflow
8. `{USER_AGENTS}/workflows/DEPLOYMENT.md` — Deployment workflow
9. `{USER_AGENTS}/workflows/PULL_REQUEST.md` — Pull request workflow
10. [Requirement and specification rules](.agents/project/SPECIFICATION.md) — in this repo
11. `{USER_AGENTS}/standards/SALESFORCE_PROJECT_BEST_PRACTICES.md` — Salesforce project best practices
12. `{USER_AGENTS}/skills/SALESFORCE_SKILLS.md` — Salesforce skills
13. `{USER_AGENTS}/standards/SALESFORCE_APEX_STANDARDS.md` — Salesforce Apex standards
14. `{USER_AGENTS}/standards/PMD_APEX_RULESET.md` — PMD Apex ruleset guide
15. `{USER_AGENTS}/standards/LEAN_CODE_STANDARDS.md` — Lean code standards
16. `{USER_AGENTS}/standards/APEX_TRIGGER_FRAMEWORK.md` — Apex trigger framework
17. `{USER_AGENTS}/standards/APEX_CONSTANTS_FRAMEWORK.md` — Apex constants framework
18. `{USER_AGENTS}/standards/DOCUMENTATION.md` — Documentation standards

## Documentation Layout

In the master framework repository, the full `.agents/` tree is tracked as the canonical source. In installed project repositories, the framework is split between the user-level directory and the repo:

**User-level (`{USER_AGENTS}/`)** — shared across all repos on this machine:
- `directives/` — mandatory rules agents must obey: safety, trust, confirmation, and framework governance.
- `standards/` — reusable quality expectations for Salesforce, Apex, metadata, PMD, naming, and review.
- `skills/` — capability-routing guidance and local adaptations of reusable skills or tools.
- `workflows/` — repeatable task processes such as implementation, testing, and Git/workflow handoff.
- `identity.json` — author name and email for code comment headers.
- `preferences.json` — framework version and update check state.
- `CHANGELOG.md` — per-version history of framework changes.
- `{repo_name}/` — per-repo persistent state: credentials, tickets, board, temp data.

**Repo-level (`.agents/project/`)** — project facts for this repository:
- Contains durable project facts: structure, environment, requirements, schema, integrations, glossary, and UX context.
- In an installed project repo, these files may be committed and shared with the team when the team chooses. They must never be contributed back to the master framework repository — only sanitized generic lessons extracted into directives/standards/skills/workflows may be upstreamed (see [Scenario 2](directives/AGENTIC_FRAMEWORK.md#scenario-2--forking-learned-improvements-back-to-the-master-framework-contribute-back) in AGENTIC_FRAMEWORK.md).

## Agent Framework

The governing framework for this repository's instruction files is `{USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md`. Before adding, moving, renaming, or expanding framework files, classify the content as a directive, standard, skill, workflow, or project fact and avoid duplicating an instruction already owned elsewhere.

## Installation Manifest

This section is the portable installation record. Copy this `AGENTS.md` file into any Salesforce project repository and an AI agent can bootstrap the framework into `{USER_AGENTS}/` and register all plugins. This section is not relevant when working directly in the master framework repository.

### Framework Source

| Component | Repository | Branch | Master source | Install target |
| --- | --- | --- | --- | --- |
| Core framework | https://github.com/rpoorun/sf-agentic-coding-framework | `main` | `.agents/` (directives, standards, skills, workflows, CHANGELOG) | `{USER_AGENTS}/` |

### Registered Plugins

Plugins extend the core framework with additional skills, integrations, or workflows. Each plugin is pulled from its source URL and installed under `{USER_AGENTS}/skills/` or `{USER_AGENTS}/workflows/`.

| Plugin | Source | Version | Install command | Description |
| --- | --- | --- | --- | --- |
| jira-management | https://github.com/rpoorun/sf-agentic-coding-framework | `main` | `install Jira skills` | Read-only Jira Cloud integration: ticket retrieval, ADF parsing, project prefix discovery. Delivers ticket data to the project tracking workflow. |

### Installation Procedure

To install this framework into a new or existing Salesforce project repository:

1. **Copy this file** — place `AGENTS.md` at the project repository root. Optionally create `.agents/project/` with boilerplate project doc files.
2. **Run Project Bootstrap** — on first use, the agent reads `AGENTS.md`, detects that `{USER_AGENTS}/` does not exist, and runs [Step 0a of Project Bootstrap]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md#step-0a--initialise-user-level-framework-directory) to clone the core framework's `.agents/` tree into `{USER_AGENTS}/` (one-time per machine) and [Step 0b]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md#step-0b--initialise-per-repo-directory) to create `{USER_AGENTS}/{repo_name}/` (one-time per repo).
3. **Bootstrap interview** — if `.agents/project/*` is still boilerplate, the agent runs the [Project Bootstrap]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md) interview to configure the project.
4. **Install plugins** — for each registered plugin, say its install command (e.g. `install Jira skills`). The agent follows the plugin's guided setup flow to configure credentials in `{USER_AGENTS}/{repo_name}/.local-config.json`.
5. **Daily update check** — on each subsequent session, the agent runs the [Daily Update Check]({USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) to detect newer framework versions from the core repository and update `{USER_AGENTS}/`.

### Adding a New Plugin

To register a new plugin in this manifest:

1. Add a row to the Registered Plugins table above with the plugin's source URL, version, install command, and description.
2. Create the plugin's skill folder under `{USER_AGENTS}/skills/{plugin-name}/SKILL.md` following the framework's standard skill format.
3. If the plugin adds workflows, register them in the Workflow Reference Files table below.
4. If the plugin needs local config, add a namespaced key to `{USER_AGENTS}/common/templates/.local-config.template.json` per the `_convention` block.
5. Commit the updated `AGENTS.md` so other users pulling this file get the plugin registration.

## Master Framework Repository

This framework is mirrored from a master repository: **https://github.com/rpoorun/sf-agentic-coding-framework**. The installed copy lives at `{USER_AGENTS}/`. If this install needs the latest framework updates, or has learned a generally-applicable improvement worth contributing back upstream, follow the Master Framework Repository And Sync Workflow in `{USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md` — it defines the pull/merge-with-approval procedure for updates and the isolate-and-fork procedure for contributing learned skills/instructions back, both of which require explicit user confirmation before any Git action.

## Directive Reference Files

All files in this table are at `{USER_AGENTS}/`.

| File | Intended purpose |
| --- | --- |
| `directives/AGENTIC_FRAMEWORK.md` | Governing framework for classifying, maintaining, and reusing agent instructions; also owns the daily master-repo update check and the pull/contribute-back sync workflow. |
| `CHANGELOG.md` | Per-version history of all notable framework changes; updated before every merge to `main`; relayed to the user when a newer version is detected during the daily update check. |
| `directives/AGENT_GUARDRAILS.md` | Mandatory repo-wide behavioral guardrails, source-control safety, org safety, and communication rules. |
| `directives/TRUST_DATA_SECURITY.md` | Trust boundaries, data handling, security, sanitization, logging, and mutation rules. |
| `directives/MANUAL_CONFIRMATION_GATES.md` | Actions that require human approval before proceeding. |

## Standards Reference Files

All files in this table are at `{USER_AGENTS}/standards/`.

| File | Intended purpose |
| --- | --- |
| `SALESFORCE_PROJECT_BEST_PRACTICES.md` | [Org] Salesforce baseline for naming, metadata, architecture, tests, and configuration. |
| `SALESFORCE_APEX_STANDARDS.md` | Apex class, trigger, async, security, test, and review standards. |
| `PMD_APEX_RULESET.md` | PMD Apex static-analysis guidance, command shape, suppression policy, and agent requirements. |
| `LEAN_CODE_STANDARDS.md` | Lean-coding decision ladder and token-efficient collaboration rules, refactored for Apex/LWC from general-purpose sources. |
| `APEX_TRIGGER_FRAMEWORK.md` | Mandatory `TriggerHandler` base-class pattern, recursion control, and bypass API for every Apex trigger. |
| `APEX_CONSTANTS_FRAMEWORK.md` | Mandatory `Constants`/`{SObject}Constants` singleton pattern for picklist values and other Apex constants. |
| `DOCUMENTATION.md` | How to write and maintain project technical documentation describing actual Apex, LWC, and configuration — source-verification rules, doc-tree structure, style, and content inclusion/exclusion. |

## Skill Reference Files

All files in this table are at `{USER_AGENTS}/skills/`.

| File | Intended purpose |
| --- | --- |
| `SALESFORCE_SKILLS.md` | Naming convention, synthesis procedure, and routing rules for the `sf-{cloud}-{name}` agent skills. |
| `jira-management/SKILL.md` | Read-only Jira Cloud API integration: credential setup, ticket retrieval, ADF parsing, and project prefix discovery. Activate on "install Jira skills" or `fetch {KEY}`. Does not own local tracking, analysis, or deployment — those are handled by `{USER_AGENTS}/workflows/PROJECT_TRACKING.MD` and the framework's existing workflows. |

## Workflow Reference Files

All files in this table are at `{USER_AGENTS}/workflows/`.

| File | Intended purpose |
| --- | --- |
| `PROJECT_BOOTSTRAP.md` | First-install: initialises user-level framework directory, per-repo state, and interview (org, VCS, team, release process) that populates `.agents/project/*` when it is still empty boilerplate. |
| `WORKFLOW.md` | Git workflow, task flow, branch conventions, PR expectations, and release handoff process. |
| `DEPLOYMENT.md` | Mandatory pre-deploy org-conflict check/merge and the 95% Apex coverage gate for every sandbox/org deploy, dry-run included. |
| `PULL_REQUEST.md` | Pull request template usage, final commit, back-merge, and review-readiness checklist. |
| `TESTING.md` | Verification protocols, test commands, mocking strategies, coverage expectations, and acceptance checks. |
| `IMPLEMENTATION_PLAN.md` | Delivery sequencing, dependency ordering, implementation planning, rollout steps, and open task tracking. |
| `JIRA.MD` | Jira fetch workflow: the single Jira-facing operation that retrieves a ticket and delivers parsed data to project tracking. |
| `PROJECT_TRACKING.MD` | Local ticket management: ticket files at `{USER_AGENTS}/{repo_name}/project/tickets/`, agile board, and ticket-scoped command routing (`analyse`, `build`, `deploy`, `test`, `comment`) that delegates to the framework's existing workflows. |

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

Nine mandatory behavioral rules govern every prompt, every task, every session — defined in full in `{USER_AGENTS}/directives/AGENT_GUARDRAILS.md` (Prime Directives section). In summary:

1. **Never execute a prompt verbatim** — interpret intent, not literal words.
2. **Understand context before acting** — know the problem, the codebase state, and what already exists.
3. **Decompose and question** — is this truly required? Does a simpler or declarative alternative exist?
4. **Prefer existing and standard implementations** — search the codebase and platform before generating custom code.
5. **Never assume** — if anything is ambiguous, stop and ask.
6. **Pre-generation gate** — before generating any file, present open questions and at least two alternatives with pros/cons; wait for the user to choose before proceeding.
7. **Conflict verification before any deploy** — retrieve and diff org state against local source; never overwrite org-side changes without explicit user acknowledgement.
8. **Persist user decisions** — durable decisions made during a session should be proposed for storage in the appropriate `.agents` file before the session moves on.
9. **Iteration tracking in memory only** — track how many times each file has been generated or modified in the session; never write iteration numbers into files or file names.

Make the smallest correct change, preserve unrelated work, and stop for human confirmation before any action that changes an org, shared branch, deployment state, credentials, secrets, production data, or irreversible local state.

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

For detailed gates, see `{USER_AGENTS}/directives/MANUAL_CONFIRMATION_GATES.md`.

## Acknowledgements And Sources

This framework's skills and standards content is built by synthesizing, refactoring, or vendoring (with attribution) the open-source work of the following projects. See `{USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md` (Installing This Framework section) for how each one was used and how to re-pull updates.

| Source | Author / Org | Used for |
| --- | --- | --- |
| [forcedotcom/sf-skills](https://github.com/forcedotcom/sf-skills) | Salesforce | Primary source for most `sf-platform-*`, `sf-design-*`, `sf-dx-*`, `sf-agentforce-*`, `sf-omnistudio-*`, `sf-integration-*`, `sf-tooling-*` skills — synthesized and renamed to this framework's `sf-{cloud}-{name}` convention. |
| [Clientell-Ai/salesforce-skills](https://github.com/Clientell-Ai/salesforce-skills) | Clientell | Secondary/merged source for the same skills above (`sf-apex`, `sf-test`, `sf-flow`, `sf-lwc`, `sf-soql`, `sf-deploy`, `sf-data`, `sf-schema`, `sf-debug`, `sf-agentforce`, `sf-permissions`, `sf-integration`, `sf-docs`, `sf-diagram`, `sf-omnistudio`, `sf-find`, `sf-eval`, `sf-security`) — merged into the same synthesized skills, plus the sole source for `sf-security-audit`. |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | Dietrich Gebert | Source doctrine (refactored, not copied) for the lean-coding decision ladder in `{USER_AGENTS}/standards/LEAN_CODE_STANDARDS.md`. |
| [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Julius Brussee | Source doctrine (refactored, not copied) for the token-efficient communication and surgical-diff rules in `{USER_AGENTS}/standards/LEAN_CODE_STANDARDS.md`. |
| [kevinohara80/sfdc-trigger-framework](https://github.com/kevinohara80/sfdc-trigger-framework) | Kevin M. O'Hara | `TriggerHandler` base class vendored verbatim (MIT License) — see `{USER_AGENTS}/standards/APEX_TRIGGER_FRAMEWORK.md`. |
| [beyond-the-cloud-dev/apex-consts](https://github.com/beyond-the-cloud-dev/apex-consts) | Beyond The Cloud | `Constants`/`{SObject}Constants` pattern (MIT License), adapted with every class renamed from the upstream `Consts` abbreviation to the full word `Constants` — see `{USER_AGENTS}/standards/APEX_CONSTANTS_FRAMEWORK.md`. |

If you maintain one of these projects and want attribution adjusted, or you maintain a project this framework should credit and currently doesn't, open an issue or PR against [rpoorun/sf-agentic-coding-framework](https://github.com/rpoorun/sf-agentic-coding-framework).
