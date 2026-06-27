---
name: sf-platform-test
description: "Generate and validate Apex test classes with TestDataFactory patterns, bulk testing (251+ records), mocking strategies, assertion best practices, and disciplined test-fix loops. Use this skill when creating new Apex test classes, improving test coverage, debugging and fixing failing Apex tests, running test execution and coverage analysis, or implementing testing patterns for triggers, services, controllers, batch jobs, queueables, and integrations. Triggers on *Test.cls, *_Test.cls files, sf apex run test workflows, coverage reports, test-fix loops. Do NOT trigger for production Apex code (use platform-apex-generate) or Jest/LWC tests."
metadata:
  version: "1.0"
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
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-apex-test-generate; forcedotcom/sf-skills :: platform-apex-test-run; Clientell-Ai/salesforce-skills :: sf-test |

Generate production-ready Apex test classes and run disciplined test-fix loops with coverage analysis.

Coverage analysis run as part of a deploy (dry-run, validate, or real) must satisfy the 95% mandatory coverage gate in [DEPLOYMENT.md](../../workflows/DEPLOYMENT.md), not just the org-wide default minimum — treat a result below 95% for any class/trigger in deploy scope as a failure to fix, not a passing result to report.

## Core Principles

1. **One behavior per method** — each test method validates a single scenario. Separate positive, negative, and bulk tests. NEVER combine related-but-distinct inputs (e.g., null and empty) in one method — create `_NullInput_` and `_EmptyInput_` as separate test methods
2. **Bulkify tests** — test with 251+ records to cross the 200-record trigger batch boundary. **Batch Apex exception:** in test context only one `execute()` invocation runs, so set `batchSize >= testRecordCount`. See [references/async-testing.md](references/async-testing.md)
3. **Isolate test data** — every `@TestSetup` must delegate record creation to a `TestDataFactory` class. If none exists, create one first. Never build record lists inline in `@TestSetup`. Never rely on org data (`SeeAllData=false`) or hardcoded IDs. For duplicate rule handling, see [references/test-data-factory.md](references/test-data-factory.md)
4. **Assert meaningfully** — use exact expected values computed from test data setup. NEVER use range assertions or approximate counts when the value is deterministic. Always include failure messages. See [references/assertion-patterns.md](references/assertion-patterns.md)
5. **Use `Assert` class only** — `Assert.areEqual`, `Assert.isTrue`, `Assert.fail`, etc. Never use legacy `System.assert`, `System.assertEquals`, or `System.assertNotEquals`
6. **Mock external boundaries** — use `HttpCalloutMock` for callouts, `Test.setFixedSearchResults` for SOSL, DML mock classes for database isolation. Design for testability via constructor injection. See [references/mocking-patterns.md](references/mocking-patterns.md)
7. **Test negative paths** — validate error handling and exception scenarios, not just happy paths
8. **Wrap with start/stop** — pair `Test.startTest()` with `Test.stopTest()` to reset governor limits and force async execution

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
- coverage threshold (75% minimum for deploy, 90%+ recommended)
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

If no `TestDataFactory` exists in the project, create `TestDataFactory.cls` + `TestDataFactory.cls-meta.xml` using [assets/test-data-factory-template.cls](assets/test-data-factory-template.cls).

#### @TestSetup Example

```apex
@TestSetup
static void setupTestData() {
    List<Account> accounts = TestDataFactory.createAccounts(251, true);
}
```

#### Test Method Structure

Use Given/When/Then:

```apex
@isTest
static void shouldUpdateStatus_WhenValidInput() {
    // Given
    List<Account> accounts = [SELECT Id FROM Account];

    // When
    Test.startTest();
    MyService.processAccounts(accounts);
    Test.stopTest();

    // Then
    List<Account> updated = [SELECT Id, Status__c FROM Account];
    Assert.areEqual(251, updated.size(), 'All accounts should be processed');
}
```

#### Negative Test — Exception Pattern

Use try/catch with `Assert.fail` to verify expected exceptions:

```apex
@isTest
static void shouldThrowException_WhenInvalidInput() {
    // Given
    List<Account> emptyList = new List<Account>();

    // When/Then
    Test.startTest();
    try {
        MyService.processAccounts(emptyList);
        Assert.fail('Expected MyCustomException to be thrown');
    } catch (MyCustomException e) {
        Assert.isTrue(e.getMessage().contains('cannot be empty'),
            'Exception message should indicate empty input');
    }
    Test.stopTest();
}
```

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
3. Apply fix — adjust test data or assertions for test-side issues; delegate production code issues to the `platform-apex-generate` skill
4. Rerun the focused test before broader regression
5. Repeat until all tests pass, iteration limit reached, or root cause requires design change

