---
name: sf-platform-test
description: "Generate and validate Apex test classes with TestDataFactory patterns, bulk testing (251+ records), mocking strategies, assertion best practices, and disciplined test-fix loops. Use this skill when creating new Apex test classes, improving test coverage, debugging and fixing failing Apex tests, running test execution and coverage analysis, or implementing testing patterns for triggers, services, controllers, batch jobs, queueables, and integrations. Triggers on *Test.cls, *_Test.cls files, sf apex run test workflows, coverage reports, test-fix loops. Do NOT trigger for production Apex code (use sf-platform-apex) or Jest/LWC tests."
metadata:
  version: "1.1"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-apex-test-generate
    - forcedotcom/sf-skills :: platform-apex-test-run
    - Clientell-Ai/salesforce-skills :: sf-test
---

# sf-platform-test: Apex Testing

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-test` |
| Cloud | Platform |
| Version | 1.1 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-apex-test-generate; forcedotcom/sf-skills :: platform-apex-test-run; Clientell-Ai/salesforce-skills :: sf-test |

Generate production-ready Apex test classes and run disciplined test-fix loops with coverage analysis.

Coverage analysis run as part of a deploy (dry-run, validate, or real) must satisfy the 95% mandatory coverage gate in [DEPLOYMENT.md](../../workflows/DEPLOYMENT.md), not just the org-wide default minimum — treat a result below 95% for any class/trigger in deploy scope as a failure to fix, not a passing result to report.

Use [agentic-qa](../agentic-qa/SKILL.md) when the task needs full-ticket QA beyond Apex unit tests: scenario matrices, manual/browser smoke checks, regression coverage, canary/health checks, benchmark evidence, or report-only QA. `sf-platform-test` owns Apex test authoring/execution; `agentic-qa` owns the broader verification story.

## Core Principles

1. **One behavior per method** — each test method validates a single scenario. Separate positive, negative, and bulk tests. NEVER combine related-but-distinct inputs (e.g., null and empty) in one method — create `_NullInput_` and `_EmptyInput_` as separate test methods
2. **Bulkify tests** — use 251+ records where appropriate to cross the 200-record trigger batch boundary; do not multiply expensive external-user personas without a requirement. **Batch Apex exception:** in test context only one `execute()` invocation runs, so set `batchSize >= testRecordCount`. See [references/async-testing.md](references/async-testing.md)
3. **Isolate test data** — reuse approved project factories; delegate shared setup to project-owned flows. For new reusable fixtures, use the [Test Data Framework](references/test-data-factory.md): generic registry/core, stateless object helpers, typed project flows. `build/buildMany` perform no DML; `create/createMany` persist explicitly. Never rely on existing business data (`SeeAllData=false`), hardcoded IDs, static setup caches, or silent duplicate-rule bypasses.
4. **Assert meaningfully** — use exact expected values computed from test data setup. NEVER use range assertions or approximate counts when the value is deterministic. Always include failure messages. See [references/assertion-patterns.md](references/assertion-patterns.md)
5. **Use `Assert` class only** — `Assert.areEqual`, `Assert.isTrue`, `Assert.fail`, etc. Never use legacy `System.assert`, `System.assertEquals`, or `System.assertNotEquals`
6. **Mock external boundaries** — use `HttpCalloutMock` for callouts, `Test.setFixedSearchResults` for SOSL, DML mock classes for database isolation. Design for testability via constructor injection. See [references/mocking-patterns.md](references/mocking-patterns.md)
7. **Test negative paths** — validate error handling and exception scenarios, not just happy paths
8. **Wrap with start/stop** — pair `Test.startTest()` with `Test.stopTest()` to reset governor limits and force async execution

## Test Class Generation Rules

When generating or rewriting Apex test classes, apply these rules in addition to the core principles:

- Add a class-level ApexDoc header comment that names the production Apex class(es), trigger handler(s), controller(s), batch class(es), or Flow entry-point function(s) covered by the test class. Keep the coverage mapping explicit so a reviewer can see what behavior the class protects. Where possible, include the ticket/requirement ID in the `@description` text and use `@instruction` to explain the overall objective for the next agent.
- Add method-level ApexDoc comments for every test method with `@description`, `@scenario`, and `@expectedResults` entries. Use the tags to describe the behavior under test, the inputs or branch being exercised, and the expected outcome. Where possible, include the ticket/requirement ID in the `@description` text.
- Every generated test class must have `@TestSetup` that creates its test user and any common fixture graph through the project factory. Each method re-queries its own isolated copy; no static Id or dataset cache survives setup.
- Reuse the setup user through `System.runAs`; choose the actual persona/profile deliberately. Keep User/permission setup-object DML and business-data DML explicitly separated in the project flow. Do not silently grant access, substitute admin, or use async to conceal Mixed DML.
- Execute every test method in the intended user context. Default to a non-admin test user and use `System.runAs(testUser)` for the behavior under test unless the requirement explicitly calls for admin context.
- Cover both positive and negative branches for the targeted behavior. Include invalid inputs, null/empty inputs, boundary values, and sanitization or validation failures where the entry point accepts external or user-provided data.
- For controllers, invocables, Flow-triggered Apex, LWC/Aura adapters and REST, map each input boundary to validation tests. Apex is statically typed: do not write uncompilable wrong-type method calls. Test malformed serialized input at the deserializer/REST boundary; verify Flow/LWC/Aura transport rejection using the appropriate caller-level test when it happens before Apex. In Apex, cover nulls, malformed IDs, ineligible records, unsafe text, and the specified safe failure response. Record unreachable paths with evidence.
- For Batch Apex, include bulk tests that prove record volume is handled safely and that no data is skewed after execution.
- Assert the requirement or acceptance criteria directly in every method. Every test method must contain at least one meaningful assertion tied to the business outcome.

## Test.startTest() / Test.stopTest()

Always wrap the code under test in `Test.startTest()` / `Test.stopTest()`:

- Resets governor limits so the test measures only the code under test
- Executes async operations synchronously (queueables, batch, future methods)
- Fires scheduled jobs immediately

## Test Code Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| SOQL/DML inside loops | Query once before the loop; use `Map<Id, SObject>` for lookups |
| Magic numbers in assertions | Derive expected values from setup constants |
| God test class (>500 lines) | Split into multiple test classes by behavior area |
| Long test methods (>30 lines) | Extract Given/When/Then into helper methods |
| Generic `Exception` catch | Catch the specific expected type (e.g., `DmlException`) |

## Workflow

### Step 1 — Gather Context

Before generating or fixing tests, identify:

- the target production class(es) under test
- existing test classes, test data factories, and setup helpers
- desired test scope (single class, specific methods, suite, or local tests)
- coverage threshold (Salesforce platform minimum is 75%; this framework's deploy gate is **95%** — see [DEPLOYMENT.md](../../workflows/DEPLOYMENT.md#apex-test-coverage-gate-mandatory))
- org alias when running tests against an org

### Step 2 — Generate the Test Class

Apply the structure, naming conventions, and patterns from the asset templates and reference docs.

**MANDATORY — File Deliverables:** For every test class, create BOTH files:
1. `{ClassName}Test.cls` — the test class (use [assets/test-class-template.cls](assets/test-class-template.cls) as starting point)
2. `{ClassName}Test.cls-meta.xml` — the metadata file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

Before adding factory source, check for existing class-name collisions and reuse the project implementation. For an approved new framework, use the [five core types, sample helpers, project facade and contract suites](references/test-data-factory.md#ownership-and-source-map). Keep project requirements out of generic core source. The older flat factory assets are compatibility examples, not the new generation default.

#### Setup And Method Structure

The [example project factory](assets/test-data-framework/examples/ExampleProjectTestDataFactory.cls) provides a small internal-user setup flow. Adapt it to the project's required persona; a Partner/Community Plus user requires an explicit project decision and prerequisites.

```apex
/**
 * @description Arrange the shared non-admin identity and relationship graph.
 * @scenario Each test starts from the same isolated fixtures.
 * @expectedResults One user and one Account/Contact graph exist.
 */
