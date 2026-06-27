# Salesforce Skills

## Purpose And Use

This file maps Salesforce task types to the synthesized skill folders installed under `.agents/skills/sf-<cloud>-<name>/` and explains the naming convention, the synthesis process used to build them, and how to adapt them to client-specific project rules. Read it when selecting a capability for Apex, tests, metadata, data, LWC, Flow, SLDS, security, Agentforce, integration, OmniStudio, or specialized platform work. Put capability-routing rules, local skill adaptations, and skill-specific delivery constraints here.

## Naming Convention

Every installed skill folder is named `sf-{cloud}-{name}`:

- `sf-` — fixed prefix identifying a Salesforce skill local to this framework.
- `{cloud}` — the Salesforce cloud or capability domain the skill belongs to: `platform` (core Apex/LWC/Flow/metadata/data/schema development), `design` (SLDS/UX), `dx` (DevOps tooling), `security`, `agentforce`, `integration`, `omnistudio`, `tooling` (diagrams and other dev-support utilities), `meta` (skill discovery/evaluation), and reserved domains such as `commerce`, `mobile`, `data360` for when those families are installed.
- `{name}` — a short, specific capability name (`apex`, `trigger`, `lwc`, `flow`, `soql`, `deploy`, `store`, …). Prefer the smallest name that still disambiguates from sibling skills in the same cloud.

Examples: `sf-platform-apex`, `sf-platform-lwc`, `sf-design-slds-apply`, `sf-commerce-store` (reserved name pattern for a future Commerce Cloud skill, not yet installed).

## Why These Skills Are Synthesized, Not Copied Verbatim

The skills in this folder originated from two external catalogs:

