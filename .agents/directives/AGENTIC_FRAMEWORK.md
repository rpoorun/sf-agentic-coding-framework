# Agentic Framework Prompt

## Purpose And Use

This file defines the governing framework for maintaining this repository's agent instructions and contains a reusable prompt that can be pasted into another AI coding agent to reorganize that repository's `AGENTS.md` and `.agents` instruction folders. Use it when bootstrapping, rebuilding, refactoring, or expanding agent instructions so the target repository has a clear separation between directives, standards, skills, workflows, and project-specific references, with explicit folder labels, file naming, precedence rules, section responsibilities, and no duplicated scope.

## Installing This Framework Into A New Repository

When this framework is installed into a new or existing Salesforce repository, `.agents/skills/` ships with only a curated starting set of skill folders. Treat this as a baseline, not the full catalog.

### Skill Source Repositories

| Source | URL | Folder layout | Notes |
| --- | --- | --- | --- |
| Salesforce `sf-skills` | https://github.com/forcedotcom/sf-skills | skills live under `skills/<skill-name>/` | Broad official catalog: Apex, Flow, LWC, custom object/field/tab/application, permission sets, validation/sharing rules, FlexiPage, list views, metadata deploy/retrieve, SOQL, data management, SLDS, Code Analyzer, plus optional Data Cloud/OmniStudio/Agentforce/Commerce/mobile families. |
| Clientell `salesforce-skills` | https://github.com/Clientell-Ai/salesforce-skills | skills live under `skills/<skill-name>/` (the repo's `.agents/skills` and `.claude/skills` folders are symlinks into that same `skills/` directory) | Compact 18-skill catalog prefixed `sf-` (`sf-apex`, `sf-test`, `sf-flow`, `sf-lwc`, `sf-soql`, `sf-security`, `sf-deploy`, `sf-data`, `sf-schema`, `sf-debug`, `sf-agentforce`, `sf-permissions`, `sf-integration`, `sf-docs`, `sf-diagram`, `sf-omnistudio`, `sf-find`, `sf-eval`). Also installable via `npx skills add Clientell-Ai/salesforce-skills` or its `install.sh`. |
| Ponytail | https://github.com/DietrichGebert/ponytail | single rule file at `.agents/rules/ponytail.md` (also mirrored for other tools) | **Not Salesforce-specific.** General-purpose "lazy senior dev" lean-coding decision ladder (YAGNI, reuse-first, minimum-code-last) for any language. Used only as the source doctrine for [LEAN_CODE_STANDARDS.md](../standards/LEAN_CODE_STANDARDS.md); never installed as its own `.agents/skills/` folder. |
| Caveman | https://github.com/JuliusBrussee/caveman | multiple skills under `skills/<skill-name>/` (`caveman`, `caveman-review`, `caveman-compress`, …) plus agents under `agents/` | **Not Salesforce-specific.** General-purpose token-efficient communication mode and surgical, scope-bounded editing discipline for any language. Used only as the source doctrine for [LEAN_CODE_STANDARDS.md](../standards/LEAN_CODE_STANDARDS.md); never installed as its own `.agents/skills/` folder. |
| sfdc-trigger-framework | https://github.com/kevinohara80/sfdc-trigger-framework | single base class at `src/classes/TriggerHandler.cls` (+ test class) | **Salesforce-native, MIT licensed.** Minimal `TriggerHandler` base class providing context dispatch, max-loop-count recursion control, and a static bypass API. Vendored verbatim (not refactored) into `sf-platform-apex/assets/TriggerHandler.cls` because it is already Apex-native with no general-purpose content to translate. Mandated by [APEX_TRIGGER_FRAMEWORK.md](../standards/APEX_TRIGGER_FRAMEWORK.md). |
| apex-consts | https://github.com/beyond-the-cloud-dev/apex-consts | classes under `force-app/main/default/classes/` (`Consts.cls` root + `concrete-consts/{SObject}Consts.cls`) | **Salesforce-native, MIT licensed.** Lazy-singleton constants pattern (one `{SObject}Consts` class per object, exposed via `Consts.{OBJECT}`) replacing hardcoded picklist/API-name literals. Vendored verbatim into `sf-platform-apex/assets/Consts.cls` and `assets/concrete-consts/AccountConsts.cls`. Mandated by [APEX_CONSTANTS_FRAMEWORK.md](../standards/APEX_CONSTANTS_FRAMEWORK.md). |