@TestSetup
static void setupData() {
    ExampleProjectTestDataFactory.createContractSetup();
}

/**
 * @description Verify the example flow reuses the supplied Contact.
 * @scenario Supply only a saved Contact.
 * @expectedResults Its actual Account is returned and no DML occurs.
 */
@IsTest
static void reuseContactAndItsParent() {
    System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
        Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        ExampleProjectTestDataFactory.AccountContactOptions options =
            new ExampleProjectTestDataFactory.AccountContactOptions();
        options.contact = contact;
        Test.startTest();
        ExampleProjectTestDataFactory.AccountContactDataSet result =
            ExampleProjectTestDataFactory.createAccountContactDataSet(options);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();
        Assert.areEqual(contact.Id, result.contact.Id, 'Reuse the supplied Contact.');
        Assert.areEqual(contact.AccountId, result.account.Id, 'Reuse its actual parent.');
        Assert.areEqual(0, dmlStatements, 'Reusing dependencies must not write.');
    }
}
```

Use Given/When/Then with the invocation and outcome assertions inside the intended user context. Complete class headers, including coverage mapping and `@instruction`, remain mandatory; add actual ticket references to class and method descriptions when applicable.

For negative tests, catch the specific expected exception and use `Assert.fail` if the call succeeds. Assert the exact error/status and unchanged data, not merely that some exception occurred. The [flow contract tests](assets/test-data-framework/tests/TestDataFlowContractTest.cls) demonstrate unsaved, deleted, parentless, and mismatched dependencies.

#### Naming Convention

- `should[ExpectedResult]_When[Scenario]`: `shouldSendNotification_WhenOpportunityClosedWon`
- `[SubjectOrAction]_[Scenario]_[ExpectedResult]`: `AccountUpdate_ChangeName_Success`

### Step 3 — Run Tests

Start narrow when debugging; widen after the fix is stable.

```bash
# Single test class
sf apex run test --class-names MyServiceTest --result-format human --code-coverage --target-org <alias>

