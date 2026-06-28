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
4. Either way, proceed to Step 1 below in the same turn — this question does not block the rest of bootstrap.

## Step 1 — Required Tooling Check

Before asking the interview questions, check locally for the tools this framework assumes. Report what is present/missing; do not install anything without confirmation (installing dependencies/CLI plugins is approval-gated per [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md)).

| Tool | Check | Why it matters |
| --- | --- | --- |
| Salesforce CLI (`sf`) | `sf --version` | Required for org auth, retrieve/deploy, Apex test execution — almost every skill in `.agents/skills/sf-platform-*` assumes it. |
| Git | `git --version` | Required for the [Workflow](WORKFLOW.md) and [Pull Request](PULL_REQUEST.md) processes. |
| `sfdx-git-delta` plugin | `sf plugins` (look for `sfdx-git-delta`) | Generates a delta package.xml from a git diff so deploys stay scoped to the actual change — directly supports the scoped-deploy rule in [DEPLOYMENT.md](DEPLOYMENT.md). |
| Code Analyzer (`@salesforce/sfdx-scanner` or `sf code-analyzer`) | `sf plugins` / `sf code-analyzer --help` | Used by `sf-dx-analyzer` and [PMD_APEX_RULESET.md](../standards/PMD_APEX_RULESET.md). |

If a tool is missing, tell the user and ask whether to proceed without it (some checks become "unavailable: tool not installed" rather than blocking) or to install it now (requires confirmation per the gates above).

## Step 2 — The Interview

Ask the questions below **one at a time**, waiting for each answer before asking the next. Do not dump the whole list at once. Skip a question if its answer is already evident from the repo (e.g. a `package.xml` and active CI workflow already show the release process). Aim for 5-10 questions total — combine closely related questions rather than asking every line item separately if the user is clearly in a hurry.

### A. Org source of truth

1. "Which Salesforce org should be the development source of truth for this project? Run `sf org list` — if an authenticated org is already available, which alias is it?" If no org is authenticated yet, explain that the user needs to run `sf org login web --alias <alias> --instance-url <url>` (or the appropriate auth flow for their org type) before any org-aware work can start, and offer to wait or proceed read-only/source-only until that's done.
2. "What other environments exist in the pipeline (INT, UAT, QA, POC, PRE-PROD, PROD), and do you have CLI aliases authenticated for any of them yet?"

### B. Version control

3. "Is this project using Git? If so, what is the remote origin (e.g. GitHub URL)?" If no remote exists yet, ask whether one should be created/linked, and treat creating a remote or pushing as a confirmation-gated Git action.
4. "What is the default/integration branch (e.g. `main`, `develop`), and is there a branch-per-environment or trunk-based convention?"

### C. Team and process

5. "Are other developers actively working in this org/repo? Roughly how many, and do they work in the same sandbox or separate ones?"
6. "How are conflicts between developers typically resolved today — manual merge review, a designated org/branch owner, scheduled merge windows, something else?"
7. "How is this project released to higher environments — GitHub Actions (or other CI), Copado, Gearset, manual `sf project deploy start`, or another tool?"

### D. Naming and conventions

8. "What is the client/customer identifier and the project identifier to use in the org alias convention `{client name}-{project name}-{env}`?" (See [ENVIRONMENT.md](../project/ENVIRONMENT.md#org-alias-naming-convention).)
9. "Does this project already follow a specific Apex/LWC naming or layering convention beyond this framework's defaults, or should the framework defaults in [SALESFORCE_APEX_STANDARDS.md](../standards/SALESFORCE_APEX_STANDARDS.md) apply as-is?"

## Step 3 — Persist The Answers

After the interview, propose where each answer will be written (per the existing permission-to-persist rule in [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md)) before writing:

| Answer | Destination |
| --- | --- |
| Org aliases, environments, auth status | [ENVIRONMENT.md](../project/ENVIRONMENT.md) — replace the placeholder table with real aliases following the `{client name}-{project name}-{env}` convention. |
| Git remote, branch convention | [PROJECT_STRUCTURE.md](../project/PROJECT_STRUCTURE.md) and/or [WORKFLOW.md](WORKFLOW.md). |
| Team size, conflict resolution, release tooling | [WORKFLOW.md](WORKFLOW.md) — add a "Project Process" section documenting the team's actual conflict-resolution and release process (this supersedes generic guidance, it does not duplicate it). |
| Naming/layering conventions | [SALESFORCE_PROJECT_BEST_PRACTICES.md](../standards/SALESFORCE_PROJECT_BEST_PRACTICES.md), only if the project's convention differs from the framework default — note the override there rather than rewriting the default. |

Never write personal credentials, tokens, or session details discovered during this interview into any tracked file — see [TRUST_DATA_SECURITY.md](../directives/TRUST_DATA_SECURITY.md).

Once the interview is complete and answers are persisted, proceed with the user's original task using the now-populated project facts.
