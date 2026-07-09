# Changelog

## Purpose And Use

This file records all notable changes to `sf-agentic-coding-framework` in human-readable form, one entry per released version, newest first. Read it when a newer master framework version is detected during the [Daily Update Check](directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) — relay the relevant entries to the user so they know what changed before approving a merge. **Update this file before every merge to `main`** — the entry should be complete and accurate so the next installer or updater understands exactly what arrived in each version without reading the full diff.

---

## [0.1.3] — Unreleased

### Added
- **Per-repo project-specific workflows and directives**: `{USER_AGENTS}/{repo_name}/workflows/` and `{USER_AGENTS}/{repo_name}/directives/` hold instructions that apply to one repo only. A same-named file there overrides its generic framework counterpart for that repo; otherwise both apply. Created empty during bootstrap Step 0b; sanitized generic lessons may be upstreamed via Scenario 2.
- **Per-developer environment file**: the live `ENVIRONMENT.md` (org aliases, auth status, env facts) moves from the repo to `{REPO_STATE}/project/ENVIRONMENT.md` — per developer, cross-branch, never shared. Each developer records their own org access during bootstrap instead of inheriting another developer's; the repo's `.agents/project/ENVIRONMENT.md` remains only as the boilerplate template copied at bootstrap. Author-identity secondary store follows: `identity.json` (global) → user-level per-repo `ENVIRONMENT.md` (repo-specific override) → just-in-time question.
- **Multi-OS support**: cross-platform notes in `AGENTS.md` (per-OS `{USER_AGENTS}` resolution incl. PowerShell/Bash forms; WSL is a separate machine from its Windows host; user-level state is per machine and does not sync — Jira is the ticket sync source); cross-platform command rule in `AGENTIC_FRAMEWORK.md` (shell examples must be OS-neutral or dual PowerShell+Bash); `.gitattributes` added for LF/CRLF normalization across OSes.
- **Lowercase filename convention**: `JIRA.MD` → `JIRA.md`, `PROJECT_TRACKING.MD` → `PROJECT_TRACKING.md` (and board lane templates referenced as `.md`) — Linux filesystems are case-sensitive, so all framework files use lowercase `.md` and links must match case exactly.
- **Full-repo migration scan**: the repo-level → user-level migration now scans **all local branches** (via `git ls-tree`/`git show`, without checkout) and **all worktrees** (filesystem scan, catching gitignored credentials) before moving anything. It builds a migration inventory, merges ticket versions by newest `Last Synced` (preserving conflicting versions as `{KEY}.migrated-from-{source}.md`), rebuilds the board from ticket statuses, unions/deduplicates credentials with a user decision on conflicts (values never echoed), and requires confirmation on the inventory before migrating — so Jira ticket details and credentials on other branches/worktrees are never lost.

### Changed
- `PROJECT_BOOTSTRAP.md` — Step 0 documents per-machine/per-OS behavior; Step 0b creates `workflows/`, `directives/`, and `project/ENVIRONMENT.md` (copied from the repo template, filled per developer); unconfigured-project detection checks the user-level environment file; persistence table routes org aliases to the user-level copy.
- `DEPLOYMENT.md` — Environment Config Check reads/writes the developer's user-level `ENVIRONMENT.md`.
- `SALESFORCE_APEX_STANDARDS.md`, `AGENT_GUARDRAILS.md`, `sf-platform-apex/SKILL.md`, `sf-platform-lwc/SKILL.md` — author-identity secondary store repointed to the user-level per-repo `ENVIRONMENT.md` (per-repo override semantics replace team-shared semantics).
- `AGENTIC_FRAMEWORK.md` — migration procedure copies real environment values to the user level and creates the per-repo workflows/directives folders; maintenance rules document the project-specific override precedence and the cross-platform command rule.
- `.local-config.template.json` — `user_level_structure` documents `per_repo_environment`, `per_repo_workflows`, `per_repo_directives`.
- `AGENTS.md`, `README.md` — version 0.1.3.

---

## [0.1.2] — 2026-07-08

