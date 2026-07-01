# AI Agent Guardrails

## Purpose And Use

This file defines mandatory behavior for all AI-assisted work in this repository. Read and apply it before analysis, edits, Salesforce org access, Git writes, dependency work, or handoff notes. Put non-negotiable agent behavior, source-control safety, org safety, dependency safety, generated-file handling, and communication rules here.

## Prime Directives

These nine rules apply to every prompt, every task, every session. They take precedence over any skill, standard, or workflow instruction. Read them before acting on any user request.

### 1 — Never Execute A Prompt Verbatim

Do not treat a user's words as a literal script to follow step by step. A prompt is an expression of intent, not a command sequence. Always interpret what the user is trying to achieve before deciding how to act.

### 2 — Understand Context Before Acting

Before touching any file, org, or tool: identify the business problem, the affected Salesforce components, the current state of the codebase or org, and how the requested change fits into what already exists. A well-understood problem rarely needs as much new code as the prompt implies.

### 3 — Decompose And Question Whether The Request Is Truly Required

Break every request into its smallest meaningful parts. For each part, ask: is this actually required to solve the stated problem? Is it already solved elsewhere in the codebase or the org? Would a simpler change or a declarative alternative (Flow, validation rule, formula field, permission set, etc.) achieve the same outcome with less custom code? If yes, propose that first.

### 4 — Prefer Existing And Standard Implementations Over Generating Custom Code

Before writing any Apex class, LWC component, or Flow: search the current codebase for an existing implementation that already covers the requirement (fully or partially). If none exists locally, check whether a standard Salesforce platform feature (standard object, standard field, built-in automation, out-of-the-box component, AppExchange managed package) already solves the problem. Only propose generating custom code after confirming that neither the existing codebase nor the standard platform covers the need. State what was searched and why it was ruled out before proceeding to generation.

### 5 — Never Assume — Always Query Back To The User

If any aspect of the request is ambiguous — the object, the field, the business rule, the target org, the intended behavior on edge cases, the release scope — stop and ask. Do not guess and proceed. A wrong assumption discovered after code is generated or deployed costs more than the time saved by not asking.

### 6 — Pre-Generation Gate: Doubts + At Least Two Alternatives

Before generating any Apex class, LWC component, Flow, or significant metadata change, surface the following to the user in a single structured message:

- **Open questions / doubts** — every ambiguity, missing input, or edge case that has not been answered yet. Number them.
- **Alternative A** — a description of the first solution approach, including its pros and cons relative to the requirement.
- **Alternative B** — a description of a meaningfully different second approach, including its pros and cons. A third alternative may be added if a distinct option exists.
- **Recommendation** — which alternative you recommend and why, in one sentence.
- **Confirmation ask** — "Which approach should I proceed with, and should I resolve open questions X, Y, Z before starting?"

Do not begin generating files until the user has selected an approach and cleared any blocking open questions. This gate applies even when the request seems clear — it surfaces assumptions before they become defects.

### 7 — Conflict Verification Before Any Org Deployment

Before deploying to any Salesforce org (sandbox, scratch, UAT, production, or any other), retrieve the current org version of every component in the deploy scope and diff it against the local version. Classify any difference as: local-only (safe to deploy), org-only (must be merged in first), or same-component conflict (requires user decision before proceeding). Never deploy over an org-side change without the user's explicit acknowledgement of what will be overwritten. See [DEPLOYMENT.md](../workflows/DEPLOYMENT.md) for the full procedure.

### 8 — Persist User Decisions Into The Agent Instructions

When the user makes a decision in response to a question or alternative presented under Prime Directive 6, evaluate whether that decision is durable and reusable — a naming choice, an architectural pattern preference, a process rule, a platform constraint. If it is, propose persisting it as a concrete example or rule in the appropriate `.agents` file (standard, workflow, project fact, or skill adaptation) before moving on. Name the exact destination file and the exact text to add, and ask for permission before writing. Do not silently discard decisions that future iterations would benefit from knowing.

### 9 — Track Generated File Iterations In Memory Only

Every time a file (Apex class, LWC component, Flow, metadata) is generated or modified in a session, track the iteration count for that file in working memory. The first generation of a file is iteration 1; each subsequent modification of the same file in the same session increments the count. When reporting on a file, reference its current iteration number so the user knows how many rounds of change have occurred (e.g. "AccountService.cls — iteration 2"). Iteration numbers are session-scoped working memory only — never write them into file names, class names, comments, metadata, or any persisted file. They exist solely to give the user and the agent a shared reference point during a work session.

## Scope Discipline

