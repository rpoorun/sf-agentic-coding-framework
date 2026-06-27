# PMD Apex Ruleset Guide

## Purpose And Use

This file defines the repository's PMD Apex static-analysis expectations. Read it before running PMD, changing PMD configuration, adding suppressions, or reporting static-analysis results. Put PMD rule guidance, command shapes, suppression policy, tuning notes, and agent reporting requirements here.

This repository should use PMD as a static analysis gate for Apex. The companion ruleset template is here:

```text
config/pmd/apex-ruleset.xml
```

## Reference Version

This guide was aligned with PMD Apex rule documentation for PMD 7.25.0. PMD rule names can change across major versions, so update this file when upgrading PMD.

## Recommended Baseline

The [Org] baseline expects Apex PMD to be available in the project tooling. Start with PMD's Apex quickstart ruleset and add project-specific strictness over time. The quickstart baseline includes rules across:

- Best practices.
- Code style.
- Design.
- Documentation.
- Error prone.
- Performance.
- Security.

High-value rules for Salesforce projects include:

| Area | Rules |
| --- | --- |
| Security | `ApexCRUDViolation`, `ApexSharingViolations`, `ApexSOQLInjection`, `ApexSuggestUsingNamedCred`, `ApexInsecureEndpoint`, `ApexOpenRedirect`, `ApexXSSFromURLParam`, `ApexXSSFromEscapeFalse`, `ApexBadCrypto` |
| Performance | `OperationWithLimitsInLoop`, `OperationWithHighCostInLoop`, `AvoidNonRestrictiveQueries`, `AvoidDebugStatements` |
| Tests | `ApexUnitTestClassShouldHaveAsserts`, `ApexUnitTestClassShouldHaveRunAs`, `ApexUnitTestShouldNotUseSeeAllDataTrue`, `ApexUnitTestMethodShouldHaveIsTestAnnotation` |
| Maintainability | `AvoidLogicInTrigger`, `AvoidGlobalModifier`, `AvoidHardcodingId`, `CyclomaticComplexity`, `CognitiveComplexity`, `ExcessiveParameterList`, `TooManyFields` |
| Error-prone code | `EmptyCatchBlock`, `EmptyIfStmt`, `EmptyStatementBlock`, `EmptyTryOrFinallyBlock`, `AvoidDirectAccessTriggerMap`, `MethodWithSameNameAsEnclosingClass` |

## Suggested Commands

Use the command style already supported by the repo. Examples:

```powershell
pmd check --dir force-app/main/default/classes --rulesets config/pmd/apex-ruleset.xml --format text
```

```powershell
pmd check --dir force-app/main/default --rulesets config/pmd/apex-ruleset.xml --format html --report-file reports/pmd-apex.html
```

If PMD is installed through npm, Maven, SFDX Scanner, or a CI image, use the equivalent project command instead of adding a new installer.

## Suppression Policy

Suppressions are allowed only when the issue is understood and documented.

Allowed suppression patterns:

```apex
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class ExampleController {
    // Explain why this is safe, such as a prior centralized CRUD/FLS check.
}
```

Avoid broad class-level suppressions when a method-level or line-level suppression is enough.

Every suppression should explain:

- Why the rule is a false positive or intentionally bypassed.
- Where the equivalent safety control exists.
- Whether the suppression is temporary.

## Tuning Notes

- `ApexCRUDViolation` can produce false positives when CRUD/FLS is enforced through shared helper methods. Prefer documenting the helper and suppressing narrowly.
- `ApexSharingViolations` should usually remain enabled. If a class needs `without sharing`, the reason should be explicit.
- `UnusedMethod` can flag methods used indirectly by Flow, Aura, LWC serialization, reflection-like patterns, or managed package hooks. Verify references before deleting.
- Complexity rules should trigger refactoring discussion, not automatic rewrites.
- Documentation rules should not be used to force noisy comments on self-explanatory private code.

## Agent Requirements

Agents must not:

- Disable PMD rules to make a change pass without explaining why.
- Add broad suppressions to avoid refactoring.
- Treat PMD as a substitute for tests.
- Treat a clean PMD result as deploy approval.
- Treat Salesforce curated skill templates as exempt from PMD.

Agents must:

- Report PMD command used.
- Report any violations left unresolved.
- Explain suppressions added or changed.
- Keep PMD config changes separate from unrelated feature work unless the user asked for both.
- Reconcile Salesforce Code Analyzer findings with this PMD ruleset instead of silently relaxing either gate.