### Added
- **Layered resolution model**: framework files, credentials, and temp locations are now resolved via a priority chain rather than assuming `{USER_AGENTS}` is unconditionally available. Supports `SF_AGENTIC_FRAMEWORK_HOME` env var override, user-level paths (local default), and repo-local `.agents/` fallback for sandboxed/remote agents.
- **Credential lookup chain**: 5-tier resolution (secret manager → env vars → OS keychain → local JSON → interactive prompt). Plaintext `.local-config.json` is now explicitly documented as local-developer-only convenience, not a universal credential store.
- **Temp fallback**: repo-local `.agents/temp/` (gitignored) added as a fallback for agents that cannot write to `{USER_AGENTS}/{repo_name}/temp/`.
- **Environment detection in bootstrap**: Step 0 now probes `{USER_AGENTS}` writability before attempting user-level installation; sandboxed agents gracefully fall back to repo-local framework files.

### Changed
- `AGENTS.md` — Framework Location section reframed as "local-first, user-level architecture with fallbacks"; added Layered Resolution subsection with lookup-order tables for framework files, credentials, temp, and per-repo project state (`{REPO_STATE}` shorthand: env-var override → user-level → agent-provided workspace → repo-local `.agents/state/`).
- `PROJECT_BOOTSTRAP.md` — added environment detection step before Step 0a; Step 0a detection now requires confirmed writability; Step 0b creates per-repo state at the first writable `{REPO_STATE}` tier and only creates plaintext `.local-config.json` on local machines.
- `PROJECT_TRACKING.md` — ticket file and board paths now use `{REPO_STATE}`; persistence claims scoped to what the resolved tier actually provides (no cross-sandbox persistence promise).
- `AGENTIC_FRAMEWORK.md` — Daily Update Check uses `preferences.json` only when writable, otherwise an in-session marker (never attempts the write, never fails the check); Scenario 1 temp clone uses layered temp resolution.
- `AGENT_GUARDRAILS.md` — Temp Workspace section lists 3-tier temp location resolution; Code Comment Authorship now resolves identity from `{USER_AGENTS}/identity.json` first, `ENVIRONMENT.md` second.
- `jira-management/SKILL.md` — Credential Loading rewritten as 5-tier lookup; install flow Step 1 resolves via secret manager → env vars → keychain → local JSON, never creates plaintext config in hosted/sandboxed environments; project prefixes stored only when a writable approved state location exists.
- `JIRA.md` — fetch step 2 resolves credentials via the layered lookup instead of reading the local JSON first.
- `README.md` — installation wording matches v0.1.2: copy `AGENTS.md` (+ optional `.agents/project/` boilerplate); framework files install at user level or fallback via layered resolution.
- `sf-platform-apex/SKILL.md` — ApexDoc author identity resolution aligned (identity.json primary, ENVIRONMENT.md fallback).
- `sf-platform-test/SKILL.md`, `sf-platform-soql/SKILL.md`, `sf-platform-debug/SKILL.md` — stale `platform-apex-logs-debug` routing links/labels replaced with `sf-platform-debug` (frontmatter source attribution preserved); debug skill's Agentforce observability route fixed from non-existent `agentforce-observe` to `sf-agentforce-build`; debug README and reference headers renamed to the installed skill name.
- `AGENTS.md` — added `{REPO_TEMP}` shorthand; Purpose/Installation Procedure and workflow reference table now use `{REPO_STATE}`/`{REPO_TEMP}` and the layered credential lookup instead of unconditional `{USER_AGENTS}/{repo_name}` paths; fixed Scenario 2 link to `.agents/directives/AGENTIC_FRAMEWORK.md`.
- `AGENT_GUARDRAILS.md` — Temp Workspace headings, examples, cleanup rules, and folder convention now use `{REPO_TEMP}` (resolved temp workspace) rather than hard-coded `{USER_AGENTS}` paths.
- `jira-management/SKILL.md` — fixed root `AGENTS.md` link depth (`../../../AGENTS.md`).
- `README.md` — "How it works" and "Installing" now mention the sandboxed/hosted fallback path with a pointer to Layered Resolution (previously described only the local happy path).
- `.local-config.template.json` — convention block scoped to local developer machines; persistence claims for tickets/board limited to what the resolved `{REPO_STATE}` tier provides; hosted agents directed to the layered chains.
- `AGENTS.md` — installed-repo footprint description acknowledges gitignored `.agents/temp/`/`.agents/state/` fallback directories; `{REPO_STATE}` chain documents fall-through when `SF_AGENTIC_FRAMEWORK_HOME` is a read-only mount.
- `sf-platform-debug/SKILL.md` — Agentforce route annotated as a capability gap (nearest installed skill) with a pointer to the synthesis procedure for a dedicated observability skill.
- `.gitignore` — added `.agents/temp/` and `.agents/state/` entries for repo-local fallbacks.

