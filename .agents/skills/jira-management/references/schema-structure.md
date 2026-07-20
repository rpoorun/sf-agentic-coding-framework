# Jira Cloud REST API v3 — Swagger Schema Structure & Official Links

Support material for the [`jira-management`](../SKILL.md) skill: how the official OpenAPI (swagger) specification is structured, what the API's conventions are, and where the authoritative documentation lives. Source of record for regenerating [api-reference.md](api-reference.md).

## Official Links

| Resource | URL |
| --- | --- |
| **API intro / about** (start here) | https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#about |
| Full v3 API reference (browsable) | https://developer.atlassian.com/cloud/jira/platform/rest/v3/ |
| **OpenAPI spec download** (`swagger-v3.v3.json`) | https://developer.atlassian.com/cloud/jira/platform/swagger-v3.v3.json |
| **Postman collection download** (`jiracloud.3.postman.json`) | https://developer.atlassian.com/cloud/jira/platform/jiracloud.3.postman.json |
| Jira Software (Agile) REST API (`/rest/agile/1.0/`) | https://developer.atlassian.com/cloud/jira/software/rest/intro/ |
| Basic auth with API tokens | https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/ |
| Manage API tokens (user-facing) | https://id.atlassian.com/manage-profile/security/api-tokens |
| OAuth 2.0 (3LO) apps & scopes | https://developer.atlassian.com/cloud/jira/platform/oauth-2-3lo-apps/ |
| Atlassian Document Format (ADF) structure | https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/ |
| Pagination conventions | https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#pagination |
| Expansion, ordering, special headers | https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#expansion |
| Rate limiting | https://developer.atlassian.com/cloud/jira/platform/rate-limiting/ |
| API status & deprecation policy | https://developer.atlassian.com/cloud/jira/platform/deprecation-policy/ |
| Changelog (breaking API changes) | https://developer.atlassian.com/cloud/jira/platform/changelog/ |
| JQL reference | https://support.atlassian.com/jira-software-cloud/docs/use-advanced-search-with-jira-query-language-jql/ |

## Spec Snapshot Used by This Skill

| Field | Value |
| --- | --- |
| Title | The Jira Cloud platform REST API |
| OpenAPI version | 3.0.1 |
| Spec version snapshot | `1001.0.0-SNAPSHOT-3483ab4f777f667dfc438a82ade5da45e16de73e` |
| Downloaded | 2026-07-17 (files `swagger-v3.v3.json`, `jiracloud.3.postman.json`) |
| Server | `https://your-domain.atlassian.net` |
| Operations | 616 (275 GET / 134 POST / 118 PUT / 89 DELETE) across 100 tags |
| Component schemas | 970 |
| Experimental operations | 114 (`x-experimental: true`) |

## Structure of the OpenAPI Spec

Top-level keys of `swagger-v3.v3.json`:

```
openapi                  "3.0.1"
info                     { title, description, version, contact, license }
servers                  [ { url: "https://your-domain.atlassian.net" } ]
tags                     100 resource groups — { name, description }; each operation belongs to one tag
paths                    URL template → { get | post | put | delete } → operation object
components
  ├─ schemas             970 named request/response models (JSON Schema), referenced via $ref
  └─ securitySchemes     { basicAuth, OAuth2 } — see below
externalDocs             link back to developer.atlassian.com
x-atlassian-narrative    prose documentation blocks (the intro text on the reference site)
```

### Operation Object Shape

Each `paths.{url}.{method}` entry carries:

| Key | Meaning |
| --- | --- |
| `operationId` | Unique ID (e.g. `getIssue`, `createIssue`) — used in [api-reference.md](api-reference.md) and valid `allowed_operations` entries |
| `summary` / `description` | Human-readable purpose; description includes required Jira permissions |
| `tags` | Owning resource group |
| `parameters` | Path/query/header parameters with JSON Schema types |
| `requestBody` | For writes — `$ref` into `components.schemas` |
| `responses` | HTTP status → response schema |
| `security` | Accepted auth: usually `[{basicAuth}, {OAuth2: [scopes]}, {}]` |
| `deprecated` | `true` when the operation is superseded (e.g. old search endpoints) |
| `x-experimental` | `true` = may change without deprecation notice |
| `x-atlassian-oauth2-scopes` | Granular + classic OAuth scopes per operation |
| `x-atlassian-connect-scope` | Required Connect app scope (`READ`, `WRITE`, `ADMIN`, …) |
| `x-atlassian-data-security-policy` | App-access-rule constraints for app contexts |

