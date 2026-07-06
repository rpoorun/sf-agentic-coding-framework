# Jira Workflow

## Purpose and Use

This workflow governs all interactions with Jira Cloud from within this repository. The Jira skill is **strictly read-only on the Jira platform** — all API calls to Jira are HTTP GET. Local file creation, Salesforce org deploys, and test runs are governed by the framework's existing workflows and confirmation gates.

## Prime Directive — Read-Only

The agent must **never** create, update, transition, comment on, link, or delete any resource in Jira via the API. No POST, PUT, PATCH, or DELETE requests to Jira are permitted. If the user asks for a Jira write action, explain that the skill is read-only and suggest they perform it manually in Jira. The `comment jira` command generates text locally for manual copy-paste — it does not post to Jira.

## Command Workflow Reference

Each command below is triggered by the user saying the command followed by a ticket key. The ticket key must match a known project prefix discovered during install (e.g. `DTT-115`, `COP-42`, `CAPCEESF-100`). Commands and ticket keys are case-insensitive — normalise keys to uppercase for API calls and file names.

The `jira` keyword is optional once project prefixes are known. `fetch DTT-115` and `fetch jira DTT-115` are equivalent. A bare ticket key in a natural-language question (e.g. "what is DTT-115 about?") should be treated as an implicit `fetch`. See the Ticket Key Recognition table in the [Jira skill](../skills/jira-management/SKILL.md#ticket-key-recognition) for the full mapping.

---

### `fetch jira {KEY}`

**Purpose:** Pull latest ticket details from Jira, diff against local copy, create or update the local ticket file.

**Workflow:**

1. **Inspect branch and worktree**
   ```
   git branch --show-current
   git status --short --branch
   ```
   Check if the branch name contains the ticket key.

2. **Load Jira config**
   Read `.agents/.local-config.json` → `jira` block. If any credential is blank, run the install flow (see SKILL.md Install / Setup Flow).

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
   - Description → ADF to Markdown
   - Custom fields → ADF to Markdown where applicable
   - Comments → author, date, parsed body
   - Issue links → relationship type, linked key, summary

7. **Check for existing local file**
   Look for `.agents/project/tickets/{KEY}.md`.

   **If local file exists:**
   - Read the local file
   - Compare Jira `updated` timestamp against local `Last Synced`
   - Identify new/changed comments since last sync
   - Summarise changes in chat: field changes, new comments, status changes
   - Ask user to approve the update
   - On approval, merge new data into local file preserving manually-written sections (Implementation Plan, QA Notes, Handoff Notes, etc.)

   **If no local file:**
   - Present ticket summary in chat
   - Create new local ticket file using the template from PROJECT_TRACKING.MD
   - Populate all available sections from Jira data
   - Leave implementation-specific sections (Implementation Plan, File Scope, QA Notes, etc.) as placeholders

8. **Update agile board**
   Move/add the ticket to the correct board lane based on its Jira status.

---

### `analyse jira {KEY}`

**Purpose:** Deep requirements analysis — review solution, diff against dev org, produce implementation plan.

**Workflow:**

1. **Sync ticket** — run `fetch jira {KEY}` if the local file is missing or stale.

2. **Parse requirements**
   - Extract acceptance criteria, solution, rules & conditions from the ticket
   - Identify explicit and implicit requirements
   - Note any ambiguities or missing details

3. **Review proposed solution**
   - Read the Solution custom field and any design notes in comments
   - Assess feasibility against the current codebase

4. **Diff local repo against dev org**
   - Identify which Salesforce metadata types are in scope based on the ticket
   - Retrieve the relevant metadata into the temp workspace: `sf project retrieve start --output-dir .agents/temp/retrieve-{KEY}/ ...` (with framework confirmation gates)
   - Diff the retrieved org state against local source
   - Document existing metadata that will be affected
   - The retrieved metadata in `.agents/temp/retrieve-{KEY}/` is transient — it must never be staged or committed (see [Temp Workspace](../directives/AGENT_GUARDRAILS.md#temp-workspace))

5. **Produce implementation plan**
   Save to the local ticket file:
   - **Implementation Plan** — ordered steps with file-level scope
   - **Impact Assessment** — components affected, potential overrides, conflicts
   - **Manual Steps** — pre-deploy and post-deploy actions
   - **Test Scenarios** — test cases derived from acceptance criteria
   - **Risk Assessment** — deployment conflicts, data migration needs, permission changes

6. **Report in chat**
   Summarise the analysis and flag any blockers or questions that need user input.

---

### `build jira {KEY}`

**Purpose:** Implement the ticket — generate/modify metadata and code locally, build tests, dry deploy.

**Workflow:**

1. **Verify analysis exists** — if no Implementation Plan in the local ticket file, run `analyse jira {KEY}` first.

2. **Check dependencies**
   - Read issue links from the ticket file
   - If blocking tickets exist, check their status
   - Warn the user about unresolved blockers

3. **Implement**
   - Follow the Implementation Plan step by step
   - Generate or modify Salesforce metadata and Apex code locally
   - Follow framework standards: [Salesforce Apex Standards](../standards/SALESFORCE_APEX_STANDARDS.md), [Lean Code Standards](../standards/LEAN_CODE_STANDARDS.md), [Trigger Framework](../standards/APEX_TRIGGER_FRAMEWORK.md), etc.
   - Build test classes for new/modified Apex

4. **Dry deploy**
   ```
   sf project deploy start --dry-run --target-org {defaultOrg} --test-level RunLocalTests
   ```
   - If errors occur, diagnose and fix locally
   - Re-run until the dry deploy passes cleanly
   - Report test coverage and any warnings

5. **Build deployment manifest**
   Save to the ticket file:
   - Components included in the deployment
   - Dependencies and deployment order
   - Pre-deploy manual steps
   - Post-deploy manual steps
   - Test classes and expected coverage

6. **Stop — do not deploy**
   If deployment conflicts were detected, advise the user in chat with specific details.

---

### `deploy jira {KEY}`

**Purpose:** Deploy the built ticket to the default dev org after user confirmation.

**Workflow:**

1. **Read deployment manifest** from the local ticket file. If none exists, tell the user to run `build jira {KEY}` first.

2. **Present manifest in chat**
   Show: components, dependencies, pre-deploy manual steps, post-deploy manual steps, expected test coverage.

3. **Request explicit verbal confirmation**
   > The following deployment is ready. Please confirm by saying "yes" or "confirm" to proceed.

4. **Execute deploy**
   Follow the framework's [Deployment workflow](DEPLOYMENT.md) including:
   - Pre-deploy org conflict check
   - `sf project deploy start` to the default dev org
   - Test execution with 95% coverage gate

5. **Report results**
   - Success: components deployed, test results, coverage
   - Failure: error details, suggested fixes

6. **Update ticket file**
   Record deployment outcome, timestamp, and any post-deploy observations.

---

### `test jira {KEY}`

**Purpose:** Dry deploy with test execution only — no changes persisted to the org.

**Workflow:**

1. Run:
   ```
   sf project deploy start --dry-run --target-org {defaultOrg} --test-level RunLocalTests
   ```

2. Report:
   - Test pass/fail counts
   - Coverage percentage per class
   - Any test failures with details

3. **Do not persist** any changes to the org.

4. Update the ticket file QA Notes section with test results.

---

### `comment jira {KEY}`

**Purpose:** Generate a review comment for the user to manually paste into Jira.

**Workflow:**

1. Read the local ticket file.

2. Compose a structured comment:
   ```
   ## Implementation Summary
   - Components: {list of created/modified files}
   - Branch: {current branch name}

   ## Testing
   - Test classes: {list}
   - Coverage: {percentage}
   - All tests passing: {yes/no}

   ## Manual Setup Required
   - {permission set assignments, custom settings, etc.}

   ## How to Verify
   1. {step-by-step verification instructions}

   ## Notes
   - {known limitations, follow-up items}
   ```

3. Output the comment in chat as a copyable text block.

4. **Do not post to Jira.** Remind the user to paste it manually.

---

## Error Handling

- Auth failures: report HTTP status only, suggest re-checking credentials
- 404 on ticket: report that the key was not found
- Rate limiting (429): report and suggest waiting
- Network errors: report the error type, not raw stack traces
- **Never** include auth headers or tokens in error messages
- **Never** retry with modified HTTP methods — all Jira calls are GET only