---

## [0.1.1] — 2026-07-07

### Added
- **User-level framework architecture**: the entire framework (directives, standards, skills, workflows) now installs at `~/.agents/` (Unix) or `%USERPROFILE%\.agents\` (Windows) — shared across all repositories on the machine. Per-repo persistent state (credentials, tickets, board, temp data) lives at `~/.agents/{repo_name}/`, derived from the git folder name. This solves three problems: (1) credentials lost when switching repos, (2) ticket/board state tied to a single branch, (3) gitignore sprawl from framework files in every repo.
- **`identity.json` and `preferences.json`** at user-level root: author name/email shared across all repos; framework version and update-check state in one place.
- **Per-repo credential isolation**: developers working on multiple clients (e.g. `client-a-platform`, `client-b-crm`) get separate `.local-config.json` files per project, each with its own Jira credentials and org aliases.
- **Simplified repo footprint**: project repos now contain only `AGENTS.md` (routing document) and `.agents/project/` (team-shared docs like ENVIRONMENT.md, ARCHITECTURE.md). All framework files, tickets, board state, and credentials live outside the repo.
- **Automatic migration from repo-level installs**: existing installs (v0.0.9 and earlier) are detected on first session and migrated automatically — framework files are copied to `{USER_AGENTS}/`, per-repo state (credentials, tickets, board) is moved to `{USER_AGENTS}/{repo_name}/`, and old repo-level files are deleted after user confirmation. See the Migration section in `AGENTIC_FRAMEWORK.md`.

### Changed
- `AGENTS.md` — all path references updated from `.agents/` to `{USER_AGENTS}/` notation; Installation Manifest now installs to user-level directory; reference tables use user-level paths; project docs remain at `.agents/project/` in-repo.
- `PROJECT_BOOTSTRAP.md` — Step 0 rewritten as three sub-steps: (0a) initialise user-level framework directory and identity, (0b) initialise per-repo state directory, (0c) project doc persistence decision (simplified — only applies to `AGENTS.md` and `.agents/project/`, not the full framework).
- `AGENTIC_FRAMEWORK.md` — Daily Update Check reads `{USER_AGENTS}/preferences.json` instead of `.agents/.local-config.json`; Scenario 1 (pull updates) targets `{USER_AGENTS}/` instead of `{repo}/.agents/`; Copy-Paste Prompt updated with split architecture.
- `AGENT_GUARDRAILS.md` — Generated Files and Temp Workspace sections updated to `{USER_AGENTS}/{repo_name}/temp/` paths.
- `jira-management/SKILL.md` — credential loading simplified to single location at `{USER_AGENTS}/{repo_name}/.local-config.json`; auth code examples rewritten for user-level paths; install flow updated.
- `JIRA.md` — config loading updated to user-level per-repo path.
- `PROJECT_TRACKING.md` — ticket file path updated to `{USER_AGENTS}/{repo_name}/project/tickets/{KEY}.md`; board path updated to `{USER_AGENTS}/{repo_name}/project/board/`; explicitly notes that files persist across branches and sessions.
- `.local-config.template.json` — convention block rewritten with `user_level_structure` documenting the full `{USER_AGENTS}/` directory tree; `identity` and `update_check` keys removed (moved to separate user-level files).
- `.gitignore` — simplified; removed `.agents/temp/` and `.agents/.update-check` entries (these no longer exist in repo).

---

## [0.0.9] — 2026-07-06

### Added
- **Installation Manifest** in `AGENTS.md`: portable section containing the framework source URL, registered plugins table, and step-by-step installation procedure. Any user who copies `AGENTS.md` into a new repo can pull the entire framework and all registered plugins from their source URLs.

### Added
- **Read-only Jira skill** (`jira-management` v2.0): Jira Cloud API integration layer — credential setup, auth testing, project prefix discovery, ticket retrieval, ADF parsing. Strictly read-only (GET only). Owns only the API connection; does not own local tracking or execution workflows.
- **Guided install flow**: credential prompts, auth test against `/rest/api/3/myself`, and automatic project prefix discovery so ticket keys (e.g. `DTT-115`, `COP-42`) are recognised without the `jira` keyword.
- **Implicit ticket key recognition**: once project prefixes are learned, `fetch DTT-115` is equivalent to `fetch jira DTT-115`.
- **Jira fetch workflow** (`.agents/workflows/JIRA.md`): single Jira-facing operation that retrieves a ticket and delivers parsed data to the project tracking layer.
- **Project tracking workflow** (`.agents/workflows/PROJECT_TRACKING.md`): source-agnostic local ticket management with three responsibilities: (1) local ticket files at `.agents/project/tickets/{KEY}.md`; (2) agile board with lane-based status tracking; (3) ticket-scoped command routing (`analyse`, `build`, `deploy`, `test`, `comment`) that delegates to the framework's existing workflows rather than redefining them.
- **Three-layer architecture**: Layer 1 (Jira skill) owns API access → Layer 2 (Project tracking) owns local files, board, and command routing → Layer 3 (existing framework workflows: `SPECIFICATION.md`, `IMPLEMENTATION_PLAN.md`, `DEPLOYMENT.md`, `TESTING.md`) owns execution. No duplication between layers.
- **Local agile board** (`.agents/project/board/`): lane-based status tracking across Backlog, In Progress, Blocked, Code Review, and Done.
- **Centralised local config convention**: `_convention` block in `.local-config.template.json` documents how future skills should add their config to the single local config file, preventing folder sprawl and redundant gitignore entries.
- **Temp workspace convention** (`.agents/temp/`): gitignored standard location for all transient data — retrieved org metadata, dry-deploy output, coverage reports, PMD scans, and framework update clones. Cleanup rules enforced before branch checkout, before merge, and after workflow completion.
- Draft-safe Flow generation guidance: generated or corrected Flow metadata now defaults to `<status>Draft</status>` unless the user explicitly requests activation.
- Generic contribution-back workflow for reusable lessons learned during local installs.

---

## [0.0.8] — 2026-07-01

### Added
- **Nine Prime Directives** in `AGENT_GUARDRAILS.md`: mandatory behavioral rules that apply before any other instruction — (1) never execute a prompt verbatim; (2) understand context before acting; (3) decompose and question whether the request is truly required; (4) prefer existing and standard implementations over generating custom code; (5) never assume, always query back; (6) pre-generation gate requiring open questions and at least two alternatives with pros/cons before generating any file; (7) conflict verification before any org deployment; (8) persist user decisions into agent instructions; (9) track generated file iteration counts in session memory only, never in file names or content. Summary added to the Prime Directive section of `AGENTS.md`.
- **Local configuration file** (`.agents/.local-config.json`, always gitignored): consolidated local-only state into one structured JSON file, replacing the single-line `.agents/.update-check` marker. Stores author identity (name and email, personal and never pushed), update-check last timestamp (ISO 8601 UTC), and last-known master version — extensible for future local-only credential fields.
- **Template** (`.agents/.local-config.template.json`, tracked): checked-in shape reference so new installs know the expected JSON structure without committing any real values.
- **CHANGELOG.md** (this file): descriptive per-version history, updated before every merge to `main` and relayed to the user whenever a newer framework version is detected.

### Changed
- `AGENTIC_FRAMEWORK.md` — Daily Update Check now reads/writes `.agents/.local-config.json` (`update_check.last_checked_utc` + `update_check.last_known_version`) instead of `.agents/.update-check`; added CHANGELOG update requirement to the pre-merge checklist; after a framework update is applied, the tooling check re-runs to catch any new dependencies.
- `PROJECT_BOOTSTRAP.md` — Step 1 (Required Tooling Check) fully rewritten: OS detection first (winget / brew / apt); checks 10 required tools and 2 recommended tools (Git, Node.js LTS, npm, Java JDK 11+, SF CLI, GH CLI, sfdx-git-delta, Salesforce Code Analyzer plugin, ESLint, Prettier + prettier-plugin-apex; recommended: Jest + sfdx-lwc-jest, VS Code + Salesforce Extension Pack); enforced install dependency order; consolidated automated install offer with yes / no / let me choose; install commands per tool per OS; re-verifies all tools after install; triggers on every framework update, not just first install. Interview trimmed from 9–10 questions to exactly 5.
- `PROJECT_BOOTSTRAP.md` — Step 0 now initializes `.agents/.local-config.json` from the template on first install and writes author identity into it; `.agents/.update-check` gitignore entry replaced by `.agents/.local-config.json`.
- `AGENT_GUARDRAILS.md` — Generated Files exclusion updated: `.agents/.local-config.json` replaces `.agents/.update-check`.
- `ENVIRONMENT.md` — Author Identity note updated: `.local-config.json` is now the local-only store; ENVIRONMENT.md remains the team-shared store when the framework is committed.
- `AGENTS.md` — Added CHANGELOG.md to the Directive Reference Files table.

---

## [0.0.7] — 2026-06-29

### Added
- **Daily Update Check (Automatic)**: at the start of the first turn in each session, a lightweight read-only fetch compares the master repository's version to the local install's version. If newer, the user is notified and [Scenario 1](directives/AGENTIC_FRAMEWORK.md#scenario-1--pulling-framework-updates-into-a-local-install-update--upgrade) is offered — approval gates unchanged.
- **`.agents/.update-check` marker file**: stores the last-checked date (`YYYY-MM-DD`); always gitignored regardless of the framework-persistence choice.

### Changed
- `AGENTIC_FRAMEWORK.md` — new "Daily Update Check (Automatic)" section with 7-step procedure; check skips when working directly in the master repository.
- `AGENT_GUARDRAILS.md` — Generated Files exclusion list updated to include `.agents/.update-check`.
- `PROJECT_BOOTSTRAP.md` — Step 0 now always adds `.agents/.update-check` to `.gitignore` regardless of the shared/local-only persistence choice.
- `AGENTS.md` — Purpose And Use note updated to describe the daily check; version bumped to 0.0.7.

---

## [0.0.6] — 2026-06-29

### Added
- **Permission Set query for new Apex classes**: when generating a new top-level Apex class (not inner, test, or trigger-handler), the agent now asks which Permission Set(s) should receive Apex Class Access — or which Profile (less recommended) if no permission sets are in use. The answer is included in the delivery output as a Permission Set metadata deliverable.

### Changed
- `sf-platform-apex/SKILL.md` — Required Inputs and Output Expectations updated; Permission Set deliverable added to the report template.
- `sf-platform-permissions/SKILL.md` — When to Use section updated to note Apex Class Access delegation from `sf-platform-apex`.

---

## [0.0.5] — 2026-06-29

### Added
- **Exact ApexDoc comment-block format**: class-level tags (`@description :`, `@author :`, `@group :`, `@last modified on :`, `@last modified by :`, `@test :`) and method-level tags (`@description`, `@author`, `@param`, `@return`) are now mandated with aligned-colon formatting — no deviation permitted.
- **Author identity required**: agent must read the configured author name and email from `ENVIRONMENT.md` before generating any class or method comment header; if not yet configured, ask the user just-in-time, then ask separately whether to persist it.

### Changed
- `SALESFORCE_APEX_STANDARDS.md` — "ApexDoc Comment Block (Mandatory)" section added with exact tag set and format; "Author Identity (Required)" section added.
- `AGENT_GUARDRAILS.md` — "Code Comment Authorship" section added: never write an AI/model/tool name as `@author` or `@last modified by`.
- `sf-platform-apex/SKILL.md` — ApexDoc section updated to exact format; author identity check cross-linked.
- `sf-platform-lwc/SKILL.md` — JSDoc Comment Block section added with same author-identity rule.
- `ENVIRONMENT.md` — Author Identity section added (default "Not yet configured" for name and email).

---

## [0.0.4] — 2026-06-28

### Added
- **Full ApexDoc header block mandated** for every class and method — no class or method may be delivered without a complete comment block.
- **Constants naming reinforced**: `LeadConstants` (not `LeadConsts`), `OpportunityConstants` (not `OpportunityConsts`) added as explicit examples; all references to abbreviated `Consts` forms removed or corrected.

### Changed
- `APEX_CONSTANTS_FRAMEWORK.md` — Added `LeadConstants` and `OpportunityConstants` as explicit naming examples; `Consts` abbreviation prohibition made explicit throughout.
- `SALESFORCE_APEX_STANDARDS.md` — Review Checklist updated with ApexDoc and author identity requirements.
- `sf-platform-apex/assets/Constants.cls` — Renamed from `Consts.cls`; applied exact ApexDoc class header format.
- `sf-platform-apex/assets/concrete-constants/AccountConstants.cls` — Renamed from `AccountConsts.cls`; applied exact ApexDoc class header format.

---

## [0.0.3] — 2026-06-28

### Added
- **Chat brevity rule**: while the user is waiting, the agent outputs at most one short phrase per interim update; full detail only at decision points.
- **Pre-development retrieve mandate**: the first time the agent touches any Apex class or metadata component in a session, it must retrieve the org's current version before generating or editing.
- **Environment config check before deploy**: if `ENVIRONMENT.md` is still boilerplate, the agent asks for the dev org alias before proceeding; separate question on whether to persist; skip if a real default is already recorded.
- **Framework persistence question**: on first install, asks whether `AGENTS.md` and `.agents/` should be committed to the remote or kept local-only; records the decision in `.gitignore`.

### Changed
- `AGENT_GUARDRAILS.md` — Chat Brevity While Working section added.
- `DEPLOYMENT.md` — Environment Config Check section added (runs before every deploy).
- `PROJECT_BOOTSTRAP.md` — Step 0 (Framework Persistence) added as a standalone pre-bootstrap check.
- `APEX_CONSTANTS_FRAMEWORK.md` — Full-word `Constants` mandated; `AccountConstants` example corrected from `AccountConsts`.
- `sf-platform-apex/assets/Constants.cls` and `AccountConstants.cls` — Renamed from `Consts`/`AccountConsts` variants to full `Constants`/`AccountConstants`.
- `sf-platform-schema/SKILL.md` and `sf-platform-lwc/SKILL.md` — Pre-development retrieve cross-links added.

---

## [0.0.2] — 2026-06-27

### Added
- **Project bootstrap workflow** (`PROJECT_BOOTSTRAP.md`): 9-question interview (org, VCS, team/process, naming, author identity) run on first install; answers persisted to `.agents/project/` files.
- **Framework metadata header** in `AGENTS.md`: version, author, master repository, last updated, license.
- **Acknowledgements table**: credits for all upstream sources (forcedotcom/sf-skills, Clientell-Ai/salesforce-skills, ponytail, caveman, sfdc-trigger-framework, apex-consts).
- **Master Framework Repository And Sync Workflow**: Scenario 1 (pull updates with approval gates) and Scenario 2 (contribute back with sanitization) in `AGENTIC_FRAMEWORK.md`.

### Changed
- `AGENTS.md` — Purpose And Use updated to describe the bootstrap trigger and daily update check; Required Reading Order updated.
- `ENVIRONMENT.md` — Org alias naming convention (`{client}-{project}-{env}`) and concrete illustration (`rpoorun-framework-dev`) documented; all client-identifying examples removed.

---

## [0.0.1] — 2026-06-27

### Added
- Initial repository structure: `AGENTS.md` entry point; `.agents/directives/`, `.agents/standards/`, `.agents/skills/`, `.agents/workflows/`, `.agents/project/` folder layout.
- **Core directives**: `AGENTIC_FRAMEWORK.md`, `AGENT_GUARDRAILS.md`, `TRUST_DATA_SECURITY.md`, `MANUAL_CONFIRMATION_GATES.md`.
- **Standards**: `SALESFORCE_PROJECT_BEST_PRACTICES.md`, `SALESFORCE_APEX_STANDARDS.md`, `PMD_APEX_RULESET.md`, `LEAN_CODE_STANDARDS.md` (refactored from ponytail + caveman), `APEX_TRIGGER_FRAMEWORK.md` (TriggerHandler vendored verbatim, MIT), `APEX_CONSTANTS_FRAMEWORK.md` (apex-consts adapted, MIT), `DOCUMENTATION.md`.
- **26 synthesized `sf-{cloud}-{name}` skills**: synthesized and deduplicated from forcedotcom/sf-skills and Clientell-Ai/salesforce-skills; all client-identifying content removed; standard frontmatter + header table applied to every `SKILL.md`.
- **Workflows**: `DEPLOYMENT.md` (pre-deploy conflict check, 95% Apex coverage gate), `WORKFLOW.md`, `PULL_REQUEST.md`, `TESTING.md`, `IMPLEMENTATION_PLAN.md`.
- **Project boilerplate**: `ENVIRONMENT.md`, `ARCHITECTURE.md`, `PROJECT_STRUCTURE.md`, `SCHEMA.md`, `INTEGRATIONS.md`, `GLOSSARY.md`, `SPECIFICATION.md`, `PRODUCT_REQUIREMENTS.md`, `TECHNICAL_REQUIREMENTS.md`, `USER_EXPERIENCE.md`.
- `LICENSE` (Apache License 2.0), `README.md` (human-facing overview).
