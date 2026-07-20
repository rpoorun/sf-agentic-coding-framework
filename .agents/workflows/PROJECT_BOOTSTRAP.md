# Project Bootstrap

## Purpose And Use

This file owns three first-time checks: (1) initialising the user-level framework directory (`{USER_AGENTS}`), (2) whether the project docs (`.agents/documentation/`) should be committed or kept local-only, and (3) the setup interview that runs when `.agents/documentation/*` is still empty boilerplate. Read it the first time `AGENTS.md` is read in a session, before any other implementation work, whenever any detection condition below is met.

**Path convention used in this file:**
- `{USER_AGENTS}` = `~/.agents/` (Unix/macOS) or `%USERPROFILE%\.agents\` (Windows)
- `{PROJECT_NAME}` = repository name from the git remote URL (e.g. `https://github.com/rpoorun/rehlko-dtt.git` → `rehlko-dtt`; Bash: `basename -s .git "$(git remote get-url origin)"`). If no git remote is configured, ask the user for the project name in chat and persist it in the repo-level `.agents/project/` configuration.
- `{PROJECT_AGENTS}` = `{USER_AGENTS}/{PROJECT_NAME}/` — the project-level tier, shared by every repo, branch, and worktree of the project

## Master Repository Guard

Before running any migration, bootstrap, or cleanup logic, check whether the current repo **is** the master framework repository. If it is, skip all migration and deletion steps — the master repo is the canonical source and must keep its full `.agents/` tree.

Detection (conservative — all three checks must pass to identify as master):
1. `AGENTS.md` contains a "Master repository" field whose URL matches the current repo's `git remote get-url origin` (compare hostname and path, ignore `.git` suffix and protocol).
2. The repo name (basename of `git rev-parse --show-toplevel`) is `sf-agentic-coding-framework`.
3. `.agents/directives/`, `.agents/standards/`, `.agents/skills/`, and `.agents/workflows/` all exist and are tracked by git.

If all three match, this is the master repo. Do not run migration. Do not delete `.agents/` subdirectories. Do not run Step 0a/0b (framework files are read directly from `.agents/`). The bootstrap interview (Steps 1–3) may still run if `.agents/documentation/*` is boilerplate, but framework source folders must remain untouched.

## Detection: Does This Repo Need Migration?