The two `sf-skills`/`salesforce-skills` sources publish self-contained skill folders (`SKILL.md` plus optional `assets/`, `references/`, `scripts/`) following the open Agent Skills spec at https://agentskills.io/, and get installed under `.agents/skills/`. Ponytail and Caveman are general web-development sources with no Salesforce awareness: never install or link their content directly — always refactor their guidance into Apex/LWC-specific language inside [LEAN_CODE_STANDARDS.md](../standards/LEAN_CODE_STANDARDS.md) and the `sf-platform-apex`/`sf-platform-lwc` skills, the same way the synthesis procedure below requires for any other source.

sfdc-trigger-framework and apex-consts are the opposite case: they are already small, dependency-free, Salesforce-native code, so they are vendored verbatim as `.cls` template assets under `sf-platform-apex/assets/` rather than refactored into prose. When this framework is (re-)installed or refreshed, re-fetch both repositories and diff the vendored classes against the latest upstream version — update `assets/TriggerHandler.cls`, `assets/TriggerHandlerTest.cls`, and `assets/Consts.cls` if upstream has changed, following the same approval-before-merge discipline as [Master Framework Repository And Sync Workflow](#master-framework-repository-and-sync-workflow), and update [APEX_TRIGGER_FRAMEWORK.md](../standards/APEX_TRIGGER_FRAMEWORK.md) / [APEX_CONSTANTS_FRAMEWORK.md](../standards/APEX_CONSTANTS_FRAMEWORK.md) if the usage pattern itself changed upstream.

### Mandatory Synthesis Procedure (do not copy upstream skills verbatim)

Skill folders pulled from any source above must never be installed under their raw upstream name or left as a verbatim copy. This repository requires every skill in `.agents/skills/` to be **synthesized**: renamed to the local `sf-{cloud}-{name}` convention, deduplicated against any overlapping skill from the other source, and reformatted to the standard header documented in [SALESFORCE_SKILLS.md](../skills/SALESFORCE_SKILLS.md#standard-skill-file-format). Repeat this procedure every time a new skill is added, whether at initial install or later expansion:

1. **Fetch** the target skill folder(s) from the source repository (clone or sparse-checkout; do not hand-author content that exists upstream).
2. **Classify the cloud** — pick the `{cloud}` segment from: `platform`, `design`, `dx`, `security`, `agentforce`, `integration`, `omnistudio`, `tooling`, `meta`, or a new domain (`commerce`, `mobile`, `data360`, …) if none fit.
3. **Check for an existing overlapping skill** in `.agents/skills/` covering the same task type (use the router table in `SALESFORCE_SKILLS.md`). If one exists, this is a merge, not a new addition.
4. **Merge when overlapping**: pick the more detailed/complete source as the primary body, fold the other source's non-redundant guidance into a `## Merged Source Material` section at the end of the same `SKILL.md`, and bring over any unique `assets/`/`references/`/`scripts/` files into namespaced subfolders (e.g. `references/from-<original-folder-name>/`) so nothing upstream-unique is lost.
5. **Apply the standard header** — frontmatter (`name`, `description`, `metadata.version`, `metadata.cloud`, `metadata.synthesized: true`, `metadata.sources`) followed by the `# sf-{cloud}-{name}: <Title>` heading and the field table, exactly as shown in `SALESFORCE_SKILLS.md`. Do not invent a different header shape.
6. **Rename the folder** to `sf-{cloud}-{name}` and delete the original upstream-named folder(s) that were merged into it — do not leave both the raw copy and the synthesized copy on disk.
7. **Update the router table** in [SALESFORCE_SKILLS.md](../skills/SALESFORCE_SKILLS.md) so the task type resolves to the new folder name, and add the skill to the manual-confirmation review if it can mutate org state, deploy metadata, or write data.

Aura Components have no upstream skill in either source repository as of this writing (Salesforce treats Aura as legacy in favor of LWC). Until one of the source repositories publishes one, route Aura work through `SALESFORCE_APEX_STANDARDS.md` and `SALESFORCE_PROJECT_BEST_PRACTICES.md` and apply the same guardrails (sharing, CRUD/FLS, no hardcoded IDs) by analogy with `sf-platform-lwc`.

Do not bulk-copy unrelated specialized skill families (Data Cloud, OmniStudio, Agentforce, Commerce, mobile, UI bundles) unless the project actually uses that technology — see "Optional Specialized Skills" in `SALESFORCE_SKILLS.md`. When one of those families is added, apply the same synthesis procedure to it.

## Master Framework Repository And Sync Workflow

This repository (`AGENTS.md` plus `.agents/`) is itself a reusable framework. Its master/canonical copy lives at:

**https://github.com/rpoorun/sf-agentic-coding-framework**

Once this framework is cloned or installed into a client/project repository (a "local install"), that local install diverges over time: it picks up project-specific facts in `.agents/project/`, client-specific overrides in standards/workflows, and possibly new or re-synthesized skills. Two sync directions are expected and must be handled differently.

### Scenario 1 — Pulling Framework Updates Into A Local Install (Update / Upgrade)

Trigger: the user of a local install wants the latest directives, standards, skills, or workflow updates from the master framework repository (new release, or `main`/`master` HEAD).

Procedure:

1. Fetch the master framework into an isolated temp location — clone `https://github.com/rpoorun/sf-agentic-coding-framework` (or the requested tag/release) into a scratch/temp folder. Never fetch directly on top of the local install's working tree.
2. Diff the temp copy against the local install's `AGENTS.md` and `.agents/` file-by-file. Classify each difference as: new file (master added something local doesn't have), changed file (both sides touched it), or local-only file (project facts, client overrides — master has no equivalent).
3. Merge with **local instructions taking precedence**: the existing local install's content supersedes the incoming update wherever they conflict. The update is additive/advisory, not authoritative, over local tailoring. New files with no local equivalent (new skills, new directive sections) can be added directly. Changed shared files (e.g. a directive or standard both sides edited) require a reconciled merge, not a blind overwrite.
4. Detect impact level before applying anything: classify each incoming change as **minor** (wording, additive guidance, new optional skill) or **major** (changed confirmation gates, changed mandatory workflow steps, renamed/restructured folders, removed skills the project depends on, conflicting coding standards).
5. **Stop and seek explicit user approval before merging** when the change is major, or when any conflict exists between local and incoming content. Present the user with: which files are affected, a summary of what changed, why it's classified minor/major, and the specific consequence of accepting vs. rejecting each conflicting change. Do not silently resolve conflicts in favor of either side.
6. Once approved, apply the merge, re-run the synthesis procedure above for any newly pulled skills, and report exactly what was merged, what was rejected/kept-local, and what still needs a follow-up decision.
7. Never overwrite `.agents/project/*` (project-specific facts) from the master framework — those files have no upstream equivalent and are always local-only.

### Scenario 2 — Forking Learned Improvements Back To The Master Framework (Contribute Back)

Trigger: while working in a local install, the agent or user identifies a generally-applicable improvement — a new synthesized skill, a hardened guardrail, an updated directive, a clarified workflow step — that is not specific to the current project and would benefit other projects using this framework.

Procedure:

1. Before persisting anything as a candidate for contribution, apply the existing learning rules in "Framework Maintenance Rules" below: distinguish durable, reusable learning from project-specific facts, and get the user's permission to persist it locally first.
2. Isolate only the generally-applicable files/sections — never include `.agents/project/*` content, client names, org aliases, credentials, or any project-specific fact when preparing content for the master repository.
3. Propose forking `https://github.com/rpoorun/sf-agentic-coding-framework` (or pushing a branch/PR against it, per the user's preferred contribution flow) and isolating the candidate change there, scoped to exactly the directive/standard/skill/workflow file(s) affected.
4. State clearly to the user: which files are being proposed for upstream contribution, why they are generic enough to apply beyond this project, and that this is a candidate for the maintainers to review and merge into the next release — not a guaranteed or automatic merge.
5. Treat pushing to, branching, or opening a PR against the master repository as a Git/source-control action requiring explicit user confirmation under the existing confirmation gates (see [AGENT_GUARDRAILS.md](AGENT_GUARDRAILS.md) and [MANUAL_CONFIRMATION_GATES.md](MANUAL_CONFIRMATION_GATES.md)) — do not push or open a PR without that confirmation.
6. After the user approves, perform the fork/branch/PR with the isolated content only, and report the resulting URL back to the user.

### Sanitizing Instructions Before Any Master Framework Contribution

Always sanitize instruction content before it is proposed, forked, branched, or pushed toward the master framework repository, even in a draft or preview. This applies whenever step 2 of Scenario 2 is performed, and any other time content from `.agents/` or `AGENTS.md` is shared outside the local install.

Scan for and remove or genericize:

- Client, customer, or program names (e.g. a literal company name embedded in a title, purpose statement, or example).
- Org aliases, sandbox/production URLs, usernames, or email addresses — replace with the `{client}-{project}-{env}` placeholder pattern documented in [ENVIRONMENT.md](../project/ENVIRONMENT.md#org-alias-naming-convention).
- Real ticket/case IDs, Jira keys, or support-case numbers — replace with a generic placeholder (e.g. `PROJ-123`) or drop the identifier entirely if it adds no instructional value.
- Internal consultancy, vendor, or partner names used as a stand-in for "the project's baseline standard" — replace with a bracket placeholder such as `[Org]` and a note that the local install should substitute its own organization's name.
- Any credential, token, secret, or PII, per [TRUST_DATA_SECURITY.md](TRUST_DATA_SECURITY.md) — these must never appear in any file regardless of destination.

For every `.agents/project/*` file specifically: project files are local-only by definition (see Scenario 1, step 7) and must never be forked or pushed to the master repository at all, sanitized or not. If a pattern discovered in a project file is generally useful, extract the *generic lesson* into the appropriate `directives`, `standards`, `skills`, or `workflows` file as a boilerplate example (placeholders, not real facts) — do not push the project file itself.

When in doubt whether a string is client-identifying, treat it as client-identifying and ask the user before including it in anything destined for the master repository.

## Framework Maintenance Rules

- Use this framework before creating, moving, renaming, or expanding any file under `.agents` or any major section in `AGENTS.md`.
- Treat `directives` as the highest authority. Prime directives, safety gates, confirmation gates, trust boundaries, and security rules must not be weakened by standards, skills, workflows, or project notes.
- Prefer project-specific instructions when they exist for the same scope. If no project-specific instruction exists, fall back to standards, skills, workflows, or general guidance as appropriate.
- Keep project-specific instructions isolated in `.agents/project`; keep general or reusable instructions isolated in `.agents/standards`, `.agents/skills`, `.agents/workflows`, or `.agents/directives`.
- Do not duplicate the same instruction in multiple files. Put the authoritative version in the correct folder and use cross-links from other files.
- When expanding agentic content, first search for an existing file that already owns the same scope. Update that file instead of creating a parallel instruction.
- When an agent discovers a repeatable project pattern, developer preference, architectural decision, validation habit, or workflow decision while building, it may propose persisting that learning into the appropriate `.agents` file.
- The agent must request permission before persisting newly identified project patterns or decision-making rules into `.agents`. The request should name the proposed file, the pattern, the source evidence, and why it is durable enough to preserve.
- If permission is granted, store project-specific learned patterns in `.agents/project` or capability routing lessons in `.agents/skills`, depending on whether the content is a project fact or a reusable skill adaptation.
- Do not persist temporary ticket details, secrets, credentials, sensitive data, transient run IDs, or one-off implementation notes into the agent framework.

## Copy-Paste Prompt

```text
You are working in a repository that uses AGENTS.md and a .agents folder for AI-agent operating instructions.

Your task is to inspect the existing AGENTS.md file and all instruction Markdown files under .agents, then reorganize or expand them into a clear, durable framework that another agent can understand quickly.

Do not treat this as a simple file move. First read the current instructions, identify what each file is trying to do, then classify it by purpose.

This framework is not only for reorganizing another repository. It also governs how to rebuild the current repository's agent framework, how to add new agentic content, and how to update existing files without duplicating instructions for the same scope.

Target folder architecture and labels:

.agents/
  directives/    # Mandatory rules: what the agent must obey.
  standards/     # Quality rules: what good work must look like.
  skills/        # Capability routing: which skill/tool/capability applies.
  workflows/     # Repeatable processes: which steps the agent follows.
  project/       # Repository facts: what is true about this project.

Folder scope and function:

directives/
- Mandatory operating rules.
- Safety gates, security rules, trust boundaries, confirmation requirements, source-control constraints, and actions agents must not take without approval.
- These files answer: "What must the agent obey?"
- Put non-negotiable instructions here, even when they are project-specific.
- Typical files:
  - AGENT_GUARDRAILS.md
  - MANUAL_CONFIRMATION_GATES.md
  - TRUST_DATA_SECURITY.md
  - AGENTIC_FRAMEWORK.md

standards/
- Reusable quality standards.
- Coding standards, documentation standards, static-analysis standards, naming conventions, Apex or language standards, formatting rules, and review criteria.
- These files answer: "What does good work look like?"
- Put stable quality expectations here. A standard can be reusable across projects or locally adapted for the repository.
- Typical files:
  - DOCUMENTATION.md
  - SALESFORCE_PROJECT_BEST_PRACTICES.md
  - SALESFORCE_APEX_STANDARDS.md
  - PMD_APEX_RULESET.md

skills/
- Capability and routing guidance.
- Skill selection, tool-routing, build/development capability guidance, and adaptations of external skill packs or reusable agent capabilities.
- These files answer: "Which capability should the agent use for this kind of task?"
- Do not put ordinary process checklists here unless they are truly about selecting or adapting a capability.
- Put guidance here when the file maps task types to agent skills, tools, plugins, or build/development capabilities.
- Typical files:
  - SALESFORCE_SKILLS.md
  - LWC_SKILL_ROUTER.md
  - INTEGRATION_SKILL_ROUTER.md

workflows/
- Repeatable task processes.
- Development flow, testing flow, deployment validation flow, pull-request flow, implementation planning, release handoff, and recurring task sequences.
- These files answer: "What steps should the agent follow?"
- Put ordered procedures here. A workflow may cite directives, standards, skills, and project facts, but should not duplicate them in full.
- Typical files:
  - WORKFLOW.md
  - DEVELOPMENT.md
  - TESTING.md
  - PULL_REQUEST.md
  - IMPLEMENTATION_PLAN.md

project/
- Repository-specific facts.
- Architecture, environment aliases, schema, integrations, glossary, product requirements, technical requirements, UX context, and project-specific assumptions.
- These files answer: "What is true about this project?"
- Put durable project knowledge here. Do not put generic coding rules here unless the project has a specific override.
- Typical files:
  - PROJECT_STRUCTURE.md
  - ARCHITECTURE.md
  - ENVIRONMENT.md
  - SCHEMA.md
  - INTEGRATIONS.md
  - GLOSSARY.md
  - SPECIFICATION.md
  - PRODUCT_REQUIREMENTS.md
  - TECHNICAL_REQUIREMENTS.md
  - USER_EXPERIENCE.md

Instruction precedence:

1. Current user instruction for the active task.
2. Prime directives, safety gates, trust/security rules, and manual confirmation gates from directives.
3. Project-specific instructions in project, when they exist for the same scope.
4. Workflow instructions for the task being executed.
5. Standards that define expected quality or implementation shape.
6. Skills and skill-routing guidance for choosing the right capability.
7. General platform or language practice.

Project-specific instructions take priority over standards, skills, workflows, and generic guidance when they are available and do not conflict with directives. If project-specific instructions are missing, fall back to standards and general instructions. Never use a project-specific note, workflow, standard, or skill file to override the prime directives or mandatory confirmation gates.

Naming and labeling rules:

- Keep the root entry file named AGENTS.md.
- Use lowercase directory names that label the function of the folder: directives, standards, skills, workflows, project.
- Use uppercase Markdown file stems for instruction files: AGENT_GUARDRAILS.md, DEVELOPMENT.md, DOCUMENTATION.md.
- Use one exception only when the user explicitly requests a specific filename; record that exception in AGENTS.md.
- Use short, descriptive file names based on the file's function, not the current ticket.
- Avoid vague file names such as NOTES.md, MISC.md, GENERAL.md, or README.md inside .agents unless the repository has a clear convention for them.
- Do not use "ai" as a long-term folder label if the files inside actually represent directives, standards, skills, workflows, or project facts.
- Do not use "project-specific" when "project" is enough.
- File titles should match the file function in title case, for example "# Salesforce Apex Standards" for SALESFORCE_APEX_STANDARDS.md.

Required AGENTS.md structure:

1. Keep AGENTS.md at the repository root as the entry point and router.
2. Add or keep a "Purpose And Use" section explaining that AGENTS.md is the first file agents must read.
3. Add a "Required Reading Order" section that points to the most important files in the new folder structure.
4. Add a "Documentation Layout" section explaining what each .agents subfolder contains.
5. Add reference tables for:
   - Directive Reference Files
   - Standards Reference Files
   - Skill Reference Files
   - Workflow Reference Files
   - Project-Specific Reference Files
6. Keep mandatory safety and confirmation rules visible in AGENTS.md, but route detailed rules to .agents/directives.
7. Update every link in AGENTS.md after moving files.

Recommended AGENTS.md section responsibilities:

- Purpose And Use: explains the role of AGENTS.md as the first-read router.
- Project Guidance: short links to the most common workflow, standard, skill, and project references.
- Required Reading Order: minimum reading path before changing source.
- Documentation Layout: what each .agents subfolder contains and when to use it.
- Agent Framework: link to AGENTIC_FRAMEWORK.md if the repository keeps this reusable framework prompt.
- Reference Tables: one table per subfolder category, with each file and intended purpose.
- Prime Directive: core behavior standard for the agent in this repository.
- Default Work Pattern: short universal process for most tasks.
- Never Assume: repository-specific safety reminders.
- Manual Confirmation Summary: high-level gates, with details routed to directives.

Current-framework maintenance behavior:

- Before adding a new `.agents` file, search existing `.agents` files for the same scope.
- If a file already owns the scope, update it instead of creating another file.
- If a new file is justified, place it in the folder that matches its function and add it to the relevant AGENTS.md reference table.
- If a section in AGENTS.md becomes too detailed, move the detail to the correct `.agents` file and keep AGENTS.md as the router.
- Use cross-links to avoid duplicating the same rule in several places.
- When moving content, leave no stale links to the old path.
- Keep general standards independent from project-specific facts.
- Keep project instructions specific to the repository and cite or describe the source of durable facts where practical.

Per-file requirements:

- Every instruction Markdown file should begin with a title and a "Purpose And Use" section.
- The "Purpose And Use" section must explain:
  - the purpose of the file;
  - when an agent should read or apply it;
  - what type of content belongs in that file.
- Use uppercase Markdown filenames unless the user explicitly requests a specific lowercase path.
- Keep folder names lowercase and semantic.
- Do not leave empty placeholder files unless the repository intentionally wants placeholders.

Recommended subfile section pattern:

- Title: names the file's function.
- Purpose And Use: explains scope, when to read it, and what belongs there.
- Main Content Sections: specific rules, standards, workflow steps, or project facts.
- Verification or Handoff Section: where relevant, explain how the agent proves it followed the file.
- Version or Maintenance Notes: optional, only for standards or durable project docs that need ownership history.

Scope rules for subfile content:

- directives files should use mandatory language such as "must", "must not", "requires confirmation", and "stop".
- standards files should define expected quality, naming, formatting, review, test, and static-analysis criteria.
- skills files should map task types to skills, tools, or capability families and explain local adaptations.
- workflows files should describe ordered steps, decision points, inputs, outputs, and handoff expectations.
- project files should document verified repository facts, aliases, architecture, schema, integration contracts, vocabulary, and requirements.

Learning and skill-up rules:

- While building, the agent may identify repeatable patterns, project decisions, or developer preferences that would help future work.
- The agent should distinguish temporary task context from durable reusable learning.
- Store durable project facts in project files.
- Store capability-selection lessons, local skill adaptations, tool-routing habits, and "when doing X, use Y capability" guidance in skills files.
- Store repeatable procedural sequences in workflows files.
- Store quality expectations in standards files.
- Store non-negotiable safety or permission constraints in directives files.
- Before writing any learned pattern into `.agents`, ask the user for permission and name the exact destination file.
- Do not add unverified assumptions as learned patterns. Mark uncertain findings as questions or do not persist them.

No-duplication rules:

- Every durable instruction should have one owning file.
- Other files may link to the owning file or summarize it briefly.
- Do not copy full rule lists across folders.
- If two files contain the same rule, consolidate into the file with the correct scope and update the other file to link to it.
- If a rule belongs to more than one context, put it at the highest shared level that preserves meaning: directives for mandatory gates, standards for quality, workflows for process, skills for capability routing, project for repository facts.

Reorganization process:

1. Inspect current git status and preserve unrelated local changes.
2. Read AGENTS.md and list all files under .agents.
3. Read enough of each instruction file to classify it accurately.
4. Move files into directives, standards, skills, workflows, or project based on purpose.
5. Rename files only when it improves clarity or matches the repository convention.
6. Update AGENTS.md links, reading order, folder descriptions, and reference tables.
7. Update internal links inside moved files.
8. Search for stale paths, old folder names, old project names, and broken references.
9. Verify that every instruction Markdown file has a "Purpose And Use" section.
10. Check for duplicate instructions and consolidate them into a single owning file.
11. Stage only AGENTS.md and .agents/** if the user asked for staging. Leave source-code changes unstaged.

Classification guidance:

- If a file says what agents are allowed or forbidden to do, put it in directives.
- If a file defines quality expectations or implementation rules, put it in standards.
- If a file maps task types to reusable capabilities, skill packs, tools, or build/development skills, put it in skills.
- If a file gives a sequence of steps for doing work, put it in workflows.
- If a file documents the specific repository, orgs, architecture, schemas, integrations, glossary, or requirements, put it in project.

Quality bar:

- Be precise and factual.
- Do not invent project facts.
- Preserve any existing project-specific safety rules.
- Do not replace useful local conventions with generic advice.
- Do not touch application source files unless the user explicitly asks.
- Do not persist newly discovered patterns into `.agents` without user permission.
- Report the final folder structure, key moves, updated links, verification performed, and any remaining risks.
```
