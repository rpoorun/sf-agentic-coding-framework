# AI Agent Operating Guide

| Field | Value |
| --- | --- |
| Framework | sf-agentic-coding-framework |
| Version | 0.2.0 |
| Author | Rishikesh Poorun |
| Master repository | https://github.com/rpoorun/sf-agentic-coding-framework |
| Last updated | 2026-07-16 |
| License | Apache License 2.0 |

## Framework Location

This framework uses a **three-tier architecture** — user level, project level, and repo level — with fallbacks for sandboxed and remote-hosted agents:

1. **User level** (`{USER_AGENTS}/`): the general working framework, installed or updated once per machine. Holds everything reusable across all projects — common directives, general workflows, cross-project skills (generic, parameterized, self-contained), general development/deployment instructions, standards and conventions, routing instructions, user-level credentials, and user-level environment variables/configuration.
2. **Project level** (`{PROJECT_AGENTS}` = `{USER_AGENTS}/{PROJECT_NAME}/`): everything specific to one project but shared across all of its repos, branches, and worktrees — project-specific instructions, workflows, directives, skill helpers, project credentials and per-environment configuration (dev/uat/staging/prod), glossaries and naming conventions that are author-specific, decision records, and the agile/scrum project management state (tickets, board, tracking).
3. **Repo level** (repo-root `.agents/`): repo-, branch-, or feature-specific instructions, workflows, and skillsets, plus the team-shared project documentation — kept on the default branch and shared to other branches and teammates via git.

Two additional contexts qualify the tiers:

- **Master framework repository** (this repo, `sf-agentic-coding-framework`): contains the full `.agents/` source tree — directives, standards, skills, workflows, documentation templates, and CHANGELOG. This is the canonical source from which installs are cloned. Do not run migration, do not delete `.agents/` folders, do not treat this repo as a local install.
- **Installed project repository** (a Salesforce project using this framework): contains only `AGENTS.md` (routing document) and the repo-level `.agents/` content (team-shared documentation and any repo-specific workflows/skills) as committed content. In constrained environments, gitignored `.agents/temp/` and `.agents/state/` fallback directories may additionally exist locally — they are never committed.

All three tiers share the **same subfolder organization**: `directives/`, `standards/`, `documentation/`, `workflows/`, `skills/`, and `project/` (configurations, credentials, parameters, and variables for that tier). The project tier additionally holds project management state (`project/tickets/`, `project/board/`), accessible from any repo, branch, state, or worktree of the project.

| Shorthand | Unix/macOS | Windows | Purpose |
| --- | --- | --- | --- |
| `{USER_AGENTS}` | `~/.agents/` | `%USERPROFILE%\.agents\` | User-level framework root |
| `{PROJECT_AGENTS}` | `~/.agents/{PROJECT_NAME}/` | `%USERPROFILE%\.agents\{PROJECT_NAME}\` | Project-level root (state, credentials, tickets, board, helpers) — resolved via the project state chain below |
| `{AGENTS_TEMP}` | `$TMPDIR/.agents/{PROJECT_NAME}/` (or `/tmp/...`) | `%TEMP%\.agents\{PROJECT_NAME}\` | Transient data — in the OS temp directory so the platform owns cleanup |

`{PROJECT_NAME}` is the repository name from the git remote URL — e.g. `https://github.com/rpoorun/rehlko-dtt.git` → `rehlko-dtt` (Bash: `basename -s .git "$(git remote get-url origin)"`; PowerShell: `[IO.Path]::GetFileNameWithoutExtension((git remote get-url origin))`). Repos of the same project that share that remote name share one project tier. If no git remote is available, ask the user for the project name in chat and persist the answer in the repo-level `.agents/project/` configuration so future sessions reuse it.

