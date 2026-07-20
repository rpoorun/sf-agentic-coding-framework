# Jira Skill — First-Time Setup Guide

Step-by-step instructions for initialising the `jira-management` skill **from within a repo** for the first time. The agent follows this guide when the user says **"install Jira skills"** or **"init Jira"**; each step tells the agent what to do and what to say, and tells the user what they will be asked for.

| Field | Value |
| --- | --- |
| Skill | [`jira-management`](../SKILL.md) v3.0 |
| Trigger | "install Jira skills" / "init Jira" |
| Outcome | Project-tier install: credentials resolved, prefixes discovered, method scope chosen, helper file created |
| Prerequisite | Framework bootstrapped for this repo (`AGENTS.md` present; `{PROJECT_AGENTS}` resolvable — else run [PROJECT_BOOTSTRAP.md](../../../workflows/PROJECT_BOOTSTRAP.md) first) |

**What the user should have ready:**

1. Their Jira Cloud base URL — e.g. `https://yourcompany.atlassian.net`
2. The email address they log in to Jira with
3. A Jira API token — created at https://id.atlassian.com/manage-profile/security/api-tokens → **Create API token** → give it a label (e.g. "AI agent") → copy the value. The token is shown once; it can be revoked at any time from the same page.
4. A decision (or willingness to decide during step 4) on **what this repo's install is allowed to do in Jira** — read-only, or specific write capabilities.

---

## 1 — Resolve Existing Credentials (Layered Lookup)

