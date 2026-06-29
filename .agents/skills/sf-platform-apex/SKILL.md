---
name: sf-platform-apex
description: "Primary Apex authoring skill for class generation, refactoring, and review. ALWAYS ACTIVATE when the user mentions Apex, .cls, triggers, or asks to create/refactor a class (service, selector, domain, batch, queueable, schedulable, invocable, DTO, utility, interface, abstract, exception, REST resource). Use this skill for requests involving SObject CRUD, mapping collections, fetching related records, scheduled jobs, batch jobs, trigger design, @AuraEnabled controllers, @RestResource endpoints, custom REST APIs, or code review of existing Apex."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-apex-generate
    - Clientell-Ai/salesforce-skills :: sf-apex
    - DietrichGebert/ponytail (refactored via LEAN_CODE_STANDARDS.md)
    - JuliusBrussee/caveman (refactored via LEAN_CODE_STANDARDS.md)
---

# sf-platform-apex: Apex Development

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-apex` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-apex-generate; Clientell-Ai/salesforce-skills :: sf-apex; lean-coding discipline refactored from DietrichGebert/ponytail and JuliusBrussee/caveman |

Before authoring, apply the [Lean Decision Ladder](../../standards/LEAN_CODE_STANDARDS.md#the-lean-decision-ladder-apexlwc-refactor-of-ponytail): prefer declarative Salesforce features, existing Selectors/Services/Utilities, and Apex standard-library calls over new Apex, and write the smallest correct class once the requirement and existing layering are understood. Lean does not relax bulkification, CRUD/FLS, or sharing requirements — see "Not Lazy About" in that file.

The first time in a session you touch a given class, retrieve it from the dev org first per [Pre-Development Retrieve](../../workflows/DEPLOYMENT.md#pre-development-retrieve-mandatory) — do not generate or edit on top of a local copy that may be stale relative to the org.

Use this skill for production-grade Apex: new classes, selectors, services, async jobs,
invocable methods, and triggers; and for evidence-based review of existing `.cls` OR `.trigger`.

## Required Inputs

Gather or infer before authoring:

- Class type (service, selector, domain, batch, queueable, schedulable, invocable, trigger, trigger action, DTO, utility, interface, abstract, exception, REST resource)
- Target object(s) and business goal
- Class name (derive using the naming table below)
- Net-new vs refactor/fix; any org/API constraints
- Deployment targets (default to runSpecifiedTests and use generated tests where applicable)

Defaults unless specified:
- Sharing: `with sharing` (see sharing rules per type below)
- Access: `public` (use `global` only when required by managed packages or `@RestResource`)
- API version: `66.0` (minimum version)
- ApexDoc comments: yes

If the user provides a clear, complete request, generate immediately without unnecessary back-and-forth.

---

## Workflow

All steps are sequential. Do not skip, merge, or reorder. If blocked, stop and ask for missing context. If not applicable, mark `N/A` with a one-line justification in the report.

### Phase 1 — Author

1. **Discover project conventions**
   - Service-Selector-Domain layering, logging utilities
   - Existing classes/triggers and current trigger framework or handler pattern
   - Whether Trigger Actions Framework (TAF) is already in use

2. **Choose the smallest correct pattern** (see Type-Specific Guidance below)

3. **Review templates and assets**
   - Read the matching template from `assets/` before authoring (see Type-Specific Guidance for the file mapping)
   - When a `references/` example exists for the type, read it as a concrete style guide
   - For any test class work, always read and use `platform-apex-test-generate` skill

4. **Author with guardrails** -- apply every rule in the Rules section below
   - Generate `{ClassName}.cls` with ApexDoc
   - Generate `{ClassName}.cls-meta.xml`   

5. **Generate test classes** -- Load the skill `platform-apex-test-generate` to create `{ClassName}Test.cls` and `{ClassName}Test.cls-meta.xml`.  Apex tests are always required to be generated to deploy. No test file creation or edits can occur without loading the  `platform-apex-test-generate` skill to generate tests.

### Phase 2 — Validate (required before reporting)

Writing files is the midpoint, not the finish line. Steps 6 and 7 each require a tool invocation and produce output that must appear in the Step 8 report. Do not summarize or present the report until both steps have run and their output is captured.

6. **Run code analyzer**
   - Invoke MCP `run_code_analyzer` on all generated/updated `.cls` files.
   - Remediate all `sev0`, `sev1`, and `sev2` violations; re-run until clean.
   - Capture the final tool output verbatim for the report.
   - Fallback: `sf code-analyzer run --target <target>`. If both are unavailable, record `run_code_analyzer=unavailable: <error>` in the report.

7. **Execute Apex tests**
   - Run org tests including `{ClassName}Test` via `sf apex run test` or MCP.
   - Delegate all test generation/fixes/coverage work to `platform-apex-test-generate`; iterate until the tests pass.
   - Capture pass/fail counts and coverage percentage for the report.
   - If unavailable, record `test_execution=unavailable: <error>` in the report.

### Phase 3 — Report

8. **Report** -- use the output format at the bottom of this file.
   - The `Analyzer` line must contain the actual Step 6 tool output (or `run_code_analyzer=unavailable: <reason>` after attempting invocation).
   - The `Testing` line must contain the actual Step 7 results (or `test_execution=unavailable: <reason>` after attempting invocation).
   - A report missing either line is incomplete. Always attempt the tool invocation before recording unavailable.

---

## Rules

### Hard-Stop Constraints (Must Enforce)

If any constraint would be violated in generated code, **stop and explain the problem** before proceeding:

| Constraint | Rationale |
|---|---|
| Place all SOQL outside loops | Avoid query governor limits (100 queries) |
| Place all DML outside loops | Avoid DML governor limits (150 statements) |
| Declare a sharing keyword on every class | Prevent unintended `without sharing` defaults and data exposure |
| Use Custom Metadata/Labels/describe calls instead of hardcoded IDs | Ensure portability across orgs |
| Always handle exceptions (log, rethrow, or recover) | Prevent silent failures |
| Use bind variables for all dynamic SOQL with user input | Prevent SOQL injection |
| Use Apex-native collections (`List`, `Map`, `Set`) rather than Java types | Prevent compile errors |
| Verify methods exist in Apex before use | Prevent reliance on non-existent APIs |
| Avoid `System.debug()` in main code paths | Debug statements evaluate even when loggign is not active and consume CPU. Use a logging framework if required on main code paths |
| Never use `@future` methods | Use Queueable with `System.Finalizer`; `@future` cannot chain, cannot be called from Batch, and cannot accept non-primitive types |

### Bulkification & Governor Limits

- All public APIs accept and process collections; single-record overloads delegate to the bulk method
- In batch/bulk flows, prefer partial-success DML (`Database.update(records, false)`) and process `SaveResult` for errors
- Use `Map<Id, SObject>` constructor for efficient ID-based lookups from query results
- Use `Map<Id, List<SObject>>` to group child records by parent; build the map in a single loop before processing
- Use `Set<Id>` for deduplication and membership checks; prefer `Set.contains()` over `List.contains()`
- Use relationship subqueries to fetch parent + child records in a single SOQL when both are needed
- Use `AggregateResult` with `GROUP BY` for rollup calculations instead of querying and counting in Apex
- Only DML records that actually changed — compare against `Trigger.oldMap` or prior state before adding to the update list
- Use `Limits.getQueries()`, `Limits.getDmlStatements()`, `Limits.getCpuTime()` to monitor consumption in complex transactions

### SOQL Optimization

- Use selective queries with proper `WHERE` clauses; use indexed fields (`Id`, `Name`, `OwnerId`, lookup/master-detail fields, `ExternalId` fields, custom indexes) in filters when possible
- `SELECT *` does not exist in SOQL -- always specify the exact fields needed
- Apply `LIMIT` clauses to bound result sets; use `ORDER BY` for deterministic results
- When querying Custom Metadata Types (objects ending with `__mdt`), do NOT use SOQL — use the built-in methods (`{CustomMdt__mdt}.getAll().values()`, `getInstance()`, etc.)

### Caching

- Use Platform Cache (`Cache.Org` / `Cache.Session`) for frequently accessed, rarely changed data; set a TTL and always handle cache misses — cache can be evicted at any time
- Use `private static Map` fields as transaction-scoped caches to prevent duplicate queries within the same execution context; lazy-initialize on first access

### Security

- Default to `with sharing`; document justification for `without sharing` or `inherited sharing`
- `WITH USER_MODE` in SOQL and `AccessLevel.USER_MODE` for `Database` DML for CRUD/FLS enforcement
- Validate dynamic field/operator names via allowlist or `Schema.describe`
- Named Credentials for all external credentials/API keys
- `AuraHandledException` for `@AuraEnabled` user-facing errors (no internal details)
- `without sharing` requires a Custom Permission check
- Isolate `without sharing` logic in dedicated helper classes; call from `with sharing` entry points to limit elevated-access scope
- Encrypt PII/sensitive data at rest via Platform Encryption; never expose PII in debug statements, error messages, or API responses

### Security Verification

Before finalizing, verify: CRUD/FLS enforced (SOQL + DML) · explicit sharing keyword on every class · no hardcoded secrets or Record IDs · PII excluded from logs and error messages · error messages sanitized for end users.

### Error Handling

- Catch specific exceptions before generic `Exception`; include context in messages
- Use `try/catch` only around code that can throw (DML, callouts, JSON parsing, casts); avoid defensive wrapping of simple assignments/collection ops/arithmetic
- Preserve exception cause chains: `new CustomException('message', cause)` (do not replace stack trace with concatenated messages)
- Provide a custom exception class per service domain when meaningful
- In `@AuraEnabled` methods, catch exceptions and rethrow as `AuraHandledException`
- Fallback option: when no meaningful domain exception exists, catch generic `Exception` and either rethrow it or wrap it in a minimal custom exception that preserves the original cause.


### Null Safety

- Add guard clauses for null/empty inputs at the top of every public method; match style to context: `return` early in private/trigger-handler methods, `throw` exceptions in public APIs, `record.addError()` in validation services
- Return empty collections instead of `null`
- Use safe navigation (`?.`) for chained property access
- Never dereference `map.get(key)` inline unless presence is guaranteed; use `containsKey`, assignment+null check, or safe navigation first
- Use null coalescing (`??`) for default values
- Prefer `String.isBlank(value)` over manual checks like `value == null || value.trim().isEmpty()`

### Constants & Literals

- Mandatory pattern for repeated picklist values, API names, and other literals: see [APEX_CONSTANTS_FRAMEWORK.md](../../standards/APEX_CONSTANTS_FRAMEWORK.md) — `{SObject}Constants` singleton classes exposed via `Constants.{OBJECT}`. Use the full word `Constants`, never abbreviate to `Consts`. Template: `assets/Constants.cls` and `assets/concrete-constants/AccountConstants.cls`.
- Use enums over string constants for purely internal/code-level states with no SObject field correspondence; enum values follow `UPPER_SNAKE_CASE`
- Use `Label.` custom labels for user-facing strings
- Use Custom Metadata for configurable values (thresholds, mappings, feature flags)
- Never output HTML-escaped entities in code (e.g., `&#39;`); use literal single quotes `'` in Apex string literals

### Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Service | `{SObject}Service` | `AccountService` |
| Selector | `{SObject}Selector` | `AccountSelector` |
| Domain | `{SObject}Domain` | `OpportunityDomain` |
| Batch | `{Descriptive}Batch` | `AccountDeduplicationBatch` |
| Queueable | `{Descriptive}Queueable` | `ExternalSyncQueueable` |
| Schedulable | `{Descriptive}Schedulable` | `DailyCleanupSchedulable` |
| DTO | `{Descriptive}DTO` | `AccountMergeRequestDTO` |
| Wrapper | `{Descriptive}Wrapper` | `OpportunityLineWrapper` |
| Utility | `{Descriptive}Util` | `StringUtil` |
| Interface | `I{Descriptive}` | `INotificationService` |
| Abstract | `Abstract{Descriptive}` | `AbstractIntegrationService` |
| Exception | `{Descriptive}Exception` | `AccountServiceException` |
| REST Resource | `{SObject}RestResource` | `AccountRestResource` |
| Trigger | `{SObject}Trigger` | `AccountTrigger` |
| Trigger Action | `TA_{SObject}_{Action}` | `TA_Account_SetDefaults` |

Additional naming rules:
- Classes: `PascalCase`
- Methods: `camelCase`, start with a verb (`get`, `create`, `process`, `validate`, `is`, `has`, `can`)
- Variables: `camelCase`, descriptive nouns; Lists as plural nouns (e.g., `accounts`, `relatedContacts`); Maps as `{value}By{key}` (e.g., `accountsById`); Sets as `{noun}Ids`
- Constants: `UPPER_SNAKE_CASE`
- Use full descriptive names instead of abbreviations (`acc`, `tks`, `rec`)

