# Testing

## Purpose And Use

This file owns repeatable verification and testing workflow guidance. Read it before choosing checks, Apex tests, local static analysis, deploy validation, manual QA, or acceptance verification. Put test commands, validation protocols, mocking strategies, coverage expectations, and handoff evidence requirements here.

## Current Notes

Use `agentic-qa` for the broader scenario matrix, manual/browser verification, canary checks and regression evidence. It complements the Apex-specific rules below.

Use the `sf-platform-test` skill for Apex test generation, test-fix loops, and coverage work.

For reusable test data, follow the [Test Data Framework](../skills/sf-platform-test/references/test-data-factory.md) and its core/helper/flow templates. Reuse existing project factories rather than migrating existing tests implicitly.

When writing or reviewing Apex tests, align with these framework expectations:

- Class-level comment headers should name the production Apex class, trigger handler, controller, batch, invocable, or Flow entry point under test. Where possible, include the ticket/requirement ID in the `@description` text and use `@instruction` to explain the overall objective for the next agent.
- Method-level comments should include `@description`, `@scenario`, and `@expectedResults`. Where possible, include the ticket/requirement ID in the `@description` text.
- Every generated class creates its shared test user and common graph in `@TestSetup` through the project factory; test methods re-query their isolated fixtures.
- Default to `System.runAs` with a non-admin test user unless the requirement explicitly depends on admin context.
- Cover happy path, negative path, bulk path, and validation or sanitization failures for external entry points.
- For Batch Apex, prove the post-run data state is correct after bulk execution.
- Keep assertions meaningful and tied to the requirement or acceptance criteria.

## Fixture Adoption Checks

- Confirm the real persona/profile and required project graph before implementing user flows. Partner and Community Plus are not interchangeable defaults; unresolved licensing/profile/role prerequisites remain explicit decisions.
- Run the supplied helper, registry and flow contract suites in the approved target org/API after adaptation. Include zero-DML builds, fresh records from reused helpers, null overrides, native invalid-value errors, 251-record bulk insertion, rollback and dependency reuse/rejection.
- Verify Mixed DML behavior through both standalone tests and the approved deployment validation. Separate User/permission setup DML from business-data DML in the project flow; never hide it in helpers or async jobs.
- Fixture arrangement may deliberately use system-mode DML. Keep production security checks unchanged and assert CRUD/FLS/sharing outcomes separately under the actual user context.
- For wrong-type inputs rejected before Apex, test the actual Flow/LWC/Aura/REST transport boundary and retain caller-level evidence. Do not generate Apex calls that cannot compile.
- Record test results, coverage, unresolved prerequisites and any untested platform paths. Static analysis alone is not Apex compilation or runtime proof.

## Verification Modes

- **Local static check** - lint, PMD, Salesforce Code Analyzer, XML parsing, link checks, or other local verification.
- **Apex/unit test** - focused test classes first, then broader suites when shared behavior changes.
- **Deploy validation** - dry-run or validate-only deploy with the target org and scope known.
- **Manual/browser QA** - user-profile, permission, UI, Experience Cloud, or end-to-end workflow checks.
- **Report-only QA** - defect report without code changes when the user asks for analysis only.
- **Canary/post-deploy** - read-only health checks after a deploy or release.
- **Benchmark** - before/after performance comparison using measured values.

## Scenario Matrix

For each changed behavior, consider:

- Happy path.
- Empty or no-data path.
- Invalid input or validation failure.
- Permission, sharing, or profile difference.
- Bulk or high-volume path for Apex/data work.
- Integration timeout/error path.
- Navigation-away, double-submit, stale state, or retry path for UI/async work.
- Regression path for the closest existing behavior.

Do not mark a scenario verified unless prerequisites, user context, and expected result are clear.

## Evidence Standard

Every testing report should include:

- Command or manual path used.
- Target org/alias or local environment when applicable.
- Test class or method, page/workflow, or scenario name.
- Result and failure cause.
- Known gaps and why they were not run.

After fixing a defect, re-run the original failing scenario and at least one focused regression scenario.
