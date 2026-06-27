# AI Agent Guardrails

## Purpose And Use

This file defines mandatory behavior for all AI-assisted work in this repository. Read and apply it before analysis, edits, Salesforce org access, Git writes, dependency work, or handoff notes. Put non-negotiable agent behavior, source-control safety, org safety, dependency safety, generated-file handling, and communication rules here.

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

## Communication Standard

When proposing or completing work, be exact:

- Name files and metadata members.
- Name the org alias if an org was touched.
- Name deploy or validation IDs when applicable.
- State what was not done because it requires manual confirmation.