# Specific test methods
sf apex run test --tests MyServiceTest.shouldUpdateStatus_WhenValidInput --result-format human --target-org <alias>

# All local tests
sf apex run test --test-level RunLocalTests --result-format human --code-coverage --target-org <alias>
```

### Step 4 — Analyze Results

Focus on:

- failing methods — exception types and stack traces
- uncovered lines and weak coverage areas
- whether failures indicate bad test data, brittle assertions, or broken production logic

### Step 5 — Fix Loop

When tests fail, run a disciplined fix loop (max 3 iterations — stop and surface root cause if still failing):

1. Read the failing test class and the class under test
2. Identify root cause from error messages and stack traces
3. Apply the diagnosed fix; delegate production code issues to `sf-platform-apex`. Existing test methods are business requirements: do not delete, refactor, or weaken their assertions without the guardrails' double validation. Prefer new regression methods.
4. Rerun the focused test before broader regression
5. Repeat until all tests pass, iteration limit reached, or root cause requires design change

### Step 6 — Validate Coverage

| Level | Coverage | Purpose |
|-------|----------|---------|
| Salesforce platform minimum | 75% | Required by Salesforce for production deploy |
| **This framework's deploy gate** | **95%** | Enforced for every deploy including dry-runs — see [DEPLOYMENT.md](../../workflows/DEPLOYMENT.md#apex-test-coverage-gate-mandatory) |
| Critical paths | 100% | Business-critical code |

Cover all paths: positive, negative/exception, bulk (251+ records), callout/async, validation, sanitization, and user-context behavior.

## What to Test by Component

| Component | Key Test Scenarios |
|-----------|-------------------|
| Trigger | Bulk insert/update/delete, recursion guard, field change detection, user-context assertions where sharing or CRUD/FLS matter |
| Service | Valid/invalid inputs, bulk operations, exception handling, sanitization of user-provided data |
| Controller | Page load, action methods, view state, input validation, bad-type and ineligible payload handling |
| Batch | start/execute/finish, scope matching (batch size >= record count), `Database.Stateful` tracking, bulk correctness, error handling, chaining (separate methods — `finish()` calling `Database.executeBatch()` throws `UnexpectedException`) |
| Queueable | Chaining (only first job runs in tests), bulkification, error handling, callout mocks before `Test.startTest()`, user-context execution when relevant |
| Callout | Success response, error response, timeout, malformed payload handling |
| Selector | Valid/null/empty inputs, bulk (251+), field population, sort order, `WITH USER_MODE` via `System.runAs` |
| Scheduled | Direct execution via `execute(null)`, CRON registration via `CronTrigger` query |
| Platform Event | `Test.enableChangeDataCapture()`, `Test.getEventBus().deliver()`, verify subscriber side effects |
| Flow-invoked Apex | Wrong data type, missing required fields, ineligible data, and safe failure or skip behavior |

## Output Expectations

Deliverables per test class:
- `{ClassName}Test.cls` + `{ClassName}Test.cls-meta.xml` (match API version of class under test; default `66.0`)
- Only the missing, approved factory/core/helper/flow types with matching metadata; never overwrite an existing factory or migrate tests implicitly.
- Contract-test results for newly adopted fixture APIs, with target org/API and any unresolved persona prerequisites.

## Agentic QA Routing

After Apex tests pass, call out whether broader QA is still needed:

- UI-visible behavior, admin configuration, portal/customer experience, or integration behavior: use `agentic-qa`.
- Pure Apex helper with isolated unit coverage and no behavior outside the class under test: mark broader QA `N/A` with the evidence.
- Release or production-like change: include canary/health evidence expectations from `agentic-qa` and [DEPLOYMENT.md](../../workflows/DEPLOYMENT.md#post-deploy-verification).

## Reference Files

Load on demand for detailed patterns:

| Reference | When to use |
|-----------|-------------|
| [references/test-data-factory.md](references/test-data-factory.md) | Canonical core/helper/flow contract, source templates, persona/Mixed DML decisions, and adoption checks |
| [references/assertion-patterns.md](references/assertion-patterns.md) | Assertion best practices, anti-patterns, common pitfalls |
| [references/mocking-patterns.md](references/mocking-patterns.md) | HttpCalloutMock, DML mocking, StubProvider, SOSL, Email, Platform Events |
| [references/async-testing.md](references/async-testing.md) | Batch, Queueable, Future, Scheduled job testing |

---

## Supplemental Reference Routing

Upstream attribution is retained in the skill metadata. Use these focused references instead of copying conflicting legacy generation instructions. This skill and the Test Data Framework contract take precedence over their historical snippets: required headers, shared setup user, non-admin `System.runAs`, `Assert` methods, explicit build/create semantics, and the 95% deployment gate still apply.

| Reference | Purpose |
| --- | --- |
| [CLI commands](references/from-platform-apex-test-run/cli-commands.md) | Test execution flags, async results and coverage retrieval. |
| [Test patterns](references/from-platform-apex-test-run/test-patterns.md) | Scenario ideas; adapt older snippets to current rules. |
| [Extended patterns](references/from-sf-test/test-patterns.md) | REST, events, Flow and mocking scenarios. |
| [Test-fix loop](references/from-platform-apex-test-run/test-fix-loop.md) | Root-cause analysis; never weaken existing requirements to make tests pass. |
| [Performance](references/from-platform-apex-test-run/performance-optimization.md) | Isolate expensive boundaries without hiding integration behavior. |
| [Basic scaffold](assets/test-class-template.cls) | Required headers, shared user and explicit acceptance placeholders. |
| [Legacy flat factory](assets/test-data-factory-template.cls) | Compatibility only; do not introduce new boolean insertion switches. |

For async assertions, observe the supported test execution boundary and assert persisted effects after `Test.stopTest()`; test chained stages separately where necessary. Fixture helpers must never use async to avoid Mixed DML. See [async testing](references/async-testing.md).