### Step 6 — Validate Coverage

| Level | Coverage | Purpose |
|-------|----------|---------|
| Production deploy | 75% minimum | Required by Salesforce |
| Recommended | 90%+ | Best practice target |
| Critical paths | 100% | Business-critical code |

Cover all paths: positive, negative/exception, bulk (251+ records), callout/async.

## What to Test by Component

| Component | Key Test Scenarios |
|-----------|-------------------|
| Trigger | Bulk insert/update/delete, recursion guard, field change detection |
| Service | Valid/invalid inputs, bulk operations, exception handling |
| Controller | Page load, action methods, view state |
| Batch | start/execute/finish, scope matching (batch size >= record count), `Database.Stateful` tracking, error handling, chaining (separate methods — `finish()` calling `Database.executeBatch()` throws `UnexpectedException`) |
| Queueable | Chaining (only first job runs in tests), bulkification, error handling, callout mocks before `Test.startTest()` |
| Callout | Success response, error response, timeout |
| Selector | Valid/null/empty inputs, bulk (251+), field population, sort order, `WITH USER_MODE` via `System.runAs` |
| Scheduled | Direct execution via `execute(null)`, CRON registration via `CronTrigger` query |
| Platform Event | `Test.enableChangeDataCapture()`, `Test.getEventBus().deliver()`, verify subscriber side effects |

## Output Expectations

Deliverables per test class:
- `{ClassName}Test.cls` + `{ClassName}Test.cls-meta.xml` (match API version of class under test; default `66.0`)
- `TestDataFactory.cls` + `TestDataFactory.cls-meta.xml` (if not already present)

## Reference Files

Load on demand for detailed patterns:

| Reference | When to use |
|-----------|-------------|
| [references/test-data-factory.md](references/test-data-factory.md) | TestDataFactory patterns, field overrides, duplicate rule handling |
| [references/assertion-patterns.md](references/assertion-patterns.md) | Assertion best practices, anti-patterns, common pitfalls |
| [references/mocking-patterns.md](references/mocking-patterns.md) | HttpCalloutMock, DML mocking, StubProvider, SOSL, Email, Platform Events |
| [references/async-testing.md](references/async-testing.md) | Batch, Queueable, Future, Scheduled job testing |

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `platform-apex-test-run` (forcedotcom/sf-skills :: platform-apex-test-run)

# platform-apex-test-run: Salesforce Test Execution & Coverage Analysis

Use this skill when the user needs **Apex test execution and failure analysis**: running tests, checking coverage, interpreting failures, improving coverage, and managing a disciplined test-fix loop for Salesforce code.

## When This Skill Owns the Task

Use `platform-apex-test-run` when the work involves:
- `sf apex run test` workflows
- Apex unit-test failures
- code coverage analysis
- identifying uncovered lines and missing test scenarios
- structured test-fix loops for Apex code

