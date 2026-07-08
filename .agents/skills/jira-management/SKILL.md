---
name: jira-management
description: "Read-only Jira Cloud API integration: connect to Jira, fetch ticket details, parse ADF content, and deliver structured ticket data. Activate when the user says 'install Jira skills', 'init Jira', 'fetch jira {KEY}', or mentions a ticket key matching a known project prefix."
metadata:
  version: "2.0"
  category: "Integration"
  api: "Jira Cloud REST API v3"
---

# jira-management: Jira Cloud Integration

| Field | Value |
| --- | --- |
| Skill ID | `jira-management` |
| Category | Integration |
| Version | 2.0 |
| API | Jira Cloud REST API v3 |

## Prime Directive

**This skill is strictly read-only on the Jira platform.** All Jira API calls must be HTTP GET. No POST, PUT, PATCH, or DELETE requests to Jira are permitted under any circumstances. If the user requests a Jira write action, explain that this skill is read-only and suggest they perform the action manually in Jira.

## Scope

This skill owns **only** the Jira API connection layer:
- Credential setup and auth testing
- Project prefix discovery
- Ticket retrieval and field extraction
- ADF (Atlassian Document Format) parsing
- Comment and issue link retrieval

This skill does **not** own:
- Local ticket file creation or management → owned by [PROJECT_TRACKING.MD](../../workflows/PROJECT_TRACKING.MD)
- Agile board updates → owned by [PROJECT_TRACKING.MD](../../workflows/PROJECT_TRACKING.MD)
- Ticket analysis, implementation, deployment, testing → owned by the framework's existing workflows, invoked through [PROJECT_TRACKING.MD](../../workflows/PROJECT_TRACKING.MD)
- Comment generation for Jira → owned by [PROJECT_TRACKING.MD](../../workflows/PROJECT_TRACKING.MD)

## When to Use

- User says "install Jira skills" or "init Jira"
- User says `fetch jira {KEY}` or `fetch {KEY}` (once prefixes are known)
- User asks "what is DTT-115 about?" (implicit fetch)
- Another workflow or skill needs raw ticket data from Jira (internal invocation)

## Ticket Key Recognition

After the install flow discovers project prefixes and stores them in `{USER_AGENTS}/{repo_name}/.local-config.json` under `jira.project_prefixes`, the agent must treat any token matching `{PREFIX}-{number}` (case-insensitive) as a Jira ticket reference. The `jira` keyword is optional:

| User says | Interpreted as |
| --- | --- |
| `fetch jira DTT-115` | Fetch ticket `DTT-115` from Jira |
| `fetch DTT-115` | Fetch ticket `DTT-115` from Jira |
| `fetch dtt-115` | Fetch ticket `DTT-115` from Jira |
| `what is DTT-115 about?` | Implicit fetch of `DTT-115` |

The prefix match is case-insensitive. Normalise the key to uppercase for API calls and file names.

Commands that are **not** Jira API operations (`analyse`, `build`, `deploy`, `test`, `comment`) are recognised by the same prefix matching but routed to [PROJECT_TRACKING.MD](../../workflows/PROJECT_TRACKING.MD), not this skill.

## Install / Setup Flow

When a user says **"install Jira skills"** or **"init Jira"**:

### Step 1 — Check Existing Credentials (Layered Lookup)