- [forcedotcom/sf-skills](https://github.com/forcedotcom/sf-skills) (folders originally named `platform-*`, `automation-*`, `experience-*`, `design-systems-*`, `dx-*`).
- [Clientell-Ai/salesforce-skills](https://github.com/Clientell-Ai/salesforce-skills) (folders originally named `sf-*`, e.g. `sf-apex`, `sf-flow`, `sf-lwc`).

Both catalogs cover overlapping ground (for example, Apex generation existed as both `platform-apex-generate` and `sf-apex`). Installing both verbatim produced duplicate, inconsistently formatted instructions for the same task. Each skill below was therefore **synthesized**: the richer/more detailed source became the primary body, the other source's unique guidance was folded in under a "Merged Source Material" section inside the same `SKILL.md`, and a standardized frontmatter + header table was applied to every file. See [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md#installing-this-framework-into-a-new-repository) for the mandatory synthesis procedure that must be repeated whenever new external skills are added.

### Standard Skill File Format

Every `SKILL.md` in this folder follows this shape:

```markdown
---
name: sf-{cloud}-{name}
description: "<activation description, carried over from the primary source>"
metadata:
  version: "1.0"
  cloud: "<Cloud>"
  synthesized: true
  sources:
    - <org/repo> :: <original-folder-name>
    - <org/repo> :: <original-folder-name>
---

# sf-{cloud}-{name}: <Title>

| Field | Value |
| --- | --- |
| Skill ID | `sf-{cloud}-{name}` |
| Cloud | <Cloud> |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | <org/repo> :: <folder>; <org/repo> :: <folder> |

<primary source body>

---

## Merged Source Material
<deduplicated supplemental guidance from the secondary source, kept only where it adds value beyond the primary body>
```

Do not introduce a different header shape for a new or re-synthesized skill; match this table exactly so every skill file is scannable the same way.

## Priority Order

When instructions conflict, apply this order:

1. Current user instruction.
2. Client-specific project standard or ticket instruction.
3. Repository-specific README, `AGENTS.md`, architecture decision, or established code pattern.
4. [Org] Salesforce best-practice baseline.
5. The synthesized skill's primary guidance, then its merged supplemental guidance.
6. General Salesforce platform practice.

PMD and security gates do not disappear because a skill suggests a faster path.

## Skill Router

| Work type | Skill folder (`.agents/skills/<name>`) | Local adaptation |
| --- | --- | --- |
| Apex classes, triggers, services, selectors, async jobs, invocables, REST resources | `sf-platform-apex` | Use [Org] naming and layering where the repo already follows it; PMD must remain clean or violations must be explained. |
| Apex tests, mocks, test data factories | `sf-platform-test` | Use `ClassName_TEST`, `@TestSetup`, no `SeeAllData=true`, meaningful assertions, positive/negative/bulk cases, and expected/actual assert ordering. |
| Apex debug logs, governor limits, runtime troubleshooting | `sf-platform-debug` | Use for compile/parse failures, governor-limit failures, and log-driven diagnosis; delegate test-result analysis to `sf-platform-test`. |
| SOQL/SOSL design or query review | `sf-platform-soql` | Prefer selectors or Data Managers; no non-selective broad queries; bind variables for dynamic filters. |
| Metadata deploy, retrieve, validation, CI/CD, package.xml, rollback | `sf-platform-deploy` | Dry-runs, validations, and Apex test runs are allowed verification actions; real deploys still require confirmation. Keep scope manifest-based or source-dir targeted. |
| Salesforce data create/update/delete/import/export, bulk operations, migration | `sf-platform-data` | Default to script generation unless the user explicitly asks for remote execution; remote org data writes require confirmation and cleanup guidance. |
| Custom object/field/tab/application metadata, schema scaffolding | `sf-platform-schema` | Follow [Org] naming, descriptions, help text, domain prefixes, and required client translation behavior. |
| Custom Lightning Types (Einstein/Agentforce action schemas) | `sf-platform-clt` | Use only when the task explicitly involves CLTs, widget renditions, or agent action input/output schemas. |
| Lightning pages and FlexiPages | `sf-platform-flexipage` | Bootstrap or edit with valid Salesforce structure; do not handcraft broad XML unless editing a known existing file. |
| List views | `sf-platform-listview` | Match existing filter/column conventions; confirm visibility (owner/all users) before widening. |
| Permission sets, profiles, FLS auditing, access troubleshooting | `sf-platform-permissions` | Use least privilege; security-review high-risk permissions; do not add required fields to field permissions. |
| Sharing rules | `sf-platform-sharing` | Apply least-privilege sharing; security-review criteria-based and owner-based rules that widen access. |
| Validation rules | `sf-platform-validation` | Preserve existing formula logic unless the user asks to replace it; use CDATA for formulas containing XML-sensitive characters. |
| Platform/official documentation lookup | `sf-platform-docs` | Use to ground answers in official Salesforce documentation before generating metadata or code. |
| Flows, Process Builder migration | `sf-platform-flow` | Prefer grounded org metadata and draft-safe deployment; active vs draft state must be reported. |
| Lightning Web Components | `sf-platform-lwc` | Use SLDS, accessible states, no unsafe client trust, no console logs at delivery, and preserve existing project conventions. |
| SLDS application | `sf-design-slds-apply` | Do not override Salesforce base component internals; prefer styling hooks and SLDS tokens. |
| SLDS validation | `sf-design-slds-validate` | Run before delivery on any UI work; treat failures the same as a failing lint/test gate. |
| Static analysis (PMD / Salesforce Code Analyzer) | `sf-dx-analyzer` | PMD ruleset is the local baseline; do not weaken `config/pmd/apex-ruleset.xml` without approval. |
| Security / AppExchange / CRUD-FLS / SOQL-injection audit | `sf-security-audit` | Use for codebase-wide scans, in addition to (not instead of) the Hard-Stop Constraints already enforced inside `sf-platform-apex`. |
| Agentforce agents, topics, actions, Agent Scripts, PromptTemplates | `sf-agentforce-build` | Use only when the repo contains Agentforce; topic/action metadata changes follow the same deploy confirmation gates as other metadata. |
| Named Credentials, Connected Apps, External Services, Platform Events, CDC | `sf-integration-config` | Use Named Credentials or External Credentials; endpoint/auth changes require confirmation. |
| OmniStudio (OmniScripts, FlexCards, Integration Procedures, DataRaptors) | `sf-omnistudio-build` | Use only when the project actually contains OmniStudio/Salesforce Industries components. |
| Mermaid diagrams from metadata (ERD, class, sequence, flow, dependency graphs) | `sf-tooling-diagram` | Use for documentation/review artifacts; never treat generated diagrams as deployable metadata. |
| Skill discovery ("which skill should I use") | `sf-meta-find` | Use to route an ambiguous request to the correct skill folder before starting work. |
| Skill quality evaluation/benchmarking | `sf-meta-eval` | Use only for meta work on the skill library itself, not for everyday delivery tasks. |
| Aura Components | None installed (Aura is legacy/superseded by LWC; neither upstream catalog publishes one) | Apply `SALESFORCE_APEX_STANDARDS.md` and `SALESFORCE_PROJECT_BEST_PRACTICES.md` guardrails by analogy with `sf-platform-lwc` until a source publishes one. |
| Org alias switching, org management, permission set assignment | Not yet installed; synthesize from `forcedotcom/sf-skills`'s `dx-org-manage`, `dx-org-switch`, `dx-org-permission-set-assign` if needed | Local project default is preferred; global org config requires explicit approval. |
| Lightning App coordination | Not yet installed; synthesize from `forcedotcom/sf-skills`'s `platform-lightning-app-coordinate` if needed | Use when sequencing multi-component Lightning App build-out across object, page, and nav-item changes. |
| B2B Commerce / UI bundles / mobile / Data Cloud | Not installed by default | Use only when the repo contains those technologies; synthesize the matching `commerce-*`, `experience-ui-bundle-*`, `mobile-*`, or `data360-*` folder into `sf-commerce-*` / `sf-mobile-*` / `sf-data360-*` per the naming convention above. |

## Adapted Delivery Workflow

For any non-trivial Salesforce source change:

1. Identify the task type and applicable `sf-{cloud}-{name}` skill via the router above (or `sf-meta-find` if ambiguous).
2. Inspect current source conventions before introducing new patterns.
3. Check whether client standards override [Org] defaults.
4. Define the intended metadata and file scope.
5. Make the smallest correct source change.
6. Run local checks available without network or org mutation.
7. Run PMD or Salesforce Code Analyzer (`sf-dx-analyzer`) when available and appropriate.
8. Run deploy dry-runs, deploy validations, and Apex tests when the target org and scope are known.
9. Stop before real deploy, data mutation, commit, push, or org config changes unless the user approved that action.
10. Report changed files, metadata members, checks run, skipped approval-gated actions, and remaining risks.

## Apex Generation Constraints

When using `sf-platform-apex`:

- Use explicit sharing on every class.
- Prefer `with sharing` for user-facing controllers and services.
- Avoid `global` unless managed package, web service, or platform requirements demand it.
- No SOQL, SOSL, DML, callouts, or `@future` in loops.
- Prefer Queueable over new `@future` work.
- Do not use `System.debug` in delivery code.
- Use bind variables and allowlists for dynamic SOQL.
- Avoid hardcoded IDs, URLs, record type IDs, profile names, and picklist logic.
- Use Custom Metadata, Custom Labels, describe calls, or existing project configuration where appropriate.
- Keep old-code refactors incremental unless the task explicitly asks for a broader rewrite.

When the repo uses [Org] layering:

- `SMXXX_ServiceName` contains business logic and calls Entity Managers.
- `EMXXX_ObjectName` handles object data preparation/manipulation and calls Data Managers.
- `DMXXX_ObjectName` owns SOQL, DML, callouts, and database access.
- `TH_ObjectName` or the established trigger handler owns trigger context logic.

If the repo uses another established pattern, follow the repo pattern and document the difference.

## Test Adaptation

When using `sf-platform-test`:

- One Apex class should have at least one matching `ClassName_TEST` class unless project convention differs.
- Test methods need meaningful names and assertions.
- Use assertion messages.
- Do not use existing org data.
- Use `@TestSetup` and test factories for reusable data.
- Create admin and non-admin users when permissions, sharing, or user-context behavior matters.
- Use `System.runAs` when behavior depends on user context.
- Use `Test.startTest()` and `Test.stopTest()` around the behavior under test.
- Cover successful and failed paths.
- Bulk-test trigger-sensitive behavior with more than 200 records when feasible.
- Use record type developer names, not labels.
- Add `ORDER BY` when asserting query order.

## SOQL And Data Access Adaptation

When using `sf-platform-soql`:

- Query only fields that are needed.
- Use selective filters for large objects.
- Keep SOQL in Data Managers, selectors, or the repo's equivalent data-access layer.
- Avoid dynamic SOQL unless necessary.
- Use bind variables for values.
- Allowlist dynamic field and object names.
- Enforce CRUD/FLS for user-facing reads and writes.
- Use `Security.stripInaccessible` or `WITH SECURITY_ENFORCED`/`WITH USER_MODE` where suitable.

## Metadata Generation Adaptation

Custom objects and fields (`sf-platform-schema`):

- Names must follow [Org] conventions unless the client overrides.
- Descriptions are mandatory.
- Help text should be included when it improves usability or picklist clarity.
- Avoid abbreviations and unapproved underscores.
- Use `TECH_` and `REP_` prefixes only for the documented technical/reporting use cases.

Validation rules (`sf-platform-validation`):

- Use clear labels based on field/group plus rule.
- Ensure bypass design follows the project standard, such as user checkbox or hierarchical custom setting.
- Wrap XML-sensitive formulas in CDATA.
- Treat "update formula to" as replacement and "update formula to also" as additive.

Permission sets (`sf-platform-permissions`):

- Apply least privilege.
- Confirm field existence before adding FLS.
- Do not include required fields in field permissions.
- Formula fields must not be editable.
- Security-review `ViewAllData`, `ModifyAllData`, `ManageUsers`, broad API access, and Apex/Visualforce access.

Flows and FlexiPages (`sf-platform-flow`, `sf-platform-flexipage`):

- Prefer official generation/bootstrap paths where available.
- Do not manually invent complex Flow XML if grounded generation tooling is required by the environment.
- Distinguish draft, latest, and active Flow versions.
- Validate page component references and target objects before deployment.

## Deployment Adaptation

`sf-platform-deploy` recommends dry-run first. In this repository, dry-run validation and Apex test execution are allowed verification actions. Real deploys remain approval-gated.

Before running validation or asking for deploy approval:

- Confirm target org alias and environment.
- Confirm manifest, source-dir, or metadata members.
- Confirm test level.
- Confirm whether Flow activation, permission assignments, or data setup are part of the action.
- Confirm rollback or manual recovery expectation for risky changes.

Preferred deployment order:

1. Custom objects and fields.
2. Permission sets.
3. Apex.
4. Flows as draft.
5. Flow activation and post-deploy verification.

## Data Operation Adaptation

`sf-platform-data` distinguishes script generation from remote execution. Use that distinction strictly.

Allowed without remote execution approval:

- Draft anonymous Apex scripts.
- Draft CSV templates.
- Draft data plans.
- Draft cleanup scripts.

Requires approval:

- `sf data` create, update, delete, upsert, import, or bulk commands.
- Anonymous Apex execution.
- Test data seeding in a shared org.
- Cleanup scripts against a real org.
- Exports containing sensitive or customer data.

Use synthetic data, not real PII. Provide cleanup commands when data is created.

## Integration And Auth Adaptation

When using `sf-integration-config`:

- Use Named Credentials or External Credentials.
- Avoid hardcoded credentials, tokens, endpoints, and secrets.
- Use HTTPS endpoints.
- Treat Connected Apps, OAuth flows, certificates, CORS, CSP Trusted Sites, Remote Site Settings, Named Credentials, and External Credentials as approval-gated metadata.
- Redact secrets in logs and handoffs.

## UI And SLDS Adaptation

When using `sf-platform-lwc`, `sf-design-slds-apply`, `sf-design-slds-validate`:

- Prefer Lightning Base Components where they satisfy the requirement.
- Use SLDS blueprints only when base components are insufficient.
- Use SLDS styling hooks and tokens rather than overriding internal classes.
- Preserve accessibility: labels, keyboard behavior, focus states, aria attributes, loading, empty, and error states.
- Remove `console.log` before delivery.
- Do not trust client-side validation alone; server-side Apex must validate security and data integrity.

## Optional Specialized Skills

Not installed by default. Synthesize from the matching upstream folder(s) before use, following the naming convention and synthesis procedure above:

- Data Cloud → `sf-data360-*` (from `forcedotcom/sf-skills`'s `data360-*` folders).
- OmniStudio → already installed as `sf-omnistudio-build`; pull additional `omnistudio-*` folders from `forcedotcom/sf-skills` for deeper coverage (datapacks, EPC catalog, dependency analysis) and merge into it.
- Agentforce → already installed as `sf-agentforce-build`; pull `agentforce-*` folders from `forcedotcom/sf-skills` for architecture analysis/testing/observability and merge.
- Commerce and UI bundles → `sf-commerce-*` (from `commerce-b2b-*`) and `sf-experience-*` (from `experience-ui-bundle-*`).
- Mobile → `sf-mobile-*` (from `mobile-*`).

Do not add these frameworks or dependencies merely because a curated skill exists.

## Final Handoff Template

Use this compact handoff after Salesforce work:

```text
Scope:
- Requested:
- Implemented:
- Not done because approval is required:

Files and metadata:
-

Standards applied:
- Client override:
- [Org]:
- Salesforce skill used (sf-{cloud}-{name}):
- PMD/static analysis:

Checks:
-

Risks or follow-up:
-
```
