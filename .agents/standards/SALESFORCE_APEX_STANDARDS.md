# Salesforce Apex Standards

## Purpose And Use

This file defines quality standards for Apex classes, triggers, async jobs, tests, and related metadata. Read it before generating, reviewing, refactoring, or validating Apex. Put Apex-specific security, layering, SOQL/DML, async, error-handling, testing, and review standards here.

These standards apply to Apex classes, triggers, tests, and related Salesforce metadata.

These standards inherit the [Org] Salesforce best-practice baseline unless the client has an explicit project-specific convention. See [Salesforce project best practices](SALESFORCE_PROJECT_BEST_PRACTICES.md).

Salesforce curated skills may provide implementation patterns, but generated or modified Apex must still satisfy this file and the local PMD ruleset.

## Core Principles

- Bulkify all logic. Code must work for one record and many records.
- Keep triggers thin. Put behavior in handler, service, selector, or domain classes.
- Follow the project Apex layering pattern where present: Service Manager, Entity Manager, Data Manager, trigger handler, and dedicated test class.
- Make sharing mode explicit on every class.
- Enforce CRUD and FLS for user-facing operations.
- Avoid hardcoded IDs, profile names, record type IDs, URLs, and org-specific values.
- Prefer metadata-driven allowlists over stringly typed business rules.
- Keep methods small enough to test and review.
- Prefer clear names over comments that restate the code.

## Trigger Rules

- One trigger per object when possible.
- No business logic directly in triggers.
- No SOQL, SOSL, DML, callouts, or complex branching directly in triggers.
- Use context-specific handler methods such as `beforeInsert`, `beforeUpdate`, `afterInsert`, and `afterUpdate`.
- Prevent recursion intentionally; do not rely on static booleans without documenting the transaction behavior.
- Use a shared `TriggerHandler` base class when the project has one.
- Use an object-specific handler class such as `TH_ObjectName` when that is the project convention.
- Test triggers through insert, update, delete, and undelete events rather than testing only handler methods.

## Layering Rules

When the project follows the SM/EM/DM pattern:

- `SMXXX_ServiceName` classes contain business logic and must not contain SOQL or callouts.
- `EMXXX_ObjectName` classes prepare object data and manipulation rules and must not contain SOQL or callouts.
- `DMXXX_ObjectName` classes contain SOQL, DML, callouts, and database access.
- Data Managers should focus on one object.
- Matching EM and DM classes should use the same numeric identifier when the convention is already present.
- Do not introduce a parallel architecture if the repo already has a clear handler, service, selector, or domain pattern.

## SOQL and DML Rules

- No SOQL, SOSL, or DML inside loops.
- No callouts or `@future` work inside loops.
- Query only fields that are needed.
- Filter large-object queries.
- Use maps and sets for joins.
- Handle empty collections safely.
- Prefer partial-success DML only when the caller has a clear error handling path.
- Do not swallow DML exceptions.

## Security Rules

- Use bind variables in SOQL.
- Allowlist dynamic object and field names.
- Use `Security.stripInaccessible` where returned or persisted SObject fields may exceed user access.
- Consider `WITH SECURITY_ENFORCED` for simple read paths.
- Escape or encode values used in UI-facing errors.
- Avoid `without sharing` unless the business reason is explicit and tested.

## Apex Entry Point Method Pattern

Apex entry points must not assume that callers have already filtered or sanitized input. This applies to invocable methods, trigger handlers, async `execute` methods, controllers, exposed service methods, and any method called directly by Flow or automation.

Design entry points in three clear tiers:

- Input parameter validation and cleaning:
  - Validate that inputs are not null or empty before processing.
  - Validate required values, Id formats, expected sObject types, and supported record type developer names where applicable.
  - Query required records and fields inside Apex instead of trusting caller-provided field values.
  - Normalize or clean values needed by the business logic before mutation.
  - Separate invalid, unsupported, incomplete, or ambiguous records from eligible records without mutating them.
- Execution of logic:
  - Execute business logic only against validated inputs.
  - Keep execution bulk-safe, deterministic, and scoped to the eligible records.
  - Mutate only records that match the validated business pattern.
- Error, exception, and logging handling:
  - Wrap top-level entry points with controlled error handling.
  - Convert expected validation failures into skipped or failed result states instead of unhandled exceptions.
  - Return or log meaningful per-record outcomes where practical.
  - Avoid allowing one invalid record to fail a whole batch unless the failure is an unrecoverable configuration or platform issue.
  - Preserve useful diagnostic detail in safe logs without leaking secrets or sensitive customer data.

## Error Handling

- Do not use empty catch blocks.
- Do not convert all exceptions into generic success responses.
- Use custom exceptions where they make caller behavior clearer.
- Surface safe, actionable user messages.
- Preserve diagnostic detail in safe internal logs without leaking secrets or customer data.

## Async Rules

- Prefer Queueable over `@future` for new async work.
- Use Batch Apex for large data volumes.
- Design async jobs to be idempotent where possible.
- Avoid chaining without a clear limit.
- Do not enqueue jobs from loops without limits.

## Test Rules

- Every Apex behavior change must include or update tests unless the user explicitly scoped the task away from tests.
- Tests must include assertions.
- Avoid `SeeAllData=true`.
- Use `System.runAs` when permissions, sharing, or user context matters.
- Cover positive, negative, empty, and bulk cases.
- Use `@TestSetup` and test data factories when they reduce duplication.
- Use more than 200 records for trigger bulk tests when feasible.
- Use `Test.startTest()` and `Test.stopTest()` around the behavior being verified.
- Use record type developer names instead of record type labels.
- Use `ORDER BY` when asserting ordered query results.
- Keep the first assert parameter as expected and the second as actual.
- Test security behavior where CRUD/FLS/sharing is part of the requirement.
- Keep test data local to the test unless using an approved test factory.

## Review Checklist

Before considering Apex ready:

- PMD has no unreviewed high-priority issues.
- Tests cover the changed behavior.
- No SOQL or DML is inside loops.
- Sharing mode is explicit.
- CRUD/FLS posture is deliberate.
- No hardcoded org-specific IDs or secrets exist.
- Logs do not expose sensitive data.
- Deployment scope and test class scope are known.
