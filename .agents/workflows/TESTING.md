# Testing

## Purpose And Use

This file owns repeatable verification and testing workflow guidance. Read it before choosing checks, Apex tests, local static analysis, deploy validation, manual QA, or acceptance verification. Put test commands, validation protocols, mocking strategies, coverage expectations, and handoff evidence requirements here.

## Current Notes

Use the narrowest meaningful checks available and follow the relevant Salesforce and Apex standards. Use `agentic-qa` when the task needs scenario design, manual/browser verification, report-only QA, canary checks, performance comparison, or regression mapping.

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