### URL Namespaces in the Spec

| Prefix | What it is | Callable with basic auth? |
| --- | --- | --- |
| `/rest/api/3/...` | Jira platform REST API v3 (the main surface) | Yes |
| `/rest/agile/1.0/...` | Jira Software boards/sprints/backlog (separate spec; skill uses it for boards) | Yes |
| `/rest/atlassian-connect/1/...` | Connect app lifecycle (app properties, migrations, dynamic modules) | No — Connect app JWT auth only |
| `/rest/forge/1/...` | Forge app properties | No — Forge app auth only |
| `/rest/internal/...` | Atlassian-internal, undocumented | No — never use |

### Authentication Schemes

`components.securitySchemes` defines:

- **`basicAuth`** (`type: http, scheme: basic`) — email + API token. The skill's default; simplest for user-tier personal credentials.
- **`OAuth2`** (`type: oauth2`, authorization-code flow via `https://auth.atlassian.com/authorize`) — hundreds of granular scopes shaped `{action}:{resource}:jira` (e.g. `read:issue:jira`, `write:comment:jira`, `delete:attachment:jira`) plus classic scopes (`read:jira-work`, `write:jira-work`, `manage:jira-project`, `manage:jira-configuration`). Relevant when a project installs the skill against an OAuth app instead of a personal token.
- Anonymous access (`{}` in an operation's `security` list) — some read endpoints allow it when the Jira site permits public access; never rely on it.

The OAuth scope taxonomy mirrors this skill's project-tier method scoping: `read:*` ↔ GET, `write:*` ↔ POST/PUT, `delete:*` ↔ DELETE. A project that connects via OAuth should request only the scopes matching its `allowed_methods`.

### API Conventions (from the intro documentation)

- **Pagination** — collection responses return `startAt`, `maxResults`, `total` (or `isLast`/`nextPage` cursors on newer endpoints). Always iterate until exhausted or the needed item is found; never assume one page is everything.
- **Expansion** — heavy fields are returned only when requested: `?expand=renderedFields,names,transitions`.
- **Field selection** — `?fields=summary,status` trims responses; prefer it on searches.
- **ADF** — rich-text fields (`description`, comment `body`, worklog comments) are Atlassian Document Format JSON trees, both in responses and in write payloads.
- **JQL search** — `GET/POST /rest/api/3/search/jql` is the current search API (the older `/rest/api/3/search` is deprecated in the spec).
- **Async tasks** — some bulk/heavy operations (e.g. bulk delete, project delete) return a `taskId`; poll `GET /rest/api/3/task/{taskId}`.
- **Permissions** — every operation's description states the Jira permissions required (e.g. *Browse Projects*, *Administer Jira*). A 403 usually means the authenticated user lacks that Jira permission, not that the token is invalid.
- **Rate limiting** — 429 with `Retry-After`; back off, never hammer.
- **Experimental** (`x-experimental`) — usable but may change without notice; prefer stable operations when both exist.

## The Postman Collection

`jiracloud.3.postman.json` (Postman Collection v2.0) mirrors the same 616 operations, organised into the same resource folders, with:

- Collection variables: `{{protocol}}`, `{{host}}`, `{{basePath}}`, `{{username}}`, `{{apiToken}}`
- Per-request basic auth pre-configured as `{{username}}` / `{{apiToken}}`

It is the convenient way for a **human** to explore or manually test an endpoint before scoping it into a project install: import into Postman, set `host` to `your-site.atlassian.net`, `username` to the login email, and `apiToken` to an API token.

## Keeping This Skill Current

1. Re-download the spec: https://developer.atlassian.com/cloud/jira/platform/swagger-v3.v3.json (and optionally the Postman collection).
2. Regenerate [api-reference.md](api-reference.md) with the bundled script — `python ../scripts/generate-api-reference.py --download` (or `--spec <downloaded file>`). It parses `paths`, groups operations by first tag, emits the Resource Group Index (per-group GET/POST/PUT/DELETE counts) followed by one table per group with Method / Path / Operation ID / Summary, flags `x-experimental` (🧪) and `deprecated` (⚠️), and routes `/rest/internal/` paths to the "Internal (untagged)" group.
3. Update the **Spec Snapshot** table above (spec version string, counts, date).
4. Check the [changelog](https://developer.atlassian.com/cloud/jira/platform/changelog/) for breaking changes affecting the [core operations](../SKILL.md#core-operations-read) the framework depends on.
5. Bump the skill's `metadata.version` and record the change in the framework `CHANGELOG.md`.
