---
name: jira-management
description: "Read-only Jira Cloud integration: fetch tickets, track locally as Markdown, analyse requirements, plan implementations, build and deploy Salesforce metadata, and generate review comments. Activate when the user mentions Jira tickets, ticket keys (e.g. DTT-115, COP-42), sprint work, or says 'install Jira skills'."
metadata:
  version: "1.1"
  category: "Project Management"
  api: "Jira Cloud REST API v3"
---

# jira-management: Jira Ticket Retrieval & Local Tracking

| Field | Value |
| --- | --- |
| Skill ID | `jira-management` |
| Category | Project Management |
| Version | 1.1 |
| API | Jira Cloud REST API v3 |

## Prime Directive

**This skill is strictly read-only on the Jira platform.** The agent must never create, update, transition, comment on, link, or delete any resource in Jira. All Jira API calls must be HTTP GET. No POST, PUT, PATCH, or DELETE requests to Jira are permitted under any circumstances, regardless of what the user asks. If the user requests a Jira write action, explain that this skill is read-only and suggest they perform the action manually in Jira.

The skill writes only to local files (`.agents/project/tickets/`, `.agents/project/board/`) and to the local dev org via standard Salesforce deploy commands governed by the framework's existing deployment workflow.

## When to Use

- User says "install Jira skills" or "init Jira"
- User mentions a ticket key matching a known project prefix (e.g. `DTT-115`, `COP-42`, `CAPCEESF-100`)
- User says `fetch jira`, `analyse jira`, `build jira`, `deploy jira`, `test jira`, or `comment jira` followed by a ticket key
- User says a **command + bare ticket key** without the `jira` keyword (e.g. `fetch DTT-115`, `analyse COP-42`) — once project prefixes are discovered during install, any input matching `{command} {PREFIX}-{number}` is implicitly a Jira command
- User asks about sprint work, backlog, or ticket status

## Ticket Key Recognition

After the install flow discovers project prefixes and stores them in `.agents/.local-config.json` under `jira.project_prefixes`, the agent must treat any token matching `{PREFIX}-{number}` (case-insensitive) as a Jira ticket reference. The `jira` keyword becomes optional:

| User says | Interpreted as |
| --- | --- |
| `fetch jira DTT-115` | `fetch jira DTT-115` |
| `fetch DTT-115` | `fetch jira DTT-115` |
| `fetch dtt-115` | `fetch jira DTT-115` |
| `analyse COP-42` | `analyse jira COP-42` |
| `build CAPCEESF-100` | `build jira CAPCEESF-100` |
| `what is DTT-115 about?` | Treat as an implicit `fetch jira DTT-115` |

The prefix match is case-insensitive. The ticket key should be normalised to uppercase when used in API calls and file names (e.g. `dtt-115` → `DTT-115`).

## Install / Setup Flow

When a user says **"install Jira skills"** or **"init Jira"**, follow this guided flow:

### Step 1 — Check Existing Config

Read `.agents/.local-config.json` and inspect the `jira` block. Identify which fields are missing or blank:
- `base_url`
- `email`
- `api_token`

If all three are populated, skip to Step 3.

### Step 2 — Prompt for Missing Values

Ask the user **only** for the values that are blank:

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
> The token is stored **only** in `.agents/.local-config.json` (gitignored, never committed) and will **never** be displayed in chat.

Write each value into `.agents/.local-config.json`. **Never echo the API token.**

### Step 3 — Test Connection

Run a read-only auth check:

```
GET {base_url}/rest/api/3/myself
```

Report:
- Success: `Jira connection OK — authenticated as {displayName}`
- Failure: `Jira connection FAILED — HTTP {status}. Please check your credentials.`

Do not print the response body, auth headers, or token.

### Step 4 — Discover Project Prefixes

After auth succeeds, retrieve the list of accessible Jira projects:

```
GET {base_url}/rest/api/3/project?expand=description&status=live
```

Extract each project's `key` and `name`. These are the ticket naming prefixes (e.g. `DTT`, `COP`, `CAPCEESF`). Present them to the user:

> **Discovered Jira projects:**
> | Project Key | Project Name |
> | --- | --- |
> | DTT | Digital Transformation Team |
> | COP | Customer Operations Platform |
> | CAPCEESF | Cap Cee Salesforce |
>
> Ticket references like `DTT-115`, `COP-42`, or `CAPCEESF-100` will be recognised automatically.

Store the discovered prefixes in `.agents/.local-config.json` under `jira.project_prefixes` so future sessions can recognise ticket keys without re-querying:

```json
{
  "jira": {
    "base_url": "...",
    "email": "...",
    "api_token": "...",
    "project_prefixes": ["DTT", "COP", "CAPCEESF"]
  }
}
```

### Step 5 — Read the Board

Attempt to fetch the active sprint or board to show current ticket state:

```
GET {base_url}/rest/agile/1.0/board?type=scrum
```

If a board is found, retrieve the active sprint's issues and display a summary in chat. If no board or sprint is found, skip this step silently.

### Step 6 — Confirm Setup & Show Command Glossary

Present the skill summary and available commands:

> **Jira skills installed successfully.**
>
> This skill provides **read-only access** to your Jira platform. It can download ticket details, track them locally, analyse requirements, and generate implementation plans — but it will **never modify anything in Jira**. Comments for Jira are generated locally for you to copy-paste manually.
>
> **Available commands** (examples use your project prefixes):
>
> | Command | What it does |
> | --- | --- |
> | `fetch jira DTT-115` | Pull latest ticket details from Jira, diff against local copy if one exists, summarise changes, and create/update the local ticket file |
> | `analyse jira DTT-115` | Fetch + deep requirements analysis: review the proposed solution, diff local repo against dev org, produce an implementation plan with impact assessment and test scenarios |
> | `build jira DTT-115` | Implement the ticket: generate/modify metadata and code locally, build test classes, dry-deploy to dev org, produce the deployment manifest |
> | `deploy jira DTT-115` | Show the deployment manifest, request verbal confirmation, then deploy to the default dev org |
> | `test jira DTT-115` | Dry deploy with test runs only — does not persist any changes to the org |
> | `comment jira DTT-115` | Generate a review comment summarising the implementation, testing, and manual setup steps — output to chat for manual copy-paste into Jira |
>
> All Jira access is read-only. Local file creation and Salesforce org deploys follow the framework's existing confirmation gates.

## Credential Loading

This skill follows the **framework local config convention**: all user-specific values live under a namespaced key in `.agents/.local-config.json` (gitignored, never committed). See `_convention` in `.agents/.local-config.template.json`.

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

On Windows PowerShell:
```powershell
$config = Get-Content ".agents/.local-config.json" | ConvertFrom-Json
$pair = "$($config.jira.email):$($config.jira.api_token)"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{ "Authorization" = "Basic $base64"; "Accept" = "application/json" }
```

On Bash:
```bash
config=$(cat .agents/.local-config.json)
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

Search the response for fields whose `name` matches (case-insensitive):
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

## Command Reference

### `fetch jira {KEY}`

Pull the latest ticket details from Jira. If a local ticket file already exists at `.agents/project/tickets/{KEY}.md`:

1. Read the local file.
2. Fetch the latest from Jira.
3. Compare the latest comment and field values against the local copy.
4. Summarise what changed since last sync in chat.
5. If the user approves, update the local file with the new data.

If no local file exists:

1. Fetch the ticket from Jira.
2. Present the ticket summary in chat.
3. Create the local ticket file using the template from `PROJECT_TRACKING.MD`, populating all available sections: metadata, description, requirements, acceptance criteria, solution, dependencies, comments summary.

Always update the agile board lane after creating/updating a ticket file.

### `analyse jira {KEY}`

Performs everything `fetch` does, then continues with deep analysis:

1. If the local ticket is not up to date, sync it first.
2. Parse and review the ticket requirements and specification.
3. Review the proposed solution (from custom fields or description).
4. Run a diff between the default dev org and the local repo to identify existing metadata relevant to the ticket scope.
5. Based on the diff and requirements, produce:
   - **Implementation plan** — ordered steps with file-level scope
   - **Impact assessment** — which existing components are affected, potential overrides
   - **Manual steps** — pre-deploy and post-deploy manual actions required
   - **Test scenarios** — test cases derived from acceptance criteria and requirements
6. Save everything to the local ticket file under the appropriate sections.
7. Do not modify any source files — analysis only.

### `build jira {KEY}`

Implements the ticket locally:

1. Ensure the ticket has been analysed (run `analyse` first if needed).
2. Check for dependencies on other tickets — if blockers exist, warn the user.
3. Generate or modify Salesforce metadata and Apex code locally according to the implementation plan.
4. Build test classes to cover the new/modified code.
5. Perform a dry deploy (`sf project deploy start --dry-run`) to the default dev org with test execution.
6. If errors occur, make corrections and re-run until the dry deploy passes.
7. When clean, build the deployment manifest (list of components, dependencies, pre/post steps).
8. Save the deployment manifest to the ticket file.
9. **Do not deploy** — stop here. If deployment conflicts are detected during the dry run, advise the user in chat.

Source file generation and modification follow the framework's existing Salesforce standards, Apex standards, and lean code standards.

### `deploy jira {KEY}`

Deploys the built ticket to the default dev org:

1. Read the deployment manifest from the local ticket file.
2. Present the manifest in chat: components, dependencies, manual pre-deploy steps, manual post-deploy steps.
3. **Request explicit verbal confirmation** from the user before proceeding.
4. Once confirmed, run the Salesforce deploy via the framework's [Deployment workflow](../../workflows/DEPLOYMENT.md).
5. Report deploy results — success or failure with details.
6. Update the ticket file with deployment outcome.

This command follows all existing framework deployment gates (org conflict check, coverage gate, manual confirmation).

### `test jira {KEY}`

Dry deploy with test execution only:

1. Run `sf project deploy start --dry-run` with relevant test classes against the default dev org.
2. Report test results — pass/fail, coverage percentage, any failures with details.
3. **Do not persist any changes to the org.**
4. Update the ticket file with test results under QA Notes.

### `comment jira {KEY}`

Generate a review comment for the user to manually copy-paste into Jira:

1. Read the local ticket file.
2. Compose a structured comment summarising:
   - What was implemented (components, files changed)
   - Test results and coverage
   - Manual setup steps required (permission sets, custom settings, etc.)
   - How to verify/test the implementation
   - Any known limitations or follow-up items
3. Output the comment in chat as a formatted text block the user can copy.
4. **Do not post to Jira** — this skill is read-only on the Jira platform.

## Security Rules

- **Never** print auth headers, Basic auth strings, or API tokens in chat or files
- **Never** store raw API tokens in tracked (committed) files
- **Never** make POST, PUT, PATCH, or DELETE requests to the Jira API
- **Never** include raw sensitive payloads in local ticket files
- Sanitize error responses before displaying (remove auth details)
- The `.agents/.local-config.json` file must remain gitignored at all times