If this repo has framework files at `{repo}/.agents/directives/`, `{repo}/.agents/standards/`, `{repo}/.agents/skills/`, or `{repo}/.agents/workflows/` — **and** the repo is not the master framework repository (see guard above) — it is following the old repo-level structure and needs migration. Run the [Migration procedure]({USER_AGENTS}/directives/AGENTIC_FRAMEWORK.md#migration--upgrading-from-repo-level-to-user-level-architecture) in `AGENTIC_FRAMEWORK.md` before proceeding with bootstrap. This moves framework files to `{USER_AGENTS}/`, project state to `{PROJECT_AGENTS}/`, and cleans up the repo. The migration **scans all local branches and all worktrees** (not just the checked-out one) before moving anything, so Jira ticket files committed on other branches and credentials sitting in other worktrees are inventoried, merged, and preserved — never silently lost.

This is a **standing check, not a one-time upgrade step**: it applies even when `{USER_AGENTS}/` is already installed. A branch or isolated worktree checked out from an old commit may still carry the old structure (repo-level framework folders, `.agents/.local-config.json` credentials, repo-level tickets/board). Whenever such a remnant is encountered — including during any later framework update — install the update normally, then run the remnant migration: merge only content newer than what the user level already holds, keep common instruction files authoritative at the user level, and clean the old files off the current branch/worktree. Migration **merges — never overrides or deletes** existing instructions (user-level stays the base; additive repo-level guidance is folded in; project-specific tailoring moves to `{PROJECT_AGENTS}/directives|workflows/`), and credentials merge at the connection level (union of all connector keys and non-empty fields across every copy found, conflicts resolved by the user, each connection verified after migration) so no existing connection is ever lost.

## Detection: Is This Project Still Unconfigured?

Treat the project as **not yet bootstrapped** if the developer's user-level environment file (`{PROJECT_AGENTS}/project/ENVIRONMENT.md`) does not exist or still contains only its boilerplate placeholders (e.g. `{client name}-{project name}-{env}`, "Not yet documented"), and/or most `.agents/documentation/*.md` files in the repo still read "No durable ... details have been documented here yet." Environment details are per developer — a new developer on an already-configured project still runs the environment part of this interview to record their own org access. If the project is already configured (real org aliases, real architecture notes, etc. are present), skip this entire workflow and proceed with the normal [Default Work Pattern](../../AGENTS.md#default-work-pattern).

When the detection condition is met, run this workflow before starting the user's actual task, unless the user's request is itself trivial/read-only (e.g. "what does this repo do") — in that case answer the request first, then offer to run the bootstrap interview.

## Step 0 — User-Level Framework Initialisation (Runs Once Per Machine, Then Once Per Project)

This step has its own trigger, separate from the project-config detection above: run it the first time this framework is read in any repository's git context on this machine. Skip sub-steps that are already complete.

**Per-machine, per-OS**: the user-level install is bound to one machine and one OS user profile. The same repo cloned on a second machine (or a different OS — Windows, macOS, Linux; WSL counts as a separate machine from its Windows host because `$HOME` differs) triggers Step 0 again there. `{USER_AGENTS}` resolves per OS — `%USERPROFILE%\.agents\` on Windows, `$HOME/.agents/` on macOS/Linux — and `{PROJECT_NAME}` derives identically everywhere, so the project folder name matches across machines. User-level state (credentials, tickets, board, environment) does **not** sync between machines: Jira is the sync source for tickets, and each machine's developer environment is recorded fresh. Anything that must travel with the repo belongs in committed `.agents/documentation/` docs.

### Environment detection (before Step 0a)

Before creating user-level directories, determine which runtime environment the agent is in:

1. If `SF_AGENTIC_FRAMEWORK_HOME` is set, use that path as the framework root instead of `{USER_AGENTS}`. Skip Step 0a (framework files are already provided at that location). Proceed to Step 0b using `SF_AGENTIC_FRAMEWORK_HOME` in place of `{USER_AGENTS}`.
2. If `{USER_AGENTS}` (`~/.agents/` or `%USERPROFILE%\.agents\`) is writable, proceed with Step 0a as normal.
3. If `{USER_AGENTS}` is **not writable** (sandboxed agent, ephemeral container, restricted workspace), fall back:
   - Use the repo-local `.agents/` tree as a read-only framework source (do not copy files).
   - Use the agent-provided writable temp/workspace path for temp output.
   - Use environment variables or platform-provided secrets for credentials (see [Credential lookup order](../../AGENTS.md#layered-resolution)).
   - Log a note that user-level installation was skipped due to environment constraints.
   - Skip Step 0a entirely; proceed to Step 0b using the project state chain (`{PROJECT_AGENTS}` in [AGENTS.md — Layered Resolution](../../AGENTS.md#layered-resolution)): `SF_AGENTIC_FRAMEWORK_HOME/{PROJECT_NAME}/` → `{USER_AGENTS}/{PROJECT_NAME}/` → agent-provided persistent workspace → repo-local `.agents/state/` (gitignored). Create the project-level directories at the first writable tier and tell the user which tier was used and what persistence it actually provides.

### Step 0a — Initialise user-level framework directory

Detection: run this if `{USER_AGENTS}` does not exist on disk and the environment detection above confirmed it is writable.

1. Create the directory structure:
   ```
   {USER_AGENTS}/
   ├── identity.json
   ├── preferences.json
   ├── documentation/        (user-level, author-specific notes tied to no project)
   ├── project/              (user-level config: system-wide credentials, env vars, parameters)
   ├── common/
   │   └── templates/
   ```
2. Ask the user for their **author name and email** (Question 5 from Step 2 may be asked here and skipped later). Write to `{USER_AGENTS}/identity.json`:
   ```json
   {
     "author_name": "Jane Doe",
     "author_email": "jane.doe@company.com"
   }
   ```
3. Create `{USER_AGENTS}/preferences.json` with blank update-check fields:
   ```json
   {
     "framework_version": "",
     "last_checked_utc": "",
     "last_known_version": ""
   }
   ```
4. Copy the framework's directives, standards, skills, and workflows into `{USER_AGENTS}/`:
   - `{USER_AGENTS}/directives/` ← from `.agents/directives/`
   - `{USER_AGENTS}/standards/` ← from `.agents/standards/`
   - `{USER_AGENTS}/skills/` ← from `.agents/skills/`
   - `{USER_AGENTS}/workflows/` ← from `.agents/workflows/`
   - `{USER_AGENTS}/CHANGELOG.md` ← from `.agents/CHANGELOG.md`
   - `{USER_AGENTS}/common/templates/.local-config.template.json` ← from `.agents/.local-config.template.json`
   These are the shared framework files — installed once, available to all projects and repos. On a framework **update** (rather than first install), the same copy runs again: the existing user-level files are the merge base and the newer master files are folded in per the update workflow in [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) — the framework subfolders are expanded at `{USER_AGENTS}/`, never inside any repo.

### Step 0b — Initialise project-level directory

Detection: run this if the project-level state directory (`{PROJECT_AGENTS}` — see the [project state chain](../../AGENTS.md#layered-resolution)) does not exist. On local machines `{PROJECT_AGENTS}` is `{USER_AGENTS}/{PROJECT_NAME}/`; in constrained environments it resolves to the first writable tier (env-var override → user-level → agent-provided workspace → repo-local `.agents/state/`, gitignored). This runs **once per project, not once per repo** — a second repo of the same project (same `{PROJECT_NAME}` from its git remote) reuses the existing project tier.

1. Derive `{PROJECT_NAME}` from the git remote URL (`basename -s .git "$(git remote get-url origin)"`); if no remote exists, ask the user in chat and persist the answer in the repo-level `.agents/project/` configuration.
2. Create the project-level directory structure at `{PROJECT_AGENTS}` (same subfolder shape as the user tier; no `temp/` — transient data goes to `{AGENTS_TEMP}` in the OS temp directory):
   ```
   {PROJECT_AGENTS}/
   ├── workflows/            (project-specific workflows, incl. skill-orchestration — empty until the project adds any)
   ├── directives/           (project-specific directives — empty until the project adds any)
   ├── standards/            (project-specific standards/naming conventions — empty until the project adds any)
   ├── skills/               ({skill-name}/{SKILL_NAME}_HELPER.md bridges — empty until a skill is implemented for this project)
   ├── documentation/        (machine-/developer-specific project docs, e.g. meeting notes)
   └── project/
       ├── .local-config.json    (local machines only — from {USER_AGENTS}/common/templates/.local-config.template.json, blank values)
       ├── ENVIRONMENT.md        (this developer's env facts — copied from the repo's .agents/documentation/ENVIRONMENT.md template)
       ├── environments/         (optional per-environment config: development/, uat/, staging/, production/)
       ├── tickets/
       └── board/
           ├── INDEX.md
           ├── BACKLOG.md
           ├── IN-PROGRESS.md
           ├── BLOCKED.md
           ├── CODE-REVIEW.md
           └── DONE.md
   ```
3. On local developer machines only: create `{PROJECT_AGENTS}/project/.local-config.json` from the user-level template `{USER_AGENTS}/common/templates/.local-config.template.json` with blank values. This file stores project-level credentials (Jira, org aliases, etc.), optionally segregated per environment under `project/environments/`. Credentials are **never stored at repo level** (sole exception: a plain identifier the user explicitly asked to keep in the repo, after a second confirmation in chat). Do **not** create a plaintext credential file when `{PROJECT_AGENTS}` resolved to a hosted-agent workspace or the repo-local fallback — hosted/sandboxed agents take credentials from the [credential lookup chain](../../AGENTS.md#layered-resolution) (secret manager, env vars) instead.
4. Copy the environment template into `{PROJECT_AGENTS}/project/ENVIRONMENT.md` (from the repo's `.agents/documentation/ENVIRONMENT.md` if present, else from `{USER_AGENTS}/common/templates/`). Environment details are **per developer**: each developer records their own org aliases and auth status per their access — never copy another developer's populated environment file.
5. Create board lane files with empty Markdown table headers.
6. `{PROJECT_AGENTS}/workflows/`, `{PROJECT_AGENTS}/directives/`, and `{PROJECT_AGENTS}/standards/` hold **project-specific** instructions that apply to every repo of this project. When a file there has the same name as a generic framework file at `{USER_AGENTS}/`, the project-specific file takes precedence; a same-named file at repo level (`.agents/`) beats both (most specific tier wins). `{PROJECT_AGENTS}/skills/{skill-name}/{SKILL_NAME}_HELPER.md` files bridge user-tier skills to this project's environments and credentials, and project-level workflows orchestrate how those helpers are consumed and sequenced. Sanitized generic lessons from project-specific files may be contributed upstream per [Scenario 2](../directives/AGENTIC_FRAMEWORK.md#scenario-2--forking-learned-improvements-back-to-the-master-framework-contribute-back).

### Step 0c — Project doc persistence (repo-level)

Detection: run this if `AGENTS.md` is currently untracked by git (`git status --porcelain AGENTS.md` shows `??`) **and** `.gitignore` does not yet contain a `# sf-agentic-coding-framework` marker line.

The framework's shared files (directives, standards, skills, workflows) now live at `{USER_AGENTS}/` — they are never committed to individual repos. The question here only applies to `AGENTS.md` (the routing file) and `.agents/documentation/` (team-shared project docs):

1. Ask the user: "Should the project documentation (`AGENTS.md` and `.agents/documentation/`) be committed to this repository's remote and shared with the team, or kept local-only?"
2. **If shared/remote**: record the decision by adding a `# sf-agentic-coding-framework: tracked in git (shared) — see PROJECT_BOOTSTRAP.md` comment line near the top of `.gitignore`.
3. **If local-only**: add `AGENTS.md` and `.agents/` to `.gitignore` with the marker comment. If already committed, offer `git rm --cached` (requires confirmation per [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md)).
4. Proceed to Step 1 below in the same turn — this question does not block the rest of bootstrap.

## Step 1 — Required Tooling Check

Run this step on **first install** and again whenever the [Daily Update Check](../directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) detects a newer framework version has been merged. Check every tool in the table below; report a clear present/missing/outdated status for each; then offer to install or update anything missing in one automated pass — but do not install anything without explicit user confirmation (dependency installation is approval-gated per [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md)).

### 1a — OS Detection

Before running checks, detect the operating system so the correct package manager is used for any installs:

| OS | Primary package manager | Fallback |
| --- | --- | --- |
| Windows | `winget` | `choco` (Chocolatey), or `npm` for Node-distributed tools |
| macOS | `brew` (Homebrew) | `npm` for Node-distributed tools |
| Linux (Debian/Ubuntu) | `apt` / `snap` | `npm` for Node-distributed tools |
| Linux (other) | `dnf` / `yum` / `pacman` | `npm` for Node-distributed tools |

Detect via: `uname -s` (macOS → `Darwin`; Linux → `Linux`); on Windows, the shell reports `MINGW*` / `MSYS*` in Bash, or the `OS` environment variable equals `Windows_NT`. If detection is uncertain, ask the user before picking a package manager.

### 1b — Tool Checks

Run every version check below and report the installed version (or "not found") for all tools before doing anything else. Tools are grouped by tier — **required** (framework is degraded without them) and **recommended** (skippable but flagged).

#### Required tools

| # | Tool | Version check | Why it matters |
| --- | --- | --- | --- |
| 1 | **Git** | `git --version` | Source control foundation — required for every workflow in this framework. |
| 2 | **Node.js LTS** | `node --version` (expect v20 or v22 LTS) | Runtime for all npm-distributed tools; must be present before any npm install. |
| 3 | **npm** | `npm --version` | Package manager for Node-distributed CLI tools. |
| 4 | **Java JDK 11+** | `java -version` (expect 11, 17, or 21) | Required by PMD Apex static analysis and Salesforce Code Analyzer — without it the analyzer plugin cannot run. |
| 5 | **Salesforce CLI (`sf`)** | `sf --version` | Org auth, retrieve, deploy, Apex test runs — assumed by every `sf-platform-*` skill. |
| 6 | **GitHub CLI (`gh`)** | `gh --version` | Used by the [Daily Update Check](../directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic) to read the master repo version and by PR workflows. |
| 7 | **sfdx-git-delta (SGD)** | `sf plugins` → look for `sfdx-git-delta` | Generates a scoped delta `package.xml` from a git diff — required for scoped deploys in [DEPLOYMENT.md](DEPLOYMENT.md). |
| 8 | **Salesforce Code Analyzer** | `sf plugins` → look for `@salesforce/sfdx-scanner` | Wraps PMD and ESLint for Apex and LWC static analysis — used by `sf-dx-analyzer` and [PMD_APEX_RULESET.md](../standards/PMD_APEX_RULESET.md). |
| 9 | **ESLint** | `eslint --version` | LWC JavaScript linting — used by `sf-platform-lwc` and Code Analyzer. |
| 10 | **Prettier** + **prettier-plugin-apex** | `prettier --version`; `npm list -g prettier-plugin-apex` | Consistent Apex and LWC formatting before every commit. |

#### Recommended tools

| # | Tool | Version check | Why it matters |
| --- | --- | --- | --- |
| R1 | **Jest** + **@salesforce/sfdx-lwc-jest** | `npx jest --version`; `npm list @salesforce/sfdx-lwc-jest` (project-level) | LWC unit test runner — assumed by `sf-platform-test` and [TESTING.md](TESTING.md). Installed at project level, not globally. |
| R2 | **VS Code** + Salesforce Extension Pack | `code --version`; extensions: `salesforce.salesforcedx-vscode` | IDE with inline Apex/LWC diagnostics, org browser, and one-click deploy. Optional if another editor is in use. |

### 1c — Automated Install Offer

After reporting status for all tools, if **any required** tools are missing:

1. Present a consolidated list of what needs to be installed with the exact commands for the detected OS.
2. Ask: **"Shall I install all missing required tools now using `{package manager}`? (yes / no / let me choose)"**
   - **yes** — run installs in dependency order (see below), one command at a time, confirming each succeeded before the next.
   - **no** — skip; mark missing tools as "unavailable" and state which framework checks will be degraded.
   - **let me choose** — iterate through each missing tool individually and ask "install this one? (yes/no)".
3. After required tools are handled, separately ask: **"Shall I also set up the recommended tools (Jest/LWC Jest, VS Code + Salesforce Extension Pack)?"** — same three-option prompt.
4. Never run more than one install command without confirming it succeeded first.

**Install dependency order** (respect this sequence — later tools depend on earlier ones):

```
1. Java JDK     → prerequisite for Code Analyzer / PMD
2. Node.js LTS  → prerequisite for npm, SF CLI, ESLint, Prettier
3. npm          → bundled with Node.js; upgrade to latest after Node install
4. Git          → no dependencies
5. SF CLI       → requires Node.js
6. GH CLI       → no Node dependency
7. ESLint       → requires npm
8. Prettier + prettier-plugin-apex  → requires npm
9. SGD plugin   → requires SF CLI (sf plugins install)
10. Code Analyzer plugin  → requires SF CLI (sf plugins install)
11. [Recommended] Jest + sfdx-lwc-jest  → project-level npm install, requires Node.js and a package.json
12. [Recommended] VS Code + Salesforce Extension Pack  → OS package manager + `code --install-extension`
```

**Install commands by tool and OS:**

| Tool | Windows (`winget`) | macOS (`brew`) | Linux (`apt`) | Any OS (`npm` / `sf`) |
| --- | --- | --- | --- | --- |
| Java JDK 11 | `winget install EclipseAdoptium.Temurin.11.JDK` | `brew install --cask temurin@11` | `sudo apt-get install -y default-jdk` | — |
| Node.js LTS | `winget install OpenJS.NodeJS.LTS` | `brew install node@lts` | add NodeSource repo, then `sudo apt-get install -y nodejs` | — |
| npm (upgrade) | — | — | — | `npm install -g npm@latest` |
| Git | `winget install Git.Git` | `brew install git` | `sudo apt-get install -y git` | — |
| Salesforce CLI | `winget install Salesforce.SalesforceCLI` | `brew install sf` | — | `npm install -g @salesforce/cli` |
| GitHub CLI | `winget install GitHub.cli` | `brew install gh` | add GitHub apt repo, then `sudo apt install -y gh` | — |
| ESLint | — | — | — | `npm install -g eslint` |
| Prettier + plugin | — | — | — | `npm install -g prettier prettier-plugin-apex` |
| SGD plugin | — | — | — | `sf plugins install sfdx-git-delta` |
| Code Analyzer plugin | — | — | — | `sf plugins install @salesforce/sfdx-scanner` |
| Jest + LWC Jest | — | — | — | `npm install --save-dev jest @salesforce/sfdx-lwc-jest` (run inside the project root) |
| VS Code | `winget install Microsoft.VisualStudioCode` | `brew install --cask visual-studio-code` | `snap install code --classic` | — |
| Salesforce Extension Pack | — | — | — | `code --install-extension salesforce.salesforcedx-vscode` (after VS Code is present) |

After all installs complete, re-run every version check from 1b and confirm each tool now reports a version. If any install failed, report the error message and ask the user how to proceed before moving to Step 2.

## Step 2 — The Interview

Ask the five questions below **one at a time**, waiting for each answer before asking the next. Never ask all five at once. Skip a question only if its answer is already unambiguous from the repo (e.g. a committed `sfdx-project.json` and active CI workflow already name the release tool and branch convention). Five questions is the ceiling — do not split any question into sub-questions during the interview; capture everything the user volunteers in a single answer and move on.

1. **Dev org** — "Which Salesforce org is the development source of truth for this project? Run `sf org list` — tell me the alias of the authenticated dev org, or 'none' if you haven't connected one yet." If the user says none, explain the `sf org login web` command, offer to wait, and note that org-aware work cannot start until one is connected.

2. **Pipeline environments** — "What other environments exist in your delivery pipeline (e.g. INT, UAT, PRE-PROD, PROD), and what are the CLI aliases for any you've already authenticated?"

3. **Version control** — "Is this project on Git? If yes: what is the remote origin URL, and what is the default/integration branch (e.g. `main`, `develop`)?"

4. **Team and release process** — "How many developers are actively working in this org or repo, and how do you deploy to higher environments — GitHub Actions, Copado, Gearset, manual `sf project deploy start`, or something else?"

5. **Author identity** — "What name and email address should appear in the `@author` field of every generated Apex class and method header?" Store the answer in `{USER_AGENTS}/identity.json` (shared across all repos). Skip this question if identity was already captured in Step 0a. This question is also asked just-in-time the first time a class/method comment is generated and no author is recorded — see [Author Identity (Required)](../standards/SALESFORCE_APEX_STANDARDS.md#author-identity-required).

## Step 3 — Persist The Answers

After the interview, propose where each answer will be written (per the existing permission-to-persist rule in [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md)) before writing:

| Answer | Destination |
| --- | --- |
| Org aliases, pipeline environments, auth status | `{PROJECT_AGENTS}/project/ENVIRONMENT.md` (project level, this developer's copy — template at [ENVIRONMENT.md](../documentation/ENVIRONMENT.md)) — replace the placeholder table with real aliases following the `{client name}-{project name}-{env}` convention. Use the client and project identifiers the user gave in question 4 or infer from the remote URL. Per developer: never write into another developer's copy or into the repo template. |
| Git remote URL, default branch | [PROJECT_STRUCTURE.md](../documentation/PROJECT_STRUCTURE.md) and/or [WORKFLOW.md](WORKFLOW.md). |
| Team size, release tooling | [WORKFLOW.md](WORKFLOW.md) — add a "Project Process" section documenting the team's actual release process (this supersedes generic guidance, it does not duplicate it). |
| Author name/email | `{USER_AGENTS}/identity.json` (`author_name`, `author_email`) — user-level, shared across all repos. Only write to `{PROJECT_AGENTS}/project/ENVIRONMENT.md` (Author Identity section) if the user explicitly wants a repo-specific identity override for this project. |

Never write personal credentials, tokens, or session details discovered during this interview into any tracked file — see [TRUST_DATA_SECURITY.md](../directives/TRUST_DATA_SECURITY.md).

Once the interview is complete and answers are persisted, proceed with the user's original task using the now-populated project facts.