**Cross-platform notes**: `{USER_AGENTS}` resolves per OS — `%USERPROFILE%\.agents\` on Windows (PowerShell: `Join-Path $env:USERPROFILE '.agents'`), `$HOME/.agents/` on macOS and Linux — and `SF_AGENTIC_FRAMEWORK_HOME` overrides on all three. `{AGENTS_TEMP}` resolves to the platform temp directory — `%TEMP%` on Windows, `$TMPDIR` on macOS, `$TMPDIR` or `/tmp` on Linux — always with the `.agents/{PROJECT_NAME}/` suffix, irrespective of the system. `{PROJECT_NAME}` derivation is identical everywhere, so the project folder name matches across machines. The user-level install is **per machine and per OS user profile**: the same repo on a second machine (or in WSL, which has its own `$HOME` separate from its Windows host) bootstraps its own install, and user/project-level state does not sync between machines — Jira is the sync source for tickets; anything that must travel with the repo belongs in committed repo-level `.agents/` content. On Linux, filesystem paths and links are case-sensitive — all framework files use lowercase `.md` extensions and cross-references must match filename case exactly.

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
| 4 | `{PROJECT_AGENTS}/project/.local-config.json` | Local developer machines (plaintext convenience — acceptable only for local use) |
| 5 | Interactive prompt | Last resort when no credentials are pre-configured |

Never assume plaintext JSON credentials are available. If the agent is running in a hosted or sandboxed environment, prefer higher-priority sources.

**Credential tier rules**: credentials are **never stored at repo level** — the sole exception is a plain identifier (never a secret) that the user explicitly asked to store in the repo, and only after a second confirmation in chat. System-wide credentials unrelated to any one project or repo (e.g. a personal Jira token) live at the user tier (`{USER_AGENTS}/project/`). Project-specific connections and credentials live at the project tier (`{PROJECT_AGENTS}/project/`), where they may be further segregated per environment — e.g. `{PROJECT_AGENTS}/project/environments/{development|uat|staging|production}/` — so the same skill or workflow can target a chosen environment by parameter.

**Temp/output location** (`{AGENTS_TEMP}` — the first writable tier). Temp data lives in the **OS temp directory**, not in the user folder or the repo, so the platform's own cleanup handles transient files and they never pollute durable tiers:

| Priority | Location | When to use |
| --- | --- | --- |
| 1 | `{OS temp}/.agents/{PROJECT_NAME}/` — `%TEMP%\.agents\{PROJECT_NAME}\` (Windows), `$TMPDIR/.agents/{PROJECT_NAME}/` (macOS), `$TMPDIR` or `/tmp/.agents/{PROJECT_NAME}/` (Linux) | Default on every platform |
| 2 | Agent-provided writable workspace or platform temp path | Sandboxed/remote agents |
| 3 | Repo-local `.agents/temp/` (gitignored) | Fallback when neither of the above is writable |

**Project state location** (`{PROJECT_AGENTS}` — ticket files, board lanes, project config/credentials, developer environment, project-specific workflows/directives/skill helpers — shared by every repo, branch, and worktree of the project):

| Priority | Location | When to use |
| --- | --- | --- |
| 1 | `SF_AGENTIC_FRAMEWORK_HOME/{PROJECT_NAME}/` | When the env var override is set |
| 2 | `{USER_AGENTS}/{PROJECT_NAME}/` | Local developer machines (default) |
| 3 | Agent-provided persistent workspace/state path | Hosted agents that expose a durable state directory |
| 4 | Repo-local `.agents/state/` (gitignored) | Last resort when no external writable state location exists |

Write `{PROJECT_AGENTS}` in workflow instructions to mean "the first writable location in this chain". State stored in tiers 3–4 persists only as long as the hosting environment persists it — do not promise cross-session or cross-sandbox persistence unless tier 1 or 2 resolved. Note that `SF_AGENTIC_FRAMEWORK_HOME` may point to a read-only mount (e.g. in CI) — that satisfies the framework-files chain but not this one; when tier 1 is not writable, fall through to the next writable tier rather than failing.

Never assume `{USER_AGENTS}` is writable — probe before writing and fall back gracefully.

**Tier precedence for workflows and directives**: `{PROJECT_AGENTS}/workflows/` and `{PROJECT_AGENTS}/directives/` hold workflows and directives that apply to this project only; repo-level `.agents/workflows/` and `.agents/directives/` (when present in an installed repo) hold instructions specific to this repo, branch, or feature. When a file shares its name across tiers, the most specific tier wins: repo overrides project, project overrides user; otherwise all apply (the specific tier extends the generic base). Project-level workflows also orchestrate how project-tier skill helpers are consumed and sequenced. Sanitized generic lessons may be upstreamed per Scenario 2 in AGENTIC_FRAMEWORK.md.

**Skills across tiers**: skills and skillsets are always **installed at the user tier** (`{USER_AGENTS}/skills/`), generic, parameterized, and fully self-contained — each skill folder carries all its instructions, JSON schemas, callout guardrails, samples, documentation, object structures, scripts, auto/manual update instructions, and live repo references, so the skill is independent of any project specification and exportable as-is. At the project tier, a same-named folder `{PROJECT_AGENTS}/skills/{skill-name}/` holds the implementation instructions for that project, labelled `{SKILL_NAME}_HELPER.md` — the helper bridges the user-tier skill's invocables with the project-tier environments and credentials (`{PROJECT_AGENTS}/project/`). Repo-level `.agents/skills/` may add repo- or feature-specific skillsets shared via git.

## Purpose And Use

`AGENTS.md` is the first file AI-assisted coding agents must read in this repository. It is the **router** that points to framework files — either at `{USER_AGENTS}/` (in an installed project) or at `.agents/` (in the master framework repository itself). Use it before changing source, metadata, documentation, org state, or Git state.

**In the master framework repository** (`sf-agentic-coding-framework`): framework files are read directly from `.agents/` — the same paths that `{USER_AGENTS}/` would resolve to in a local install. Do not run migration, bootstrap, or delete framework source folders.

**In an installed project repository**: if the framework is not resolvable via the [Layered Resolution](#layered-resolution) chain, or `{PROJECT_AGENTS}` does not exist for this project, or `.agents/documentation/*` is still empty/boilerplate, run [Project Bootstrap]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md) before other work — it initialises the framework location (user-level or the appropriate fallback), creates the project-level state at the first writable `{PROJECT_AGENTS}` tier, and interviews the user to populate org, VCS, team, and process facts. Also run the [Daily Update Check]({USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) once per calendar day to see whether the master repository has a newer framework version.

## Project Guidance

- For instruction-file maintenance, start with `{USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md`.
- For requirement analysis, read [Specification rules](.agents/documentation/SPECIFICATION.md) before implementation feasibility.
- For Salesforce source work, read [Project structure](.agents/documentation/PROJECT_STRUCTURE.md), `{USER_AGENTS}/standards/SALESFORCE_PROJECT_BEST_PRACTICES.md`, and the relevant workflow file.
- For Apex work, read `{USER_AGENTS}/standards/SALESFORCE_APEX_STANDARDS.md` and `{USER_AGENTS}/standards/PMD_APEX_RULESET.md`.
- For tool or skill routing, read `{USER_AGENTS}/skills/SALESFORCE_SKILLS.md`.
- For writing or updating project technical documentation (`docs/` describing implemented Apex, LWC, or config), read `{USER_AGENTS}/standards/DOCUMENTATION.md` first — never document anything without verifying it against source per that file.
- For Jira setup or ticket fetching, read `{USER_AGENTS}/skills/jira-management/SKILL.md` and `{USER_AGENTS}/workflows/JIRA.md`. For local ticket management, agile board, and ticket-scoped commands (`analyse`, `build`, `deploy`, `test`, `comment`), read `{USER_AGENTS}/workflows/PROJECT_TRACKING.md` — it routes to the framework's existing workflows. To install Jira, follow the Install / Setup Flow in the Jira skill.

## Required Reading Order

All framework files below are at `{USER_AGENTS}/` unless prefixed with `.agents/` (which means they are in this repo).

1. `{USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md` — Agentic framework
2. `{USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md` — Project bootstrap (only on first install, when `.agents/documentation/*` is still empty)
3. `{USER_AGENTS}/directives/AGENT_GUARDRAILS.md` — Agent guardrails
4. `{USER_AGENTS}/directives/TRUST_DATA_SECURITY.md` — Trust, data, and security rules
5. `{USER_AGENTS}/directives/MANUAL_CONFIRMATION_GATES.md` — Manual confirmation gates
6. [Project structure](.agents/documentation/PROJECT_STRUCTURE.md) — in this repo
7. `{USER_AGENTS}/workflows/WORKFLOW.md` — Workflow
8. `{USER_AGENTS}/workflows/DEPLOYMENT.md` — Deployment workflow
9. `{USER_AGENTS}/workflows/DEVELOPMENT_GATE.md` — Development gate (pre-manifest / pre-deploy self-checklist)
10. `{USER_AGENTS}/workflows/PULL_REQUEST.md` — Pull request workflow
11. [Requirement and specification rules](.agents/documentation/SPECIFICATION.md) — in this repo
12. `{USER_AGENTS}/standards/SALESFORCE_PROJECT_BEST_PRACTICES.md` — Salesforce project best practices
13. `{USER_AGENTS}/skills/SALESFORCE_SKILLS.md` — Salesforce skills
14. `{USER_AGENTS}/standards/SALESFORCE_APEX_STANDARDS.md` — Salesforce Apex standards
15. `{USER_AGENTS}/standards/PMD_APEX_RULESET.md` — PMD Apex ruleset guide
16. `{USER_AGENTS}/standards/LEAN_CODE_STANDARDS.md` — Lean code standards
17. `{USER_AGENTS}/standards/APEX_TRIGGER_FRAMEWORK.md` — Apex trigger framework
18. `{USER_AGENTS}/standards/APEX_CONSTANTS_FRAMEWORK.md` — Apex constants framework
19. `{USER_AGENTS}/standards/DOCUMENTATION.md` — Documentation standards

## Documentation Layout

In the master framework repository, the full `.agents/` tree is tracked as the canonical source. In installed project repositories, the framework is split across the three tiers. All tiers share the same subfolder shape (`directives/`, `standards/`, `documentation/`, `workflows/`, `skills/`, `project/`); what differs is scope:

**User level (`{USER_AGENTS}/`)** — shared across all projects on this machine:
- `directives/` — mandatory rules agents must obey: safety, trust, confirmation, and framework governance.
- `standards/` — reusable quality expectations for Salesforce, Apex, metadata, PMD, naming, and review.
- `skills/` — generic, parameterized, self-contained skills and skillsets (see [Skills across tiers](#layered-resolution)) plus capability-routing guidance.
- `workflows/` — repeatable task processes such as implementation, testing, and Git/workflow handoff.
- `documentation/` — user-level (author-specific) notes that belong to no single project.
- `project/` — user-level configuration: system-wide credentials, environment variables, and parameters not tied to any project.
- `identity.json` — author name and email for code comment headers.
- `preferences.json` — framework version and update check state.
- `CHANGELOG.md` — per-version history of framework changes.
- `{PROJECT_NAME}/` — one project-level tier per project (see below).

**Project level (`{PROJECT_AGENTS}` = `{USER_AGENTS}/{PROJECT_NAME}/`)** — shared across all repos, branches, and worktrees of one project:
- `directives/`, `standards/`, `workflows/` — project-specific instructions; same-named files override their user-level counterparts for this project.
- `skills/{skill-name}/{SKILL_NAME}_HELPER.md` — per-skill implementation helpers bridging user-tier skills to this project's environments and credentials.
- `documentation/` — machine- or developer-specific project documentation (e.g. meeting notes) that should not be committed.
- `project/` — project configuration: `.local-config.json` (credentials), per-environment config (`environments/{dev|uat|staging|production}/`), this developer's `ENVIRONMENT.md` (org aliases and env facts — per developer, never shared), parameters, and variables.
- `project/tickets/`, `project/board/` — agile/scrum project management: local ticket files, board lanes, and tracking, accessible from within any repo of the project regardless of branch, state, or worktree.

**Repo level (`.agents/`)** — committed to the repo, shared with the team via git (maintained on the default branch, flowing to feature branches):
- `documentation/` — durable, team-shared project facts: structure, environment template, requirements, schema, integrations, glossary, and UX context. Documentation lives at repo level **because it is shared**; only machine- or author-specific documents (meeting notes and the like) stay at the project or user tier.
- `workflows/`, `skills/`, `directives/`, `standards/` (optional) — repo-, branch-, or feature-specific instructions and skillsets; the most specific tier wins on name collisions.
- `project/` — non-secret repo configuration (e.g. the persisted `{PROJECT_NAME}` when no git remote exists). **Never credentials** — see the credential tier rules under [Layered Resolution](#layered-resolution).
- These files may be committed and shared with the team when the team chooses. They must never be contributed back to the master framework repository — only sanitized generic lessons extracted into directives/standards/skills/workflows may be upstreamed (see [Scenario 2](.agents/directives/AGENTIC_FRAMEWORK.md#scenario-2--forking-learned-improvements-back-to-the-master-framework-contribute-back) in AGENTIC_FRAMEWORK.md).

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

1. **Copy this file** — place `AGENTS.md` at the project repository root. Optionally create `.agents/documentation/` with boilerplate project doc files.
2. **Run Project Bootstrap** — on first use, the agent reads `AGENTS.md`, runs the environment detection in [Project Bootstrap]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md#environment-detection-before-step-0a), then [Step 0a]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md#step-0a--initialise-user-level-framework-directory) to clone (or update) the core framework's `.agents/` tree into `{USER_AGENTS}/` (one-time per machine, when writable — sandboxed agents use the framework-files fallback chain instead) and [Step 0b]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md#step-0b--initialise-project-level-directory) to create the project-level state at the first writable `{PROJECT_AGENTS}` tier (one-time per project — repos sharing the same `{PROJECT_NAME}` share it).
3. **Bootstrap interview** — if `.agents/documentation/*` is still boilerplate, the agent runs the [Project Bootstrap]({USER_AGENTS}/workflows/PROJECT_BOOTSTRAP.md) interview to configure the project.
4. **Install plugins** — for each registered plugin, say its install command (e.g. `install Jira skills`). The agent follows the plugin's guided setup flow, resolving credentials via the [layered credential lookup](#layered-resolution) (on local developer machines the default store is `{PROJECT_AGENTS}/project/.local-config.json`; hosted/sandboxed agents use secrets or env vars).
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
| `jira-management/SKILL.md` | Read-only Jira Cloud API integration: credential setup, ticket retrieval, ADF parsing, and project prefix discovery. Activate on "install Jira skills" or `fetch {KEY}`. Does not own local tracking, analysis, or deployment — those are handled by `{USER_AGENTS}/workflows/PROJECT_TRACKING.md` and the framework's existing workflows. |

## Workflow Reference Files

All files in this table are at `{USER_AGENTS}/workflows/`.

| File | Intended purpose |
| --- | --- |
| `PROJECT_BOOTSTRAP.md` | First-install: initialises user-level framework directory, project-level state, and interview (org, VCS, team, release process) that populates `.agents/documentation/*` when it is still empty boilerplate. |
| `WORKFLOW.md` | Git workflow, task flow, branch conventions, PR expectations, and release handoff process. |
| `DEPLOYMENT.md` | Mandatory pre-deploy org-conflict check/merge and the 95% Apex coverage gate for every sandbox/org deploy, dry-run included. |
| `DEVELOPMENT_GATE.md` | Mandatory content-quality self-checklist run before any deployment manifest is generated (Gate A) and before any deploy is executed (Gate B): naming, descriptions, FLS/access, picklist rules, Apex standards, tests, manifest integrity. |
| `PULL_REQUEST.md` | Pull request template usage, final commit, back-merge, and review-readiness checklist. |
| `TESTING.md` | Verification protocols, test commands, mocking strategies, coverage expectations, and acceptance checks. |
| `IMPLEMENTATION_PLAN.md` | Delivery sequencing, dependency ordering, implementation planning, rollout steps, and open task tracking. |
| `JIRA.md` | Jira fetch workflow: the single Jira-facing operation that retrieves a ticket and delivers parsed data to project tracking. |
| `PROJECT_TRACKING.md` | Local ticket management: ticket files at `{PROJECT_AGENTS}/project/tickets/`, agile board, and ticket-scoped command routing (`analyse`, `build`, `deploy`, `test`, `comment`) that delegates to the framework's existing workflows. |

## Documentation Reference Files (Repo Level)

All files in this table are at repo-level `.agents/documentation/` — committed and team-shared via git.

| File | Intended purpose |
| --- | --- |
| [PROJECT_STRUCTURE.md](.agents/documentation/PROJECT_STRUCTURE.md) | Repository topology, source folders, metadata locations, and orientation checklist. |
| [ARCHITECTURE.md](.agents/documentation/ARCHITECTURE.md) | System topology, modules, services, dependencies, data flows, and ownership boundaries. |
| [ENVIRONMENT.md](.agents/documentation/ENVIRONMENT.md) | **Template only in this repo** — the live copy is per developer at `{PROJECT_AGENTS}/project/ENVIRONMENT.md`. Local setup, required tools, org aliases, environment matrix, secrets handling. Each developer records their own org access; never inherited from another developer. |
| [SCHEMA.md](.agents/documentation/SCHEMA.md) | Data models, Salesforce object relationships, schema diagrams, field ownership, and data constraints. |
| [INTEGRATIONS.md](.agents/documentation/INTEGRATIONS.md) | API connections, external systems, named credentials, payload contracts, and integration constraints. |
| [GLOSSARY.md](.agents/documentation/GLOSSARY.md) | Domain vocabulary, business terms, certified datasets, project jargon, and naming constraints. |
| [SPECIFICATION.md](.agents/documentation/SPECIFICATION.md) | Requirement validity rules, accepted sources, functional assumptions, and client-specific overrides. |
| [PRODUCT_REQUIREMENTS.md](.agents/documentation/PRODUCT_REQUIREMENTS.md) | Product requirement documents, business goals, user stories, acceptance criteria, and product constraints. |
| [TECHNICAL_REQUIREMENTS.md](.agents/documentation/TECHNICAL_REQUIREMENTS.md) | Technical requirements, non-functional constraints, platform dependencies, and technical acceptance criteria. |
| [USER_EXPERIENCE.md](.agents/documentation/USER_EXPERIENCE.md) | App flows, user journeys, design decisions, branding, content rules, and UX constraints. |

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