### ApexDoc

Required on **every** class/interface/trigger header and **every** method (not just `public`/`global`), in the exact tag set and alignment below — see [SALESFORCE_APEX_STANDARDS.md](../../standards/SALESFORCE_APEX_STANDARDS.md#apexdoc-comment-block-mandatory) for the full rules. Before generating the first header in a session, confirm an author name/email is configured in [ENVIRONMENT.md](../../project/ENVIRONMENT.md#author-identity) — if not, ask the user; never write an AI/tool name as the author.

Class-level format:

```apex
/**
 * @description       : {What this class does and why.}
 * @author            : {author_name} <{author_email}>
 * @group             : {Logical grouping, e.g. UTILS}
 * @last modified on  : {DD-MM-YYYY}
 * @last modified by  : {author_name} <{author_email}>
 * @test              : {RelatedTestClassName}
 **/
public with sharing class GeolocationService { }
```

Method-level format:

```apex
/**
 * @description {What this method does and why, if non-obvious.}
 * @author      {author_name}
 * @param       address The street address to geocode.
 * @return      The resolved Geolocation, or null if the address could not be resolved.
 */
```

### Code Structure & Architecture

- Single responsibility per class; max 500 lines -- split when exceeded
- Return Early: validate preconditions at method top, return/throw immediately
- Extract private helpers for methods over ~40 lines
- Use Dependency Injection (constructor/method params) for testability
- Prefer composition and narrow interfaces over deep inheritance; extend via new implementations, not modifications
- Enforce single-level abstraction per method across layer boundaries:

| Layer | Owns | Must NOT contain |
|---|---|---|
| Trigger | Event routing only | Business logic, orchestration |
| Handler/Service | Flow control, coordination | Inline SOQL/DML/HTTP/parsing |
| Domain | Business rules, validation | Queries, callouts, persistence details |
| Data/Integration | SOQL, DML, HTTP | Business decisions |

- Disallowed: methods mixing orchestration with inline SOQL/DML/HTTP; business rules mixed with parsing internals; validation + persistence + cross-system plumbing in one method

---

## Async Decision Matrix

| Scenario | Default | Key Traits |
|---|---|---|
| Standard async work | **Queueable** | Job ID, chaining, non-primitive types, configurable delay (up to 10 min via `AsyncOptions`), dedup signatures |
| Very large datasets | **Batch Apex** | Chunked processing, max 5 concurrent; use `QueryLocator` for large scopes |
| Modern batch alternative | **CursorStep** (`Database.Cursor`) | 2000-record chunks, higher throughput, no 5-job limit |
| Recurring schedule | **Scheduled Flow** (preferred) or **Schedulable** | Schedulable has 100-job limit; use only when chaining to Batch or needing complex Apex logic |
| Post-job cleanup | **Finalizer** (`System.Finalizer`) | Runs regardless of Queueable success/failure |
| Long-running callouts | **Continuation** | Up to 3 per transaction, 3 parallel |
| Delays > 10 minutes | `System.scheduleBatch()` | Schedule a Batch job at a specific future time |
| Legacy fire-and-forget | `@future` | **Do not use in new code** — see Hard-Stop Constraints; replace with Queueable + Finalizer |

---

## Type-Specific Guidance

### Service
- Template: `assets/service.cls` · Reference: `references/AccountService.cls`
- `with sharing`; stateless — no `public` fields or mutable instance state; keep public APIs focused and `static` where reasonable
- Delegate all SOQL to Selectors and SObject behavior to Domains
- Wrap business errors in a custom exception (e.g., `AccountServiceException`)

### Selector
- Template: `assets/selector.cls` · Reference: `references/AccountSelector.cls`
- `inherited sharing`; one per SObject or query domain
- Return `List<SObject>` or `Map<Id, SObject>`; use a shared base field list constant (no inline duplication)
- Accept filter parameters; always include `WITH USER_MODE`

### Domain
- Template: `assets/domain.cls`
- `with sharing`; encapsulate field defaults, derivations, and validations
- Operate on in-memory lists only; no SOQL/DML (belongs in Services/Selectors)

### Batch
- Template: `assets/batch.cls` · Reference: `references/AccountDeduplicationBatch.cls`
- `with sharing`; implement `Database.Batchable<SObject>` (add `Database.Stateful` when tracking across chunks)
- `start()` = query definition; `execute()` = business logic; `finish()` = logging/notification
- Use `QueryLocator` for large datasets; handle partial failures via `Database.SaveResult`
- Accept filter parameters via constructor for reusability

### Queueable
- Template: `assets/queueable.cls`
- `with sharing`; implement `Queueable` and optionally `Database.AllowsCallouts` when HTTP callouts are needed
- Accept data via constructor
- Add chain-depth guards to prevent infinite chains
- Optionally implement `Finalizer` for recovery/cleanup
- Use `AsyncOptions` for configurable delay (up to 10 min) and dedup signatures

### Schedulable
- Template: `assets/schedulable.cls`
- `with sharing`; `execute()` delegates to Queueable or Batch
- Provide CRON constants and a convenience `scheduleDaily()` helper

### DTO / Wrapper
- Template: `assets/dto.cls`
- No sharing keyword needed (pure data containers)
- Simple public properties; no-arg + parameterized constructors; `Comparable` when ordering matters
- Use `@JsonAccess` on private/protected inner DTOs that are serialized/deserialized

### Utility
- Template: `assets/utility.cls`
- No sharing keyword needed; all methods `public static`; `private` constructor
- Pure, side-effect-free; no SOQL/DML

### Interface
- Template: `assets/interface.cls`
- Define clear contracts with ApexDoc on each method signature

### Abstract
- Template: `assets/abstract.cls`
- `with sharing`; offer default behavior via `virtual` methods
- Mark extension points `protected virtual` or `protected abstract`
- Include a concrete example in the ApexDoc showing how to extend the class

### Custom Exception
- Template: `assets/exception.cls`
- No sharing keyword; extend `Exception` with descriptive names
- Supported constructors: `()`, `('msg')`, `(cause)`, `('msg', cause)`

### Trigger
- Mandatory pattern: see [APEX_TRIGGER_FRAMEWORK.md](../../standards/APEX_TRIGGER_FRAMEWORK.md). Template: `assets/trigger.cls`; base class: `assets/TriggerHandler.cls` (deploy once per org/package).
- One trigger per object, zero logic in the trigger body; handler class named `{SObject}TriggerHandler extends TriggerHandler`, overriding only the context methods it needs
- Use `setMaxLoopCount`/the bypass API from `TriggerHandler` for recursion control — do not hand-roll static recursion-guard booleans

### Trigger Action (TAF) — Legacy Only
- Use only if `Trigger_Action__mdt`-based actions are already deployed and in active use in this org; do not introduce TAF net-new now that `TriggerHandler` is the mandatory pattern
- One class per concern per context; implement `TriggerAction.{Context}`
- Register via `Trigger_Action__mdt` (actions are inactive without registration)
- Name: `TA_{SObject}_{ActionName}`; prefer field-value comparison over static booleans for recursion

### Invocable Method (`@InvocableMethod`)
- Template: `assets/invocable.cls`
- `with sharing`; inner `Request`/`Response` with `@InvocableVariable`
- Method must be `public static`; non-static or single-object signatures will not compile
- Accept `List<Request>`, return `List<Response>`; bulkify (SOQL/DML outside loops)
- Decorator parameters: `label` (required — Flow Builder display name), `description`, `category` (groups actions in Builder), `callout=true` (required when method makes HTTP callouts)
- `@InvocableVariable` parameters: `label` (required), `description`, `required=true/false`
- `@InvocableVariable` supports: primitives, `Id`, `SObject`, `List<T>` only (no `Map`/`Set`/`Blob`); use `List<Id>` or `List<SObject>` fields for Flow collection I/O
- Always include `isSuccess`, `errorMessage`, and `errorType` (`e.getTypeName()`) in Response
- Return errors in Response (recommended); throwing an exception triggers the Flow Fault path — reserve for unrecoverable failures only

### REST Resource (`@RestResource`)
- Template: `assets/rest-resource.cls`
- `global with sharing`; both class and methods must be `global`
- Versioned URL: `@RestResource(urlMapping='/{resource}/v1/*')`
- Use proper HTTP status codes per branch (`200`/`201`/`400`/`404`/`422`/`500`); never default all errors to `500`
- Validate inputs (Id format: `Pattern.matches('[a-zA-Z0-9]{15,18}', value)`); bind all user input in SOQL
- Include `LIMIT`/`ORDER BY` in queries; implement pagination (`pageSize`/`offset`)
- Standardized `ApiResponse` wrapper (`success`, `message`, `data`/`records`); inner request/response DTOs
- Thin controller: delegate business logic to Service classes

### `@AuraEnabled` Controller
- `with sharing`; use `WITH USER_MODE` in all SOQL
- Use `@AuraEnabled(cacheable=true)` only for read-only queries; leave `cacheable` unset for DML operations
- Catch exceptions and rethrow as `AuraHandledException` with user-friendly messages

---

## Output Expectations

Deliverables per class:
- `{ClassName}.cls`
- `{ClassName}.cls-meta.xml` (default API version `66.0` or higher unless specified)
- `{ClassName}Test.cls` (generated via `platform-apex-test-generate` skill)
- `{ClassName}Test.cls-meta.xml` (generated via `platform-apex-test-generate` skill)

Deliverables per trigger:
- `{TriggerName}.trigger`
- `{TriggerName}.trigger-meta.xml` (default API version `66.0` or higher unless specified)

Meta XML template:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>{API_VERSION}</apiVersion>
    <status>Active</status>
</ApexClass>
```

Report in this order:

```text
Apex work: <summary>
Files: <paths>
Design: <pattern / framework choices>
Workflow: all steps completed (1-8); any N/A justified
Risks: <security, bulkification, async, dependency notes>
Analyzer: <REQUIRED -- paste actual run_code_analyzer output or state "run_code_analyzer=unavailable: <reason>">
Testing: <REQUIRED -- paste actual test execution results (pass/fail, coverage) or state "test_execution=unavailable: <reason>">
Deploy: <dry-run or next step>
```

---

## Cross-Skill Integration

| Need | Delegate to |
|---|---|
| Apex tests / fix failures | `platform-apex-test-generate` skill |
| Describe objects/fields | metadata skill (if available) |
| Deploy to org | deploy skill (if available) |
| Flow calling Apex | Flow skill (if available) |
| LWC calling Apex | LWC skill (if available) |

---

## Troubleshooting Boundary

This skill handles production `.cls`/`.trigger`/`.apex` issues only: compile/parse failures, deployment dependency errors, runtime governor-limit failures. For test execution, assertions, coverage, or `sf apex run test` failures, delegate to `platform-apex-test-generate`.

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `sf-apex` (Clientell-Ai/salesforce-skills :: sf-apex)

# Apex Code Generator & Reviewer

You are a Salesforce Apex specialist. Generate production-ready Apex code following all Salesforce best practices.

## Code Generation Rules

### Governor Limits Awareness
- NEVER put SOQL queries inside loops — bulkify by querying before the loop
- NEVER put DML statements inside loops — collect records in a List, then perform DML once
- Use `Limits.getQueries()` and `Limits.getLimitQueries()` for monitoring
- Prefer `Database.query()` with bind variables over hardcoded SOQL strings
- Use `System.Queueable` or `Database.Batchable` for large data operations

### Security (CRUD/FLS)
- Always use `WITH USER_MODE` in SOQL queries
- Use `Security.stripInaccessible(AccessType.READABLE, records)` before returning data
- Use `Security.stripInaccessible(AccessType.CREATABLE, records)` before insert
- Use `Security.stripInaccessible(AccessType.UPDATABLE, records)` before update
- Always declare classes with `with sharing` unless there's an explicit reason not to
- NEVER use string concatenation for dynamic SOQL — use bind variables

### Bulkification Patterns
- All code must handle 200+ records per transaction (trigger batch size)
- Use `Map<Id, SObject>` for efficient lookups
- Use `Set<Id>` to collect unique IDs before querying related records
- Use `Trigger.newMap` and `Trigger.oldMap` for efficient field change detection

### Trigger Pattern
- One trigger per object, maximum
- Trigger contains NO logic — delegates to a handler class
- Handler class implements the logic with proper bulkification
- `TriggerHandler` below is the vendored base class at `assets/TriggerHandler.cls` — see [APEX_TRIGGER_FRAMEWORK.md](../../standards/APEX_TRIGGER_FRAMEWORK.md), not a project-local class to redefine

```apex
// Trigger
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    handler.run();
}

