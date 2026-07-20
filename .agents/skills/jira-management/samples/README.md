# jira-management — Payload Samples

Ready-to-adapt JSON for the [skill's](../SKILL.md) most-used operations. Every sample carries a `_comment` key stating its endpoint, operation ID, and required project-tier scope — **strip `_comment` keys before sending**. None of these files contain credentials; auth is a header, never part of a payload.

| File | Operation | Method scope |
| --- | --- | --- |
| [adf-document.json](adf-document.json) | ADF body structure (descriptions, comments, worklog notes) — heading, links, mention, list, code block | n/a (format reference) |
| [issue-response-extract.json](issue-response-extract.json) | Trimmed `getIssue` **response** showing the standard extraction paths incl. custom fields via `names` | GET |
| [jql-search.json](jql-search.json) | `POST /rest/api/3/search/jql` — JQL search body (current endpoint; `/search` is deprecated) | GET-equivalent read |
| [create-issue.json](create-issue.json) | `POST /rest/api/3/issue` — create issue | POST |
| [add-comment.json](add-comment.json) | `POST /rest/api/3/issue/{key}/comment` — add comment (same shape for update via PUT) | POST / PUT |
| [edit-issue.json](edit-issue.json) | `PUT /rest/api/3/issue/{key}` — `fields` vs `update` verbs | PUT |
| [transition-issue.json](transition-issue.json) | `POST /rest/api/3/issue/{key}/transitions` — status change with resolution + comment | POST |

Reminders when adapting:

- Write calls run only in installs whose scope allows the method, and each call passes the [write gate](../SKILL.md#write-operation-gates) first.
- IDs are instance-specific: transition IDs from `GET .../transitions`, custom field IDs from `GET /rest/api/3/field`, account IDs from user search — never reuse the sample IDs.
- Required fields per project/issue type: `GET /rest/api/3/issue/createmeta/{projectIdOrKey}/issuetypes/{issueTypeId}` (create) or `GET .../editmeta` (edit).
- The full operation catalog is in [references/api-reference.md](../references/api-reference.md); conventions and schema links in [references/schema-structure.md](../references/schema-structure.md).
