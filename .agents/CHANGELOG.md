# Changelog

## Purpose And Use

This file records all notable changes to `sf-agentic-coding-framework` in human-readable form, one entry per released version, newest first. Read it when a newer master framework version is detected during the [Daily Update Check](directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) — relay the relevant entries to the user so they know what changed before approving a merge. **Update this file before every merge to `main`** — the entry should be complete and accurate so the next installer or updater understands exactly what arrived in each version without reading the full diff.

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