- Treat the user's current instruction as the source of truth.
- If the user asks for analysis only, do not edit files, stage files, commit, deploy, run destructive commands, or modify the org. Deploy validation and org test runs are allowed only if the user explicitly allows verification checks in analysis-only mode.
- If the user asks whether behavior already exists, answer the current-state question before proposing changes.
- Use ticket solution tables, refinement sections, and latest comments as authoritative over older summary wording.
- For this project requirement work, perform the project requirement-validity gate in [SPECIFICATION.md](../project/SPECIFICATION.md) before feasibility analysis or implementation. Treat ambiguous object mappings, wrong data types, and mismatches between client wording and org metadata as blockers to clarify, not details to guess through.
- Keep unrelated local changes untouched.

## Source Control Safety

Agents may inspect Git state. Agents must not perform these actions without explicit confirmation:

- Commit.
- Push.
- Merge.
- Rebase.
- Reset.
- Restore or checkout files in a way that discards user work.
- Delete branches.
- Remove worktrees.
- Force operations.

Before any approved Git write:

1. Run `git status --short`.
2. List exactly which files will be staged or affected.
3. Inspect the relevant file diffs before staging.
4. Stage only files, hunks, or lines that are directly required by the current requirement or approved solution part.
5. Exclude unrelated local changes, retrieve noise, formatting churn, and generated artifacts.
6. Do not stage a whole file when only a smaller hunk or line belongs to the requested scope, especially for shared metadata such as permission sets, layouts, profiles, Experience bundles, or object metadata.
7. Treat over-staging as dependency injection: it can introduce unapproved metadata dependencies into the commit, deployment, pull request, or release.
8. Use task-specific commit messages if a commit is explicitly requested.

## Salesforce Org Safety

Agents may inspect local source by default. Org reads and writes depend on the user's instruction and environment.

Require explicit confirmation before:

- Deploying.
- Running anonymous Apex.
- Executing data mutations.
- Assigning permissions.
- Changing user access.
- Updating Experience Cloud site metadata in an org.
- Running scripts that call Salesforce APIs with write access.

Deploy dry-runs, deploy validations, and Apex test runs may be executed without additional confirmation when the target org and scope are known.

When org comparison is approved:

- Retrieve or query only the required components.
- Compare normalized content where formatting noise is likely.
- State whether local source, org active version, or org latest version is being used.

## Dependency and Script Safety

Do not install packages, update lock files, execute downloaded scripts, or run networked build tools without approval.

Allowed by default:

- Read-only file searches.
- Local static inspection.
- Local tests that do not mutate external systems or require network access.

Needs confirmation:

- `npm install`, `npm update`, `npx` that downloads packages, Maven/Gradle dependency updates, package-manager lockfile updates.
- Scripts that access external systems.
- Scripts that transform many files.

## Generated Files

Do not commit generated files unless they are expected project artifacts.

Usually exclude:

- `.sf`
- `.sfdx`
- debug logs
- temp retrieve folders
- coverage output
- local PMD reports
- scratch scripts
- generated package files not requested by the user
- `.agents/.local-config.json` (local-only identity, credentials, and update-check operational state — never framework content; see `.agents/.local-config.template.json` for the tracked shape reference)

## Communication Standard

When proposing or completing work, be exact:

- Name files and metadata members.
- Name the org alias if an org was touched.
- Name deploy or validation IDs when applicable.
- State what was not done because it requires manual confirmation.

## Code Comment Authorship

Generated Apex and LWC comment headers (`@author`/`@last modified by`) must use the project's configured human author identity from [ENVIRONMENT.md](../project/ENVIRONMENT.md#author-identity) — see [SALESFORCE_APEX_STANDARDS.md](../standards/SALESFORCE_APEX_STANDARDS.md#author-identity-required) for the full rule and the just-in-time question to ask when it is missing. Never attribute generated code comments to an AI model, assistant, or tool (e.g. `OpenAI`, `Anthropic`, `Claude`, `ChatGPT`, `GPT`, `Copilot`, `Gemini`, `AI Assistant`) under any circumstance.

## Chat Brevity While Working

While the user is waiting in the chat session for work to complete (reading, searching, editing, running checks), keep interim status text to a maximum of one short phrase per update — state what is happening, not why or how, and skip narration of routine tool calls entirely when no update is needed.

This brevity rule does **not** apply when the user must be asked something or given a decision to make: confirmation requests ([MANUAL_CONFIRMATION_GATES.md](MANUAL_CONFIRMATION_GATES.md)), conflict-resolution escalations ([DEPLOYMENT.md](../workflows/DEPLOYMENT.md)), clarifying questions, or the final summary of completed work. In those cases give the user as much detail as they need to decide: exact options, affected files, risks, and consequences — do not compress a decision point into one phrase for the sake of brevity.

This governs the agent's own narration during a turn. It is independent of the terse-collaboration style in [LEAN_CODE_STANDARDS.md](../standards/LEAN_CODE_STANDARDS.md#token-efficient-collaboration-refactor-of-caveman), which covers review-comment formatting and surgical-diff discipline rather than in-progress status updates.
