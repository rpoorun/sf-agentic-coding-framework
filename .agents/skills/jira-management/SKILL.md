---
name: jira-management
description: "Jira Cloud REST API v3 integration skill: connect to Jira, invoke any of the API's 616 documented operations (GET/POST/PUT/DELETE), parse ADF content, and deliver structured ticket data. Full capability is documented at the user tier; each project-tier install scopes the callable methods (default: GET only). Activate when the user says 'install Jira skills', 'init Jira', 'fetch jira {KEY}', or mentions a ticket key matching a known project prefix."
metadata:
  version: "3.0"
  category: "Integration"
  api: "Jira Cloud REST API v3"
  api_spec: "swagger-v3.v3.json (OpenAPI 3.0.1)"
---

# jira-management: Jira Cloud Integration

| Field | Value |
| --- | --- |
| Skill ID | `jira-management` |
| Category | Integration |
| Version | 3.0 |
| API | Jira Cloud REST API v3 (`/rest/api/3/`) + Jira Agile v1 (`/rest/agile/1.0/`) |
| API surface | 616 operations — 275 GET, 134 POST, 118 PUT, 89 DELETE ([full catalog](references/api-reference.md)) |
| Setup guide | [references/setup-guide.md](references/setup-guide.md) |
| Schema & links | [references/schema-structure.md](references/schema-structure.md) |
| Payload samples | [samples/README.md](samples/README.md) |
| Config schema | [schemas/jira-config.schema.json](schemas/jira-config.schema.json) |
| Project helper template | [templates/JIRA_MANAGEMENT_HELPER.template.md](templates/JIRA_MANAGEMENT_HELPER.template.md) |
| Update script | [scripts/generate-api-reference.py](scripts/generate-api-reference.py) |

## Skill Contents (Self-Contained Layout)

Everything the skill needs travels in this folder — no external dependency beyond the Jira API itself:

```
jira-management/
├── SKILL.md                                  # this file — capability model, auth, operations, guardrails
├── references/
│   ├── api-reference.md                      # generated full catalog: all 616 operations by resource group
│   ├── setup-guide.md                        # step-by-step first-time install from within a repo
│   └── schema-structure.md                   # official links, OpenAPI spec structure, update procedure
├── samples/                                  # ready-to-adapt request/response JSON (see samples/README.md)
│   ├── adf-document.json                     # ADF body structure
│   ├── issue-response-extract.json           # getIssue response with standard extraction paths
│   ├── jql-search.json                       # JQL search body
│   ├── create-issue.json / edit-issue.json / add-comment.json / transition-issue.json
│   └── README.md
├── schemas/
│   └── jira-config.schema.json               # JSON Schema for the project-tier `jira` config block
├── scripts/
│   └── generate-api-reference.py             # regenerates references/api-reference.md from the official spec
└── templates/
    └── JIRA_MANAGEMENT_HELPER.template.md    # project-tier helper created at install
```

## Capability / Scoping Model

This skill follows the framework's two-level skill doctrine (see [Skills across tiers](../../../AGENTS.md#layered-resolution)):

- **User tier (this folder)** — the skill is generic, parameterized, and self-contained. It documents the **entire** Jira Cloud platform REST API v3 capability: every GET, POST, PUT, and DELETE operation ([references/api-reference.md](references/api-reference.md)), authentication, schemas, guardrails, and setup instructions. Nothing here is bound to any project.
- **Project tier (per install)** — a working invocation exists only after the skill is **installed for a repo/project**. The install creates `{PROJECT_AGENTS}/skills/jira-management/JIRA_MANAGEMENT_HELPER.md` (from the [template](templates/JIRA_MANAGEMENT_HELPER.template.md)) and a `jira` block in `{PROJECT_AGENTS}/project/.local-config.json`. The helper and config define the **scope** of that install: which HTTP methods (and optionally which specific operations) the agent may call for that project.

**Scoping rules:**