Resolve each of the three required values (`base_url`, `email`, `api_token`) through the [layered credential lookup](#credential-loading), in order:

1. **Secret manager / platform-provided credentials** — if the hosting platform supplies Jira credentials (CI secrets, connector credentials), use them and skip to Step 3. Do not copy them anywhere.
2. **Environment variables** — check `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` (and `JIRA_PROJECT_PREFIXES`). If all three are set, skip to Step 3.
3. **OS keychain / platform secret store** — if integrated and populated, use it and skip to Step 3.
4. **Local config file** (local developer machines only) — read `{USER_AGENTS}/{repo_name}/.local-config.json` and inspect the `jira` block, where `{USER_AGENTS}` is `~/.agents/` (Unix) or `%USERPROFILE%\.agents\` (Windows) and `{repo_name}` is the basename of `git rev-parse --show-toplevel`. If the file does not exist **and** `{USER_AGENTS}` is writable (i.e. this is a local developer machine), create it (and the parent directories) from the template. If all three fields are populated, skip to Step 3.

In a hosted/sandboxed environment where none of sources 1–3 provide credentials and `{USER_AGENTS}` is not writable, do **not** create a plaintext config file — proceed to Step 2 for in-session values and recommend the user configure env vars or platform secrets for future sessions.

### Step 2 — Prompt for Missing Values

Ask the user **only** for the values that are still unresolved:

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
> Click **Create API token**, give it a label (e.g. "Claude Code"), and copy the value.
> The token will **never** be displayed in chat.

**On local developer machines** (where `{USER_AGENTS}` is writable): write the credentials to `{USER_AGENTS}/{repo_name}/.local-config.json`, creating the directory if needed. **In hosted/sandboxed environments**: keep the values in-session only and recommend the user configure them as env vars (`JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`) or platform secrets — never write plaintext credentials to an ephemeral or shared filesystem. **Never echo the API token.**

### Step 3 — Test Connection

```
GET {base_url}/rest/api/3/myself
```

Report:
- Success: `Jira connection OK — authenticated as {displayName}`
- Failure: `Jira connection FAILED — HTTP {status}. Please check your credentials.`

Do not print the response body, auth headers, or token.

### Step 4 — Discover Project Prefixes

```
GET {base_url}/rest/api/3/project?expand=description&status=live
```

Extract each project's `key` and `name`. Present them:

> **Discovered Jira projects:**
> | Project Key | Project Name |
> | --- | --- |
> | DTT | Digital Transformation Team |
> | COP | Customer Operations Platform |
>
> Ticket references like `DTT-115` or `COP-42` will be recognised automatically.

Store prefixes (non-secret metadata) under `jira.project_prefixes` in `{USER_AGENTS}/{repo_name}/.local-config.json` if that file is in use and writable. If credentials came from env vars or a secret manager and no writable state location exists, keep the prefixes in-session (or suggest setting `JIRA_PROJECT_PREFIXES`).

### Step 5 — Read the Board

Attempt to fetch the active sprint or board:

```
GET {base_url}/rest/agile/1.0/board?type=scrum
```

If a board is found, display a summary. If not, skip silently.

### Step 6 — Confirm Setup & Show Command Glossary

> **Jira skills installed successfully.**
>
> This skill provides **read-only access** to your Jira platform. It will **never modify anything in Jira**. Comments for Jira are generated locally for you to copy-paste manually.
>
> **Available commands** (examples use your project prefixes):
>
> | Command | What it does | Handled by |
> | --- | --- | --- |
> | `fetch DTT-115` | Pull latest ticket details from Jira, create/update local ticket file | Jira skill → Project tracking |
> | `analyse DTT-115` | Requirements analysis, org diff, implementation plan | Project tracking → [SPECIFICATION](../../project/SPECIFICATION.md), [IMPLEMENTATION_PLAN](../../workflows/IMPLEMENTATION_PLAN.md) |
> | `build DTT-115` | Implement locally, build tests, dry deploy, produce manifest | Project tracking → [DEPLOYMENT](../../workflows/DEPLOYMENT.md), [TESTING](../../workflows/TESTING.md) |
> | `deploy DTT-115` | Show manifest, confirm, deploy to dev org | Project tracking → [DEPLOYMENT](../../workflows/DEPLOYMENT.md) |
> | `test DTT-115` | Dry deploy with test runs only | Project tracking → [DEPLOYMENT](../../workflows/DEPLOYMENT.md), [TESTING](../../workflows/TESTING.md) |
> | `comment DTT-115` | Generate review comment for manual paste into Jira | Project tracking |
>
> All Jira access is read-only. Local file creation and Salesforce org deploys follow the framework's existing confirmation gates.

## Credential Loading

Credentials are resolved using the framework's [layered credential lookup](../../AGENTS.md#layered-resolution), in this order:

1. **Hosted/CI secret manager** — platform-provided credentials (e.g. GitHub Actions secrets, Codex connector credentials). Preferred for remote and sandboxed agents.
2. **Environment variables** — `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`, and optionally `JIRA_PROJECT_PREFIXES` (comma-separated). Preferred for containers, CI pipelines, and automation scripts.
3. **OS keychain / platform secret store** — when available and integrated.
4. **User-level per-repo config file** — `{USER_AGENTS}/{repo_name}/.local-config.json`. This is the local developer default and stores plaintext credentials for convenience. Acceptable only on local developer machines; hosted agents should use sources 1–3.
5. **Interactive prompt** — last resort when no credentials are pre-configured.

Where:
- `{USER_AGENTS}` = `~/.agents/` (Unix) or `%USERPROFILE%\.agents\` (Windows)
- `{repo_name}` = basename of `git rev-parse --show-toplevel`

On local machines, a developer working on `client-a-platform` and `client-b-crm` has separate credentials for each project, both persisting outside the repo. See `_convention.user_level_structure` in `{USER_AGENTS}/common/templates/.local-config.template.json`.

### Config Shape

The Jira skill owns the `jira` key:

```json
{
  "jira": {
    "base_url": "https://example.atlassian.net",
    "email": "user@example.com",
    "api_token": "YOUR_TOKEN",
    "project_prefixes": ["DTT", "COP"]
  }
}
```

- `api_token` is a **sensitive field** — never echo it or write it to tracked files.
- `project_prefixes` is populated during install and used for ticket key recognition.

## Authentication

### Building the Auth Header

Jira Cloud uses HTTP Basic Auth with email + API token:

```
Authorization: Basic <base64(email:api_token)>
```

Load credentials using the [layered credential lookup](#credential-loading) — check env vars and secret managers before falling back to the per-repo config file.

On Windows PowerShell:
```powershell
$repoName = Split-Path (git rev-parse --show-toplevel) -Leaf
$configPath = Join-Path $env:USERPROFILE ".agents\$repoName\.local-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$pair = "$($config.jira.email):$($config.jira.api_token)"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{ "Authorization" = "Basic $base64"; "Accept" = "application/json" }
```

On Bash:
```bash
repo_name=$(basename "$(git rev-parse --show-toplevel)")
config=$(cat "$HOME/.agents/$repo_name/.local-config.json")
base_url=$(echo "$config" | jq -r '.jira.base_url')
email=$(echo "$config" | jq -r '.jira.email')
token=$(echo "$config" | jq -r '.jira.api_token')
auth=$(echo -n "$email:$token" | base64)
```

### Testing Auth

```
GET {base_url}/rest/api/3/myself
```

Report only `OK — authenticated as <displayName>` or `FAILED — HTTP {status}`. Never print auth headers, tokens, or the full response body.

## Retrieving Issues

### Fetch a Single Issue

```
GET {base_url}/rest/api/3/issue/{issueKey}?expand=renderedFields,names
```

### Standard Fields to Extract

| Field | JSON Path |
| --- | --- |
| Key | `key` |
| Summary | `fields.summary` |
| Status | `fields.status.name` |
| Assignee | `fields.assignee.displayName` |
| Reporter | `fields.reporter.displayName` |
| Priority | `fields.priority.name` |
| Labels | `fields.labels` |
| Components | `fields.components[].name` |
| Fix Versions | `fields.fixVersions[].name` |
| Created | `fields.created` |
| Updated | `fields.updated` |
| Issue Type | `fields.issuetype.name` |
| Description | `fields.description` (ADF format) |
| Comments | `fields.comment.comments[]` |
| Issue Links | `fields.issuelinks[]` |

### Custom Fields

Jira stores custom fields as `customfield_NNNNN`. To find relevant fields:

```
GET {base_url}/rest/api/3/field
```

Search for fields whose `name` matches (case-insensitive):
- Acceptance Criteria
- Solution
- Rules & Conditions / Rules and Conditions
- Scope
- Story Points
- Requirement
- Dependency

Cache the field-ID-to-name mapping for the session. Retrieve non-empty values from the issue.

### Retrieving Comments

Comments are at `fields.comment.comments[]`. Each has:
- `author.displayName`
- `created`
- `body` (ADF format — parse the same way as descriptions)

### Retrieving Issue Links

Issue links are at `fields.issuelinks[]`. Each has:
- `type.name` (e.g. "Blocks", "is blocked by", "relates to")
- `inwardIssue.key` / `outwardIssue.key`
- `inwardIssue.fields.summary` / `outwardIssue.fields.summary`

## Parsing ADF (Atlassian Document Format)

Jira Cloud descriptions and comments use ADF, a JSON tree. Parse recursively:

```
function parseADF(node):
  if node.type == "text":
    text = node.text
    if node.marks contains "link":
      text = "[" + text + "](" + mark.attrs.href + ")"
    if node.marks contains "strong":
      text = "**" + text + "**"
    if node.marks contains "em":
      text = "*" + text + "*"
    if node.marks contains "code":
      text = "`" + text + "`"
    return text

  if node.type == "hardBreak":       return "\n"
  if node.type == "paragraph":       return join(children) + "\n\n"
  if node.type == "heading":         return "#".repeat(level) + " " + join(children) + "\n\n"
  if node.type == "bulletList":      return join("- " + child for child in content)
  if node.type == "orderedList":     return join(i + ". " + child for child in content)
  if node.type == "listItem":        return join(children)
  if node.type == "codeBlock":       return "```" + lang + "\n" + join(children) + "\n```\n\n"
  if node.type == "table":           return parseTable(node)
  if node.type == "tableRow":        return "| " + join(cell + " | " for cell in content)
  if node.type == "tableCell/Header": return join(children).strip()
  if node.type == "mediaSingle/Group": return "[Attachment]\n"
  if node.type == "mention":         return "@" + node.attrs.text
  default: recurse into node.content
```

## Error Handling

- Auth failures: report HTTP status only, suggest re-checking credentials
- 404 on ticket: report that the key was not found
- Rate limiting (429): report and suggest waiting
- Network errors: report the error type, not raw stack traces
- **Never** include auth headers or tokens in error messages
- **Never** retry with modified HTTP methods — all Jira calls are GET only

## Security Rules

- **Never** print auth headers, Basic auth strings, or API tokens in chat or files
- **Never** store raw API tokens in tracked (committed) files
- **Never** make POST, PUT, PATCH, or DELETE requests to the Jira API
- **Never** include raw sensitive payloads in local ticket files
- Sanitize error responses before displaying (remove auth details)
- All credential files live under `{USER_AGENTS}/` (outside the repo) and are inherently untracked — never copy them into a repo or commit their contents