Delegate elsewhere when the user is:
- writing or refactoring production Apex → `platform-apex-generate` skill
- testing Agentforce agents → `agentforce-test` skill
- testing LWC with Jest → [experience-lwc-generate](../experience-lwc-generate/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- target org alias
- desired test scope: single class, specific methods, suite, or local tests
- coverage threshold expectation
- whether the user wants diagnosis only or a test-fix loop
- whether related test data factories already exist

---

## Recommended Workflow

### 1. Discover test scope
Identify:
- existing test classes
- target production classes
- test data factories / setup helpers

### 2. Run the smallest useful test set first
Start narrow when debugging a failure; widen only after the fix is stable.

### 3. Analyze results
Focus on:
- failing methods
- exception types and stack traces
- uncovered lines / weak coverage areas
- whether failures indicate bad test data, brittle assertions, or broken production logic

### 4. Run a disciplined fix loop
When the issue is code or test quality:
- delegate code fixes to `platform-apex-generate` skill when needed
- add or improve tests
- rerun focused tests before broader regression

### 5. Improve coverage intentionally
Cover:
- positive path
- negative / exception path
- bulk path (251+ records where appropriate)
- callout or async path when relevant

---

## High-Signal Rules

| Rule | Rationale |
|------|-----------|
| Default to `SeeAllData=false` | Ensures test isolation; prevents reliance on org-specific data |
| Every test must assert meaningful outcomes | Tests with no assertions prove nothing and give false confidence |
| Test bulk behavior with 251+ records | Triggers process in batches of 200; 251 records crosses the boundary |
| Use factories / `@TestSetup` when they improve clarity | Consistent data creation in one place; rolled back between test methods |
| Pair `Test.startTest()` with `Test.stopTest()` for async | Ensures async operations (queueable, future) complete before assertions |
| Do not hide flaky org dependencies inside tests | Prevents intermittent failures tied to org state |

---

## Gotchas

| Issue | Resolution |
|-------|------------|
| Test passes locally but fails in CI org | Check for `SeeAllData=true` or undeclared dependencies on org-specific records |
| Coverage drops unexpectedly after refactor | Run focused class-level tests first, then widen to `RunLocalTests` to confirm |
| "Uncommitted work pending" error in callout test | DML and HTTP callouts cannot be mixed in the same test context without `Test.startTest()` wrapping |
| Mock not taking effect in test | Ensure `Test.setMock()` is called before the code that makes the callout |
| `@TestSetup` data missing in test method | `@TestSetup` data is committed per test method — re-query it; do not store in static variables |

---

## Output Format

When finishing, report in this order:
1. **What tests were run**
2. **Pass/fail summary**
3. **Coverage result**
4. **Root-cause findings**
5. **Fix or next-run recommendation**

Suggested shape:

```text
Test run: <scope>
Org: <alias>
Result: <passed / partial / failed>
Coverage: <percent / key classes>
Issues: <highest-signal failures>
Next step: <fix class, add test, rerun scope, or widen regression>
```

---

## Cross-Skill Integration

| Need | Delegate to | Reason |
|------|-------------|--------|
| Fix production code or author test classes | `platform-apex-generate` skill | Code generation and repair |
| Create bulk / edge-case test data | [platform-data-manage](../platform-data-manage/SKILL.md) | Realistic test datasets |
| Deploy updated tests to org | [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md) | Deployment workflows |
| Inspect detailed runtime logs | [platform-apex-logs-debug](../platform-apex-logs-debug/SKILL.md) | Deeper failure analysis |

---

## Reference File Index

| File | When to read |
|------|-------------|
| `references/cli-commands.md` | All `sf apex run test` command flags, output formats, async execution, and coverage commands |
| `references/test-patterns.md` | Test class templates — basic, bulk (251+), mock callout, and data factory patterns |
| `references/testing-best-practices.md` | Core testing principles — AAA pattern, naming conventions, bulk, negative, and mock strategies |
| `references/test-fix-loop.md` | Agentic test-fix loop implementation and failure analysis decision tree |
| `references/mocking-patterns.md` | HttpCalloutMock, DML mocking, StubProvider, and selector mocking patterns |
| `references/performance-optimization.md` | Techniques to reduce test execution time — DML mocking, SOQL mocking, loop optimizations |
| `assets/basic-test.cls` | Template: standard test class with `@TestSetup`, positive / negative / bulk / edge-case methods |
| `assets/bulk-test.cls` | Template: bulk test with 251+ records that crosses the 200-record trigger batch boundary |
| `assets/mock-callout-test.cls` | Template: HTTP callout mock using `HttpCalloutMock` |
| `assets/test-data-factory.cls` | Template: reusable `TestDataFactory` with create and insert helpers |
| `assets/dml-mock.cls` | Template: `IDML` interface + `DMLMock` implementation for database-free unit tests |
| `assets/stub-provider-example.cls` | Template: `StubProvider`-based dependency injection stub |
| `hooks/scripts/parse-test-results.py` | Post-tool hook — parses `sf apex run test` JSON output and formats failures for the auto-fix loop |

---

## Score Guide

| Score | Meaning |
|---|---|
| 108+ | strong production-grade test confidence |
| 96–107 | good test suite with minor gaps |
| 84–95 | acceptable but strengthen coverage / assertions |
| < 84 | below standard; revise before relying on it |

### Supplemental Guidance from `sf-test` (Clientell-Ai/salesforce-skills :: sf-test)

# Apex Test Class Generator

You are a Salesforce test class specialist. Generate comprehensive test classes that achieve 85%+ code coverage with meaningful assertions.

## Test Class Structure

### Required Pattern
```apex
@IsTest
private class MyClassTest {

    @TestSetup
    static void makeData() {
        // Use TestFactory for all record creation
        List<Account> accounts = TestDataFactory.createAccounts(200);
        insert accounts;

        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
    }

    @IsTest
    static void testMethodName_positiveScenario() {
        // Arrange
        List<Account> accounts = [SELECT Id, Name FROM Account WITH USER_MODE];

        // Act
        Test.startTest();
        MyClass.myMethod(accounts);
        Test.stopTest();

        // Assert
        List<Account> results = [SELECT Id, Status__c FROM Account WITH USER_MODE];
        System.assertEquals(200, results.size(), 'All accounts should be processed');
        for (Account acc : results) {
            System.assertNotEquals(null, acc.Status__c, 'Status should be set');
        }
    }
}
```

### Test Scenarios (generate ALL of these)

1. **Positive tests**: Happy path with valid data
2. **Negative tests**: Invalid data, null inputs, empty lists
3. **Bulk tests**: 200+ records to verify bulkification
4. **Permission tests**: Test with restricted user profile
5. **Boundary tests**: Edge cases (0 records, 1 record, max records)

### Permission Testing Pattern
```apex
@IsTest
static void testMethod_restrictedUser() {
    User restrictedUser = TestDataFactory.createStandardUser();
    insert restrictedUser;

    System.runAs(restrictedUser) {
        Test.startTest();
        try {
            MyClass.myMethod(testData);
            System.assert(false, 'Should have thrown exception');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('access'),
                'Should throw security exception');
        }
        Test.stopTest();
    }
}
```

### Callout Mock Pattern
```apex
@IsTest
private class MyCalloutClassTest {

    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        MockHttpResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    @IsTest
    static void testCallout_success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, '{"status":"ok"}'));

        Test.startTest();
        String result = MyCalloutClass.makeCallout();
        Test.stopTest();

        System.assertEquals('ok', result, 'Should return success status');
    }

    @IsTest
    static void testCallout_failure() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500, '{"error":"fail"}'));

        Test.startTest();
        try {
            MyCalloutClass.makeCallout();
            System.assert(false, 'Should throw on 500');
        } catch (CalloutException e) {
            System.assert(true, 'Exception expected on server error');
        }
        Test.stopTest();
    }
}
```

## Rules
- NEVER hardcode record IDs — always query or create in @TestSetup
- ALWAYS use `Test.startTest()` and `Test.stopTest()` to reset governor limits
- ALWAYS use `System.assertEquals` / `System.assertNotEquals` with descriptive messages
- ALWAYS test with 200 records minimum for bulk scenarios
- Use `@TestVisible` on private methods/variables instead of making them public
- Create a `TestDataFactory` class if one doesn't exist
- NEVER use `SeeAllData=true` unless testing specific platform features
- Test both synchronous and asynchronous paths (future, queueable, batch)

## TestDataFactory Pattern
```apex
@IsTest
public class TestDataFactory {

    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i
            ));
        }
        return accounts;
    }

    public static User createStandardUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        return new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
    }
}
```

### Async Testing Patterns
- **@future**: Runs after `Test.stopTest()` — assert side effects after stopTest
- **Batch**: Call `Database.executeBatch()` between `Test.startTest()` / `Test.stopTest()`
- **Queueable**: Call `System.enqueueJob()` between startTest/stopTest — chaining limited to depth 1 in test
- **Schedulable**: Call `System.schedule()` between startTest/stopTest — assert CronTrigger afterward

### Platform Event & CDC Testing
- Platform Events: Call `Test.getEventBus().deliver()` after publishing to force synchronous delivery
- Change Data Capture: Call `Test.enableChangeDataCapture()` in test setup, then `Test.getEventBus().deliver()` after DML

### Stub API (Dependency Injection)
Use `System.StubProvider` interface + `Test.createStub()` to mock dependencies without hitting the database.

### Test.loadData()
Load bulk test data from CSV in a Static Resource: `Test.loadData(Account.sObjectType, 'TestAccounts')`

### Mixed DML Workaround
Use `System.runAs()` to separate setup object DML (User, Profile) from non-setup objects in the same test.

### Special Object Testing
- Use `Test.getStandardPricebookId()` for Product2/PricebookEntry tests
- Use `RestContext.request = new RestRequest()` for @RestResource endpoint tests

## Gotchas
- `@TestSetup` data is shared (NOT isolated) across test methods — each method gets a copy that resets
- `SeeAllData=true` exposes production data — almost never use it
- Future/Batch/Queueable execute AFTER `Test.stopTest()`, not during
- Callout mock (`Test.setMock()`) must be registered BEFORE `Test.startTest()`
- Platform Event ordering is NOT guaranteed in tests
- `Test.startTest()` / `Test.stopTest()` can only be called ONCE per test method
- Batch Apex `finish()` method also runs after `Test.stopTest()`
- Mixed DML throws `MIXED_DML_OPERATION` — use `System.runAs()` to workaround

## Workflow
1. Read the class under test using Read/Glob tools
2. Identify all public/global methods and code paths
3. Check if TestDataFactory exists; create if not
4. Generate test class with all scenario types
5. Run tests: `sf apex run test -n MyClassTest --synchronous --code-coverage`
6. Report coverage and fix any failures

## References
- [Test Patterns](references/test-patterns.md) — async testing, Platform Events, CDC, Stub API, REST endpoints, mixed DML, Flow test coverage
- [Governor Limits](../../references/governor-limits.md) — per-transaction limits for test context