1. The effective capability of an install is the **intersection** of this skill's catalog and the project scope. An operation absent from `jira.allowed_methods` / `jira.allowed_operations` is not callable in that project, even though the skill documents it.
2. **Default scope on install is `["GET"]` (read-only).** Write methods (POST, PUT, DELETE) are enabled only when the user explicitly opts in during setup (or later re-scoping), per repo requirement.
3. Every **write call** (POST/PUT/DELETE), even when in scope, passes a [manual confirmation gate](#write-operation-gates) before execution — show the method, URL, and payload summary, and wait for approval.
4. Scope may be **segregated per environment** (`{PROJECT_AGENTS}/project/environments/{dev|uat|staging|production}/`) — e.g. writes allowed against a sandbox Jira project but read-only against production projects.
5. If the user requests an out-of-scope operation, do not call it. Explain the current scope and offer the re-scoping flow ([setup guide § 7b](references/setup-guide.md#7b--re-scoping-an-existing-install)).

## Scope of Ownership

This skill owns **only** the Jira API connection layer:
- Credential setup and auth testing
- Project prefix discovery
- Issue retrieval, search (JQL), and field extraction
- ADF (Atlassian Document Format) parsing
- Comment and issue link retrieval
- Scoped write operations (create/update/transition/comment/delete) where the project-tier scope permits them

This skill does **not** own:
- Local ticket file creation or management → owned by [PROJECT_TRACKING.md](../../workflows/PROJECT_TRACKING.md)
- Agile board updates → owned by [PROJECT_TRACKING.md](../../workflows/PROJECT_TRACKING.md)
- Ticket analysis, implementation, deployment, testing → owned by the framework's existing workflows, invoked through [PROJECT_TRACKING.md](../../workflows/PROJECT_TRACKING.md)
- Deciding *when* a write to Jira is appropriate → owned by the invoking workflow; this skill only executes in-scope, gate-approved calls

## When to Use

- User says "install Jira skills" or "init Jira" → run the [setup guide](references/setup-guide.md)
- User says `fetch jira {KEY}` or `fetch {KEY}` (once prefixes are known)
- User asks "what is DTT-115 about?" (implicit fetch)
- User asks for an in-scope Jira write (e.g. "comment on DTT-115 in Jira", "transition DTT-115 to Done") — only in installs scoped for those methods
- Another workflow or skill needs raw ticket data from Jira (internal invocation)

## Ticket Key Recognition

After the install flow discovers project prefixes and stores them in `{PROJECT_AGENTS}/project/.local-config.json` under `jira.project_prefixes`, the agent must treat any token matching `{PREFIX}-{number}` (case-insensitive) as a Jira ticket reference. The `jira` keyword is optional:

| User says | Interpreted as |
| --- | --- |
| `fetch jira DTT-115` | Fetch ticket `DTT-115` from Jira |
| `fetch DTT-115` | Fetch ticket `DTT-115` from Jira |
| `fetch dtt-115` | Fetch ticket `DTT-115` from Jira |
| `what is DTT-115 about?` | Implicit fetch of `DTT-115` |

The prefix match is case-insensitive. Normalise the key to uppercase for API calls and file names.

Commands that are **not** Jira API operations (`analyse`, `build`, `deploy`, `test`, `comment`) are recognised by the same prefix matching but routed to [PROJECT_TRACKING.md](../../workflows/PROJECT_TRACKING.md), not this skill.

## Install / Setup Flow

The full step-by-step first-time initialisation (run from within a repo) is in **[references/setup-guide.md](references/setup-guide.md)**. Summary:

1. Resolve credentials via the [layered credential lookup](#credential-loading); prompt only for missing values.
2. Test the connection (`GET /rest/api/3/myself`).
3. Discover project prefixes (`GET /rest/api/3/project/search`).
4. **Scope the install** — ask the user which methods this repo needs; default `["GET"]`.
5. Create the project-tier helper `{PROJECT_AGENTS}/skills/jira-management/JIRA_MANAGEMENT_HELPER.md` from the [template](templates/JIRA_MANAGEMENT_HELPER.template.md).
6. Optionally read the board (`GET /rest/agile/1.0/board?type=scrum`).
7. Confirm setup and show the command glossary.

## Credential Loading

Credentials are resolved using the framework's [layered credential lookup](../../../AGENTS.md#layered-resolution), in this order:

1. **Hosted/CI secret manager** — platform-provided credentials (e.g. GitHub Actions secrets, Codex connector credentials). Preferred for remote and sandboxed agents.
2. **Environment variables** — `JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`, and optionally `JIRA_PROJECT_PREFIXES` (comma-separated) and `JIRA_ALLOWED_METHODS` (comma-separated). Preferred for containers, CI pipelines, and automation scripts.
3. **OS keychain / platform secret store** — when available and integrated.
4. **Project-level config file** — `{PROJECT_AGENTS}/project/.local-config.json`. This is the local developer default and stores plaintext credentials for convenience. Acceptable only on local developer machines; hosted agents should use sources 1–3.
5. **Interactive prompt** — last resort when no credentials are pre-configured.

Where:
- `{USER_AGENTS}` = `~/.agents/` (Unix) or `%USERPROFILE%\.agents\` (Windows)
- `{PROJECT_NAME}` = repository name from the git remote URL (e.g. `rehlko-dtt` from `github.com/rpoorun/rehlko-dtt.git`); `{PROJECT_AGENTS}` = `{USER_AGENTS}/{PROJECT_NAME}/`

On local machines, a developer working on `client-a-platform` and `client-b-crm` has separate credentials and separate scopes for each project, both persisting outside the repo. See `_convention.user_level_structure` in `{USER_AGENTS}/common/templates/.local-config.template.json`.

### Config Shape

The Jira skill owns the `jira` key (formal JSON Schema: [schemas/jira-config.schema.json](schemas/jira-config.schema.json)):

```json
{
  "jira": {
    "base_url": "https://example.atlassian.net",
    "email": "user@example.com",
    "api_token": "YOUR_TOKEN",
    "project_prefixes": ["DTT", "COP"],
    "allowed_methods": ["GET"],
    "allowed_operations": []
  }
}
```

- `api_token` is a **sensitive field** — never echo it or write it to tracked files.
- `project_prefixes` is populated during install and used for ticket key recognition.
- `allowed_methods` is the project-tier method scope — any subset of `["GET", "POST", "PUT", "DELETE"]`. Default `["GET"]`. An empty or missing value means `["GET"]`, never "everything".
- `allowed_operations` (optional, finer grain) — a whitelist of specific operations, each as `"METHOD /path"` (e.g. `"POST /rest/api/3/issue/{issueIdOrKey}/comment"`) or an `operationId` from the [catalog](references/api-reference.md). When non-empty, a write call must match **both** `allowed_methods` and `allowed_operations`. GET is never restricted by this list.
- Per-environment overrides may live in `{PROJECT_AGENTS}/project/environments/{env}/` using the same shape; the environment's `jira` block wins over the project default when an environment is targeted.

## Authentication

### Building the Auth Header

Jira Cloud uses HTTP Basic Auth with email + API token (generate tokens at https://id.atlassian.com/manage-profile/security/api-tokens):

```
Authorization: Basic <base64(email:api_token)>
```

Load credentials using the [layered credential lookup](#credential-loading) — check env vars and secret managers before falling back to the project-level config file.

On Windows PowerShell:
```powershell
$repoName = Split-Path (git rev-parse --show-toplevel) -Leaf
$configPath = Join-Path $env:USERPROFILE ".agents\$repoName\project\.local-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$pair = "$($config.jira.email):$($config.jira.api_token)"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{ "Authorization" = "Basic $base64"; "Accept" = "application/json" }
```

On Bash:
```bash
repo_name=$(basename -s .git "$(git remote get-url origin)")
config=$(cat "$HOME/.agents/$repo_name/project/.local-config.json")
base_url=$(echo "$config" | jq -r '.jira.base_url')
email=$(echo "$config" | jq -r '.jira.email')
token=$(echo "$config" | jq -r '.jira.api_token')
auth=$(echo -n "$email:$token" | base64)
```

Other auth schemes exist (OAuth 2.0 3LO with granular scopes, Forge/Connect app auth) — see [schema-structure.md](references/schema-structure.md#authentication-schemes). This skill's default is basic auth with an API token; note that Connect (`/rest/atlassian-connect/`) and Forge (`/rest/forge/`) endpoints in the catalog require app auth and are not callable with basic auth.

### Testing Auth

```
GET {base_url}/rest/api/3/myself
```

Report only `OK — authenticated as <displayName>` or `FAILED — HTTP {status}`. Never print auth headers, tokens, or the full response body.

## Core Operations (Read)

These GET operations cover the framework's day-to-day needs and are in scope for every install. The complete list of all 275 GET operations is in the [catalog](references/api-reference.md).

| Purpose | Call |
| --- | --- |
| Auth test / current user | `GET /rest/api/3/myself` |
| Get issue (with rendered fields) | `GET /rest/api/3/issue/{issueIdOrKey}?expand=renderedFields,names` |
| Search issues (JQL, paginated) | `GET /rest/api/3/search/jql?jql={jql}&fields={fields}` |
| List projects (paginated) | `GET /rest/api/3/project/search` |
| List all fields (find custom fields) | `GET /rest/api/3/field` |
| Issue comments (paginated) | `GET /rest/api/3/issue/{issueIdOrKey}/comment` |
| Issue transitions available | `GET /rest/api/3/issue/{issueIdOrKey}/transitions` |
| Issue watchers | `GET /rest/api/3/issue/{issueIdOrKey}/watchers` |
| Server info / API health | `GET /rest/api/3/serverInfo` |
| Boards (Agile API) | `GET /rest/agile/1.0/board?type=scrum` |
| Active sprint issues | `GET /rest/agile/1.0/board/{boardId}/sprint?state=active` |

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

Search for fields whose `name` matches (case-insensitive): Acceptance Criteria, Solution, Rules & Conditions / Rules and Conditions, Scope, Story Points, Requirement, Dependency.

Cache the field-ID-to-name mapping for the session. Retrieve non-empty values from the issue.

### Retrieving Comments

Comments are at `fields.comment.comments[]` (or paginated via `GET /rest/api/3/issue/{issueIdOrKey}/comment`). Each has:
- `author.displayName`
- `created`
- `body` (ADF format — parse the same way as descriptions)

### Retrieving Issue Links

Issue links are at `fields.issuelinks[]`. Each has:
- `type.name` (e.g. "Blocks", "is blocked by", "relates to")
- `inwardIssue.key` / `outwardIssue.key`
- `inwardIssue.fields.summary` / `outwardIssue.fields.summary`

## Common Operations (Write — scope-gated)

Callable **only** when the project-tier scope includes the method (and the operation, if `allowed_operations` is set), and **always** behind a [write gate](#write-operation-gates). The complete write catalog (134 POST, 118 PUT, 89 DELETE) is in the [catalog](references/api-reference.md).

| Purpose | Call | Scope needed |
| --- | --- | --- |
| Create issue | `POST /rest/api/3/issue` | POST |
| Add comment | `POST /rest/api/3/issue/{issueIdOrKey}/comment` | POST |
| Transition issue (status change) | `POST /rest/api/3/issue/{issueIdOrKey}/transitions` | POST |
| Edit issue fields | `PUT /rest/api/3/issue/{issueIdOrKey}` | PUT |
| Assign issue | `PUT /rest/api/3/issue/{issueIdOrKey}/assignee` | PUT |
| Update comment | `PUT /rest/api/3/issue/{issueIdOrKey}/comment/{id}` | PUT |
| Link two issues | `POST /rest/api/3/issueLink` | POST |
| Add worklog | `POST /rest/api/3/issue/{issueIdOrKey}/worklog` | POST |
| Add attachment | `POST /rest/api/3/issue/{issueIdOrKey}/attachments` | POST |
| Delete comment | `DELETE /rest/api/3/issue/{issueIdOrKey}/comment/{id}` | DELETE |
| Delete issue | `DELETE /rest/api/3/issue/{issueIdOrKey}` | DELETE |

Request bodies for descriptions and comments use ADF (`{"body": {"type": "doc", "version": 1, "content": [...]}}`) — see [ADF](#parsing-adf-atlassian-document-format) and the [schema reference](references/schema-structure.md).

### Write-Operation Gates

Per [MANUAL_CONFIRMATION_GATES.md](../../directives/MANUAL_CONFIRMATION_GATES.md), before **any** POST/PUT/DELETE to Jira:

1. Verify the method (and operation, when `allowed_operations` is non-empty) is within the install's scope. Out of scope → refuse and offer [re-scoping](references/setup-guide.md#7b--re-scoping-an-existing-install).
2. Show the user: HTTP method, full URL (no auth), and a human-readable summary of the payload (e.g. the comment text, the fields being changed, the target status).
3. Wait for explicit confirmation in chat. One confirmation covers one call — never batch-approve.
4. `DELETE` calls additionally state what is destroyed and that it may be irreversible.
5. Report the outcome (HTTP status, resulting key/ID) without the raw response body.

In a **read-only install** (default scope `["GET"]`), the `comment DTT-115` command keeps its historical behaviour: generate the comment text locally for the user to paste into Jira manually.

## Parsing ADF (Atlassian Document Format)

Jira Cloud descriptions and comments use ADF, a JSON tree (spec: https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/). Parse recursively:

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

When **writing** ADF (comments, descriptions in write-scoped installs), build the same structure in reverse: wrap plain text in `{"type": "doc", "version": 1, "content": [{"type": "paragraph", "content": [{"type": "text", "text": "..."}]}]}`.

## Full API Reference

The complete, generated catalog of all **616 operations** grouped into 99 resource groups is in **[references/api-reference.md](references/api-reference.md)**:

| Method | Count | Typical use |
| --- | ---: | --- |
| GET | 275 | Read issues, projects, fields, users, boards, configuration |
| POST | 134 | Create issues/comments/links/worklogs, transitions, bulk operations, JQL search |
| PUT | 118 | Update issues, fields, configuration, properties |
| DELETE | 89 | Remove issues, comments, links, properties, configuration |

How the OpenAPI spec is organised (paths, 970 component schemas, OAuth2 scopes, pagination, `x-experimental` markers) and all official documentation links are in **[references/schema-structure.md](references/schema-structure.md)**.

## Error Handling

- Auth failures (401/403): report HTTP status only, suggest re-checking credentials
- 404 on ticket: report that the key was not found
- 400 on writes: report the `errors`/`errorMessages` field names from the response (they are safe), not the full body
- Rate limiting (429): honour `Retry-After` when present; report and suggest waiting (see [rate limiting](references/schema-structure.md#official-links))
- Network errors: report the error type, not raw stack traces
- **Never** include auth headers or tokens in error messages
- **Never** retry a failed call with a different HTTP method or a broadened scope — scope is fixed by the project tier, not by error recovery

## Security Rules

- **Never** print auth headers, Basic auth strings, or API tokens in chat or files
- **Never** store raw API tokens in tracked (committed) files
- **Never** make a POST, PUT, PATCH, or DELETE request outside the install's project-tier scope — and never any write without its [confirmation gate](#write-operation-gates)
- **Never** widen `allowed_methods` yourself — only the user can re-scope, via the [re-scoping flow](references/setup-guide.md#7b--re-scoping-an-existing-install)
- **Never** include raw sensitive payloads in local ticket files
- Sanitize error responses before displaying (remove auth details)
- All credential files live under `{USER_AGENTS}/` (outside the repo) and are inherently untracked — never copy them into a repo or commit their contents