// Handler
public with sharing class AccountTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        // logic here
    }
}
```

### Naming Conventions
- Classes: `PascalCase` (e.g., `AccountService`, `OpportunityTriggerHandler`)
- Methods: `camelCase` (e.g., `getAccountsByIds`, `calculateDiscount`)
- Variables: `camelCase` (e.g., `accountList`, `totalAmount`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE`)
- Test classes: `ClassNameTest` (e.g., `AccountServiceTest`)

### Code Structure
- Service classes for business logic (`AccountService`)
- Selector classes for queries (`AccountSelector`)
- Domain classes for record manipulation (`Accounts`)
- Trigger handlers for trigger logic (`AccountTriggerHandler`)

### Async Apex Decision Table

| Feature | @future | Queueable | Batch | Schedulable |
|---------|---------|-----------|-------|-------------|
| Callouts | `callout=true` | `Database.AllowsCallouts` | `Database.AllowsCallouts` | No (delegate) |
| Chaining | No | Yes (1 child in test) | No (use Schedulable) | Can launch Batch |
| Return values | No (void only) | No | No | No |
| Parameters | Primitives only | Any (serializable) | N/A (query in start) | N/A |
| State | No | No (unless member vars) | `Database.Stateful` | No |
| Max records | N/A | N/A | 50M (QueryLocator) | N/A |
| Use when | Simple async, callouts | Complex async, chaining | Large data processing | Recurring/scheduled |

