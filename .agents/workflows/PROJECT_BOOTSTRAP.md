# Project Bootstrap

## Purpose And Use

This file owns two first-time checks: (1) whether this framework itself should be committed to the repository's remote or kept local-only, and (2) the setup interview that runs when `.agents/project/*` is still empty boilerplate. Read it the first time `AGENTS.md` is read in a session, before any other implementation work, whenever either detection condition below is met. Put the bootstrap detection rules, the framework-persistence question, the required-tooling check, and the interview question set here; put the durable answers themselves in the relevant `.agents/project/*` file (or `.gitignore` for the persistence decision), never in this file.

## Detection: Is This Project Still Unconfigured?

Treat the project as **not yet bootstrapped** if `.agents/project/ENVIRONMENT.md` still contains only its boilerplate placeholders (e.g. `{client name}-{project name}-{env}`, "Not yet documented") and/or most other `.agents/project/*.md` files still read "No durable ... details have been documented here yet." If the project is already configured (real org aliases, real architecture notes, etc. are present), skip this entire workflow and proceed with the normal [Default Work Pattern](../../AGENTS.md#default-work-pattern).

When the detection condition is met, run this workflow before starting the user's actual task, unless the user's request is itself trivial/read-only (e.g. "what does this repo do") — in that case answer the request first, then offer to run the bootstrap interview.

## Step 0 — Framework Persistence (Runs Once, Independent Of The Detection Above)

This step has its own trigger, separate from the project-config detection above: run it the first time this framework is read in this repository's git context, regardless of whether `.agents/project/*` is already populated. Skip it if the decision has already been recorded (see below).

Detection: run this check if `AGENTS.md` and `.agents/` are currently untracked by git (`git status --porcelain AGENTS.md .agents` shows them as `??`) **and** `.gitignore` does not yet contain a `# sf-agentic-coding-framework` marker line. If either `AGENTS.md`/`.agents/` are already tracked/committed, or the marker line already exists in `.gitignore`, the decision was already made — skip this step.

1. Ask the user: "Should this AI-agent instruction framework (`AGENTS.md` and `.agents/`) be committed to this repository's remote and shared with the team, or kept local-only on this machine?"
2. **If shared/remote**: take no special action — `AGENTS.md` and `.agents/` will be staged and committed normally as part of whatever the user later approves per [WORKFLOW.md](WORKFLOW.md) and [AGENT_GUARDRAILS.md](../directives/AGENT_GUARDRAILS.md). Record the decision by adding a `# sf-agentic-coding-framework: tracked in git (shared) — see PROJECT_BOOTSTRAP.md` comment line near the top of `.gitignore` (creating the file if it doesn't exist) so this question is not asked again.
3. **If local-only**: add `AGENTS.md` and `.agents/` to `.gitignore` (with the same marker comment, e.g. `# sf-agentic-coding-framework: local-only, do not commit — see PROJECT_BOOTSTRAP.md`), then check whether they are already committed in this repo's history (`git log --oneline -- AGENTS.md .agents`). If they are, tell the user that `.gitignore` alone will not stop already-tracked files from being tracked, and ask whether to untrack them now via `git rm --cached -r AGENTS.md .agents` (leaves the files on disk, removes them from the index) — this is a Git write and requires explicit confirmation per [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md) before running it.
4. Either way, also add `.agents/.local-config.json` to `.gitignore` (regardless of the shared/local-only answer) — it stores personal identity and update-check operational state for the [Daily Update Check](../directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic), and must never be committed even when the rest of the framework is shared. Then create `.agents/.local-config.json` from the tracked template `.agents/.local-config.template.json` if it does not already exist on disk (the template is the committed shape reference; the live `.local-config.json` is the untracked local instance). At this point, ask the user for their author name and email (Question E from Step 2 may be asked here and skipped later) and pre-populate the `identity.author_name` and `identity.author_email` fields in `.local-config.json`; the `update_check` fields start blank and are populated by the first [Daily Update Check](../directives/AGENTIC_FRAMEWORK.md#daily-update-check-automatic).
5. Proceed to Step 1 below in the same turn — this question does not block the rest of bootstrap.

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

5. **Author identity** — "What name and email address should appear in the `@author` field of every generated Apex class and method header?" Store the answer in `.agents/.local-config.json` (gitignored, personal). This question is also asked just-in-time the first time a class/method comment is generated and no author is recorded — see [Author Identity (Required)](../standards/SALESFORCE_APEX_STANDARDS.md#author-identity-required).

## Step 3 — Persist The Answers

After the interview, propose where each answer will be written (per the existing permission-to-persist rule in [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md)) before writing:

| Answer | Destination |
| --- | --- |
| Org aliases, pipeline environments, auth status | [ENVIRONMENT.md](../project/ENVIRONMENT.md) — replace the placeholder table with real aliases following the `{client name}-{project name}-{env}` convention. Use the client and project identifiers the user gave in question 4 or infer from the remote URL. |
| Git remote URL, default branch | [PROJECT_STRUCTURE.md](../project/PROJECT_STRUCTURE.md) and/or [WORKFLOW.md](WORKFLOW.md). |
| Team size, release tooling | [WORKFLOW.md](WORKFLOW.md) — add a "Project Process" section documenting the team's actual release process (this supersedes generic guidance, it does not duplicate it). |
| Author name/email | `.agents/.local-config.json` (`identity.author_name`, `identity.author_email`) — gitignored, local-only. Only write to [ENVIRONMENT.md](../project/ENVIRONMENT.md#author-identity) if the user explicitly wants a team-shared author identity committed to the repo. |

Never write personal credentials, tokens, or session details discovered during this interview into any tracked file — see [TRUST_DATA_SECURITY.md](../directives/TRUST_DATA_SECURITY.md).

Once the interview is complete and answers are persisted, proceed with the user's original task using the now-populated project facts.