Resolve each of the three required values (`base_url`, `email`, `api_token`) through the [layered credential lookup](../SKILL.md#credential-loading), in order:

1. **Secret manager / platform-provided credentials** — if the hosting platform supplies Jira credentials (CI secrets, connector credentials), use them and skip to step 3. Do not copy them anywhere.
2. **Environment variables** — check `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` (and optionally `JIRA_PROJECT_PREFIXES`, `JIRA_ALLOWED_METHODS`). If all three are set, skip to step 3.
3. **OS keychain / platform secret store** — if integrated and populated, use it and skip to step 3.
4. **Local config file** (local developer machines only) — read `{PROJECT_AGENTS}/project/.local-config.json` and inspect the `jira` block. If the file does not exist **and** `{USER_AGENTS}` is writable, create it (and parent directories) from the template at `{USER_AGENTS}/common/templates/.local-config.template.json`. If all three fields are populated, skip to step 3.

In a hosted/sandboxed environment where none of sources 1–3 provide credentials and `{USER_AGENTS}` is not writable, do **not** create a plaintext config file — collect values in-session (step 2) and recommend the user configure env vars or platform secrets for future sessions.

## 2 — Prompt for Missing Values

Ask the user **only** for the values still unresolved:

**Jira Base URL** (if blank):
> What is your Jira Cloud base URL?
> Example: `https://yourcompany.atlassian.net`
> This is the URL you see in your browser when using Jira (without `/browse` or other paths).

**Jira Email** (if blank):
> What email address do you use to log in to Jira?
> This is typically your work email, e.g. `jane.doe@company.com`.

**Jira API Token** (if blank):
> Please provide your Jira API token.
> Generate one at: https://id.atlassian.com/manage-profile/security/api-tokens
> Click **Create API token**, give it a label (e.g. "AI agent"), and copy the value.
> The token will **never** be displayed in chat.

**On local developer machines** (where `{USER_AGENTS}` is writable): write the credentials to `{PROJECT_AGENTS}/project/.local-config.json`, creating the directory if needed. **In hosted/sandboxed environments**: keep the values in-session only and recommend env vars (`JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`) or platform secrets — never write plaintext credentials to an ephemeral or shared filesystem. **Never echo the API token.**

## 3 — Test the Connection

```
GET {base_url}/rest/api/3/myself
```

Report:
- Success: `Jira connection OK — authenticated as {displayName}`
- Failure: `Jira connection FAILED — HTTP {status}. Please check your credentials.`

Do not print the response body, auth headers, or token. On 401/403, re-run step 2 for the token before anything else (expired/revoked tokens are the most common cause).

## 4 — Choose the Method Scope for This Repo

This is the step that turns the generic user-tier skill into a **scoped project-tier install**. Ask the user:

> **What is this repo's install allowed to do in Jira?**
>
> | Option | Scope (`allowed_methods`) | Effect |
> | --- | --- | --- |
> | **1. Read-only (default, recommended)** | `["GET"]` | Fetch tickets, search, read boards. Nothing in Jira can ever change. Comments are generated locally for manual paste. |
> | 2. Read + comment/transition | `["GET", "POST"]` | Also post comments, transition issues, create issues, add worklogs — each individual call still requires your confirmation. |
> | 3. Read + write | `["GET", "POST", "PUT"]` | Also edit issue fields, assign issues, update comments — each call confirmed. |
> | 4. Full | `["GET", "POST", "PUT", "DELETE"]` | Also delete comments/links/issues — destructive; every DELETE is confirmed with an irreversibility warning. |
>
> You can also restrict writes to specific operations (e.g. only `POST /rest/api/3/issue/{issueIdOrKey}/comment`) — say so and I'll record an `allowed_operations` whitelist. See the [full method catalog](api-reference.md) for everything available.

Rules for the agent:

- If the user does not answer or is unsure, install with **option 1 (read-only)**. Never default to a write scope.
- Record the choice in `{PROJECT_AGENTS}/project/.local-config.json` under `jira.allowed_methods` (and `jira.allowed_operations` when a whitelist was requested).
- If the user wants different scopes per environment (e.g. writes on a sandbox Jira project, read-only on production projects), create per-environment `jira` blocks under `{PROJECT_AGENTS}/project/environments/{env}/` — see [Config Shape](../SKILL.md#config-shape).
- Remind the user that regardless of scope, **every write call is individually confirmed** before execution ([write gates](../SKILL.md#write-operation-gates)).

## 5 — Discover Project Prefixes

```
GET {base_url}/rest/api/3/project/search
```

(Paginated; follow `nextPage` until exhausted. The older `GET /rest/api/3/project` also works but is deprecated in the spec.)

Extract each project's `key` and `name`. Present them:

> **Discovered Jira projects:**
> | Project Key | Project Name |
> | --- | --- |
> | DTT | Digital Transformation Team |
> | COP | Customer Operations Platform |
>
> Ticket references like `DTT-115` or `COP-42` will be recognised automatically.

If many projects are returned, ask the user which ones this repo works with and store only those. Store prefixes (non-secret metadata) under `jira.project_prefixes` in `{PROJECT_AGENTS}/project/.local-config.json` if that file is in use and writable. If credentials came from env vars or a secret manager and no writable state location exists, keep the prefixes in-session (or suggest setting `JIRA_PROJECT_PREFIXES`).

## 6 — Create the Project-Tier Helper

Copy [templates/JIRA_MANAGEMENT_HELPER.template.md](../templates/JIRA_MANAGEMENT_HELPER.template.md) to:

```
{PROJECT_AGENTS}/skills/jira-management/JIRA_MANAGEMENT_HELPER.md
```

and fill in the placeholders (project name, base URL — never the token —, prefixes, chosen scope, environment notes). This helper is what future sessions read to know **this project's** Jira scope and conventions; the user-tier skill stays generic. If no writable `{PROJECT_AGENTS}` tier exists (sandboxed agent), skip the file and state the scope in-session.

Then attempt to read the board (optional, silent skip on failure):

```
GET {base_url}/rest/agile/1.0/board?type=scrum
```

If a board is found, display a one-line summary.

## 7 — Confirm Setup & Show Command Glossary

> **Jira skill installed for this project.**
>
> Scope: **{chosen scope, e.g. read-only (GET)}** — recorded in this project's configuration. {If read-only: "Nothing in Jira will ever be modified; comments are generated locally for you to paste manually." If write-scoped: "Every write to Jira will be shown to you and individually confirmed before it is sent."}
>
> **Available commands** (examples use your project prefixes):
>
> | Command | What it does | Handled by |
> | --- | --- | --- |
> | `fetch DTT-115` | Pull latest ticket details from Jira, create/update local ticket file | Jira skill → Project tracking |
> | `analyse DTT-115` | Requirements analysis, org diff, implementation plan | Project tracking |
> | `build DTT-115` | Implement locally, build tests, dry deploy, produce manifest | Project tracking |
> | `deploy DTT-115` | Show manifest, confirm, deploy to dev org | Project tracking |
> | `test DTT-115` | Dry deploy with test runs only | Project tracking |
> | `comment DTT-115` | {Read-only: "Generate review comment for manual paste into Jira." Write-scoped: "Draft review comment, confirm, then post to Jira."} | Project tracking → Jira skill |
>
> Local file creation and Salesforce org deploys follow the framework's existing confirmation gates.

### 7b — Re-Scoping an Existing Install

When the user later asks to widen or narrow the scope ("allow the agent to comment on Jira", "make this repo read-only again"):

1. Show the current `jira.allowed_methods` (and `allowed_operations` if set) and the requested change.
2. Confirm the new scope explicitly in chat — widening a scope is a configuration change and gets its own confirmation.
3. Update `{PROJECT_AGENTS}/project/.local-config.json` and the helper file's Scope section.
4. Never widen scope implicitly as a side effect of a task ("post this comment" in a read-only install → offer re-scoping first, don't just do it).

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| 401 on `/myself` | Wrong email/token pairing, revoked token | Regenerate the token; re-run step 2 |
| 403 on `/myself` | Valid auth but no site access | Check the base URL points to a site the user belongs to |
| 404 on every call | Base URL wrong (e.g. includes `/jira` or `/browse`) | Base URL must be just `https://{site}.atlassian.net` |
| Empty project list | User lacks *Browse Projects* permission | Ask a Jira admin to grant project access |
| 429 responses | Rate limiting | Honour `Retry-After`; slow down; see [rate limiting docs](schema-structure.md#official-links) |
| Writes rejected 400 | Payload/field errors | Report the `errors` field names; check required fields via `GET /rest/api/3/issue/createmeta/...` |