### Exception Handling
- Create custom exceptions extending `Exception` for domain-specific errors
- Parse `Database.SaveResult` for partial DML: `Database.insert(records, false)`
- Always use `try/catch` around callouts — never let `CalloutException` propagate unhandled

### Invocable Methods (Flow Integration)
```apex
public with sharing class AccountActions {
    @InvocableMethod(label='Merge Accounts' description='Merges duplicate accounts')
    public static List<Result> mergeAccounts(List<Request> requests) {
        // Process requests (always bulkified — Flow sends List)
    }

    public class Request {
        @InvocableVariable(required=true) public Id masterId;
        @InvocableVariable(required=true) public List<Id> duplicateIds;
    }

    public class Result {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String errorMessage;
    }
}
```

### Custom Metadata vs Custom Settings
- **Custom Metadata Types**: Deployable, cached, accessed via SOQL or `getInstance()`. Use for org-wide configuration.
- **Custom Settings (Hierarchy)**: Data-based (not deployable), supports user/profile overrides, accessed without SOQL. Use for user-specific settings.
- CMT counts against SOQL limits when queried; Custom Settings do not.

### Dynamic Apex
- Use `JSON.serialize()` / `JSON.deserialize()` for API responses and flexible data structures
- Use `Type.forName('ClassName')` for dynamic class instantiation (factory pattern)
- Use `Schema.getGlobalDescribe()` sparingly — it's expensive. Cache results.

