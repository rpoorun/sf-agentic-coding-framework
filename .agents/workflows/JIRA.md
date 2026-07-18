# Jira Fetch Workflow

## Purpose and Use

This workflow defines the single Jira-facing operation: fetching a ticket from the Jira Cloud API and delivering parsed ticket data. It is the bridge between the [Jira skill](../skills/jira-management/SKILL.md) (API connection layer) and [PROJECT_TRACKING.md](PROJECT_TRACKING.md) (local ticket management layer).

This workflow does **not** own local ticket files, the agile board, analysis, implementation, deployment, testing, or comment generation. Those responsibilities belong to [PROJECT_TRACKING.md](PROJECT_TRACKING.md) and the framework's existing workflows.

## Prime Directive — Fetch Is Read-Only

Everything this workflow does is HTTP GET. Write access to Jira (POST/PUT/DELETE) exists only through the [Jira skill](../skills/jira-management/SKILL.md#capability--scoping-model) in installs whose project-tier scope allows it, and every write passes a per-call confirmation gate. In the default read-only scope, the `comment` command in [PROJECT_TRACKING.md](PROJECT_TRACKING.md) generates text locally for manual copy-paste — it does not post to Jira.

## Ticket Key Recognition

The `jira` keyword is optional once project prefixes are known. `fetch DTT-115` and `fetch jira DTT-115` are equivalent. A bare ticket key in a natural-language question (e.g. "what is DTT-115 about?") is an implicit fetch. See the [Ticket Key Recognition](../skills/jira-management/SKILL.md#ticket-key-recognition) table in the Jira skill.

Commands other than `fetch` (`analyse`, `build`, `deploy`, `test`, `comment`) are recognised by the same prefix matching but routed to [PROJECT_TRACKING.md](PROJECT_TRACKING.md), not this workflow.

---

## `fetch {KEY}`

**Purpose:** Pull the latest ticket details from Jira and deliver parsed data to the project tracking layer.

**Workflow:**

1. **Inspect branch and worktree**
   ```
   git branch --show-current
   git status --short --branch
   ```
   Check if the branch name contains the ticket key.

2. **Load Jira config**
   Resolve credentials using the [layered credential lookup](../skills/jira-management/SKILL.md#credential-loading): secret manager → env vars (`JIRA_BASE_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`) → OS keychain → `{PROJECT_AGENTS}/project/.local-config.json` (local machines only) → interactive prompt. If no source yields complete credentials, run the install flow (see [SKILL.md Install / Setup Flow](../skills/jira-management/SKILL.md#install--setup-flow)).

3. **Test auth** (first call in session or after a failure)
   ```
   GET {base_url}/rest/api/3/myself
   ```
   Report `OK` or `FAILED — HTTP {status}`. Never print auth details.

4. **Fetch ticket**
   ```
   GET {base_url}/rest/api/3/issue/{KEY}?expand=renderedFields,names
   ```

5. **Fetch custom field metadata** (once per session)
   ```
   GET {base_url}/rest/api/3/field
   ```
   Map field IDs to names for: Acceptance Criteria, Solution, Rules & Conditions, Scope, Story Points, Requirements, Dependencies.

6. **Parse content**
   - Description → ADF to Markdown (see [SKILL.md ADF parsing](../skills/jira-management/SKILL.md#parsing-adf-atlassian-document-format))
   - Custom fields → ADF to Markdown where applicable
   - Comments → author, date, parsed body
   - Issue links → relationship type, linked key, summary

7. **Hand off to project tracking**
   Pass the parsed ticket data to [PROJECT_TRACKING.md](PROJECT_TRACKING.md) for local file creation/update and board management. See the [Ticket Sync](PROJECT_TRACKING.md#ticket-sync) section.

---

## Error Handling

- Auth failures: report HTTP status only, suggest re-checking credentials
- 404 on ticket: report that the key was not found
- Rate limiting (429): report and suggest waiting
- Network errors: report the error type, not raw stack traces
- **Never** include auth headers or tokens in error messages
- **Never** retry with modified HTTP methods — all Jira calls are GET only
