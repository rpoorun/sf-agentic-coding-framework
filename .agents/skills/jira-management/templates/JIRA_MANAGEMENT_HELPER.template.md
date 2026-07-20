# Jira Management — Project Helper: {PROJECT_NAME}

<!--
Template for the project-tier helper file. During "install Jira skills" (setup guide step 6),
copy this file to:

    {PROJECT_AGENTS}/skills/jira-management/JIRA_MANAGEMENT_HELPER.md

and replace every {PLACEHOLDER}. This file bridges the generic user-tier skill
({USER_AGENTS}/skills/jira-management/SKILL.md) to THIS project's environments, credentials,
and scope. It contains no secrets — credentials stay in {PROJECT_AGENTS}/project/.local-config.json
or higher-priority sources. Delete this comment block in the copied file.
-->

| Field | Value |
| --- | --- |
| Project | `{PROJECT_NAME}` |
| User-tier skill | `{USER_AGENTS}/skills/jira-management/SKILL.md` (v3.0) |
| Jira site | `{BASE_URL, e.g. https://yourcompany.atlassian.net}` |
| Credential source | {e.g. `{PROJECT_AGENTS}/project/.local-config.json` `jira` block / env vars / CI secrets} |
| Installed | {YYYY-MM-DD} |
| Last re-scoped | {YYYY-MM-DD or "never"} |

## Scope

**Allowed methods for this project:** `{e.g. ["GET"]}`

{One sentence chosen at install, e.g. "This install is read-only: the agent may call any GET operation but must never modify anything in Jira for this project." — or for a write scope: "This install may additionally POST comments and transitions; every write call is individually confirmed in chat before it is sent."}

- Authoritative scope config: `jira.allowed_methods` (and `jira.allowed_operations`, if present) in `{PROJECT_AGENTS}/project/.local-config.json`. If this file and that config ever disagree, the config wins — then fix this file.
- Operation whitelist (`allowed_operations`): {list them, or "none — all operations of the allowed methods are in scope"}
- Out-of-scope requests → follow the re-scoping flow in the user-tier [setup guide](../../../skills/jira-management/references/setup-guide.md#7b--re-scoping-an-existing-install); never widen scope implicitly.

## Environments

{Delete this section if the project uses a single scope. Otherwise list per-environment overrides stored under `{PROJECT_AGENTS}/project/environments/{env}/`:}

| Environment | Jira project(s) | Allowed methods | Notes |
| --- | --- | --- | --- |
| development | {KEY} | {["GET","POST"]} | {e.g. sandbox Jira project — comments/transitions allowed} |
| production | {KEY} | {["GET"]} | {read-only} |

## Project Prefixes

Recognised ticket prefixes (`jira.project_prefixes`): `{e.g. ["DTT", "COP"]}`

| Project Key | Project Name |
| --- | --- |
| {DTT} | {Digital Transformation Team} |

## Project Conventions

{Project-specific Jira usage notes the generic skill cannot know — delete lines that do not apply:}

- Custom fields that matter to this project: {e.g. `customfield_10021` = Acceptance Criteria, `customfield_10016` = Story Points}
- Board: {board name/ID from `GET /rest/agile/1.0/board`, or "none"}
- Workflow statuses used by `comment`/`transition` commands: {e.g. To Do → In Progress → In Review → Done}
- JQL filters commonly used: {e.g. `project = DTT AND sprint in openSprints()`}
- {Anything else: components, fix-version conventions, who to assign reviews to, …}
