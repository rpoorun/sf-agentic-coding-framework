# Environment Reference

## Purpose And Use

This file documents durable local environment and Salesforce org alias facts for this project. Read it before running org reads, validation, retrieve, deploy, or environment-specific analysis. Put verified aliases, environment purpose, local setup notes, secrets-handling constraints, and bootstrap rules here; never put tokens, credentials, personal email addresses, or org URLs containing client-identifying details here.

**Live location — user-level, per developer**: the working copy of this file lives at `{REPO_STATE}/project/ENVIRONMENT.md` (on local machines: `{USER_AGENTS}/{repo_name}/project/ENVIRONMENT.md`) — outside the repo, so it persists across branches and stays personal. Environment details are **per developer**: each developer's org access, aliases, and auth status differ, so each developer fills in their own copy during bootstrap rather than inheriting another developer's. This file in the repo (`.agents/project/ENVIRONMENT.md`) is the **boilerplate template** that bootstrap copies to the user level.

This is a boilerplate template. Replace every `{client}` and `{project}` placeholder in the user-level copy with the actual values for this installation, then fill in the "Connected Orgs" table with verified facts. Do not commit real client names, org URLs, or usernames back to the master framework repository — see [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md#sanitizing-instructions-before-any-master-framework-contribution).

This project uses named Salesforce CLI aliases for day-to-day org work. Do not store access tokens, refresh tokens, credentials, private keys, or session details in this repository.

## Author Identity

Used as the `@author`/`@last modified by` value in every generated Apex and LWC comment header — see [SALESFORCE_APEX_STANDARDS.md](../standards/SALESFORCE_APEX_STANDARDS.md#author-identity-required).

**Primary store (user-level, preferred):** `{USER_AGENTS}/identity.json` — `author_name` and `author_email`. This file lives outside the repo at `~/.agents/` (Unix) or `%USERPROFILE%\.agents\` (Windows) and is shared across all repos on this machine. The agent must check here first.

**Secondary store (per-repo override):** the table below in the user-level copy of this file (`{REPO_STATE}/project/ENVIRONMENT.md`). Use this when a specific project needs a different author identity than the machine-wide default — e.g. a client-specific email. Leave blank to use `identity.json` for this repo.

Resolution order: if `{USER_AGENTS}/identity.json` has a non-empty `author_name`, use it. Otherwise fall back to the user-level copy of this file. If both are blank, ask the user for the identity before generating the first class/method comment header in the session, then ask separately whether to persist it to `identity.json` (user-level, shared across repos) or the user-level copy of this file (this repo only).

| Field | Value |
| --- | --- |
| Author name | Not yet configured |
| Author email | Not yet configured |

Never write an AI/model/tool name (e.g. `OpenAI`, `Anthropic`, `Claude`, `ChatGPT`, `Copilot`) as the author. Per [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md#sanitizing-instructions-before-any-master-framework-contribution), never carry a real personal name/email into anything proposed back to the master framework repository.

## Required Tooling

See [PROJECT_BOOTSTRAP.md](../workflows/PROJECT_BOOTSTRAP.md#step-1--required-tooling-check) for the full check. At minimum this project requires: Salesforce CLI (`sf`), Git, and the `sfdx-git-delta` plugin for scoped delta deploys (see [DEPLOYMENT.md](../workflows/DEPLOYMENT.md)). Record locally-confirmed versions here once verified.

## Org Alias Naming Convention

Name every Salesforce CLI org alias as:

```
{client}-{project}-{env}
```

- `{client}` — short, lowercase client/customer identifier.
- `{project}` — short, lowercase project or program identifier.
- `{env}` — environment abbreviation: `dev`, `dev2`, `int`, `uat`, `uat2`, `qa`, `poc`, `preprod`, `prod`. Append a number when multiple instances of the same environment type exist (e.g. `dev2`, `uat2`).

Example aliases following this convention (fully generic placeholders for the master framework; replace both segments with the real client and project identifiers in a local install — never carry a real client or project name into the master repository):

```
{client name}-{project name}-dev
{client name}-{project name}-uat
```

Concrete illustration using placeholder values that are not tied to any real client or project:

```
rpoorun-framework-dev
rpoorun-framework-uat
```

## Connected Orgs

| Environment | Purpose | Primary alias | Alternative names | Org URL | Current local auth note |
| --- | --- | --- | --- | --- | --- |
| Development | Main development org for this project. | `{client}-{project}-dev` | DEV, development env | Not yet documented | Verify and document the authenticated alias after connecting. |
| QA | Pre-integration testing environment. | `{client}-{project}-qa` | QA, pre-INT | Not yet documented | Alias is reserved by project convention; verify authorization and URL before use. |
| POC | Trial environment for experiments and proof-of-concept checks. | `{client}-{project}-poc` | POC, trials env | Not yet documented | Verify and document the authenticated alias after connecting. |

## Pipeline Environments Not Yet Connected Locally

These environments are commonly part of a delivery pipeline; record local Salesforce CLI alias status here once known:

| Environment | Meaning | Local alias status |
| --- | --- | --- |
| INT | Integration environment. | Not connected yet. |
| UAT | User acceptance testing environment. | Not connected yet. |
| PRE PROD | Staging environment before production release. | Not connected yet. |
| PROD | Production live environment. | Not connected yet. |

## Org Usage Rules

- Always name the target org alias in analysis notes, validation summaries, deploy summaries, and ticket/client handoffs.
- Use the `dev` alias for development inspection, retrieval, validation, and implementation work unless the user explicitly names another environment.
- Use the `poc` alias for trials and proof-of-concept checks only when the user asks for POC work.
- Treat the `qa` alias as the QA/pre-INT target by convention, but verify authorization and the org URL before running org commands against it.
- Do not assume INT, UAT, PRE PROD, or PROD access exists. Ask for the alias and approval before any command against those environments.
- Never record personal email addresses, usernames, access tokens, or full org URLs containing a client's literal subdomain in this file when preparing content for the master framework repository — replace them with the `{client}-{project}-{env}` placeholder pattern.