## Gotchas
- DML inside Continuation methods fails silently
- `@future` methods are void-only — cannot return values
- Queueable chaining limited to depth 1 in test context
- Platform Events have at-least-once delivery (not exactly-once) — design for idempotency
- Max 20 child relationship subqueries per SOQL query
- `Database.Stateful` in Batch reserializes state between execute() calls — keep state small
- Custom Metadata `getInstance()` is cached — changes don't reflect until cache clears
- `@future` cannot call another `@future` — use Queueable for chaining

## Review Checklist
When reviewing existing Apex code, check for:
1. SOQL/DML inside loops
2. Missing `with sharing`
3. Missing CRUD/FLS checks
4. Hardcoded IDs
5. Missing null checks
6. Non-bulkified code
7. Missing error handling for DML operations
8. Debug statements that expose PII
9. String concatenation in dynamic SOQL (injection risk)
10. CPU-intensive operations without limits checks

## Workflow
1. Read existing code context using Glob and Read tools
2. Understand the org's object model from metadata if available
3. Generate code following all rules above
4. Include inline comments only where logic is non-obvious
5. Suggest deployment command: `sf project deploy start -d force-app/main/default/classes/`

## References
- [Apex Design Patterns](references/apex-patterns.md) — trigger handlers, service layer, selector, batch, queueable, custom exceptions, JSON, dynamic Apex, custom metadata, managed sharing, iterators
- [Async Patterns](references/async-patterns.md) — @future, Queueable, Batch, Schedulable, Continuation, Platform Events, Change Data Capture
- [Integration Patterns](references/integration-patterns.md) — REST callouts, Named Credentials, @RestResource, SOAP, WebServiceMock, System.Callable, Composite API
- [Governor Limits](../../references/governor-limits.md) — per-transaction SOQL, DML, CPU, heap limits
