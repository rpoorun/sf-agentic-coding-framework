# Salesforce Project Best Practices

## Purpose And Use

This file defines the reusable Salesforce quality baseline used by this repository. Read it before creating or changing Salesforce metadata, Apex, tests, configuration, naming, or Lightning setup. Put stable quality expectations, naming conventions, configuration standards, architecture guidance, and review criteria here.

This document summarizes the [Org] Salesforce best-practice baseline used across projects unless client-specific standards override it.

Source baseline: this organization's internal Salesforce best-practices reference document. Record the actual source filename and version history locally; do not carry a specific organization's document name into the master framework repository.

## Client Override Rule

- Apply these standards by default.
- If the client has a documented convention, follow the client convention.
- If client guidance conflicts with this baseline, record the conflict and the selected convention in the task handoff.
- Do not mix two naming or architecture conventions in the same feature without a clear migration reason.

## Configuration Naming Principles

- Avoid abbreviations because they create interpretation risk.
- Avoid underscores in object and field API names except for approved app, module, functional-domain, or technical prefixes.
- Fill the `Description` field in English for custom configuration.
- Fill `Help Text` when it improves admin or user understanding, especially for picklists.
- Use English setup labels when the project has several languages; translate user-facing labels through Salesforce translation tooling.
- For single-language projects, setup may use the project language, but descriptive fields should remain in English.

## Metadata Naming Matrix

| Metadata | Label convention | API/name convention | Notes |
| --- | --- | --- | --- |
| Custom object | One or more words, first letter of each word uppercase. | Singular `UpperCamelCase`; no underscore except approved prefix. | Description is mandatory. |
| Custom field | One or more words, first letter of each word uppercase. | `UpperCamelCase`; no underscore except approved prefix. | Description must explain field usage. |
| Child relationship | Not applicable. | Plural `UpperCamelCase`. | Use clear distinct names for multiple relationships on the same child object. |
| Technical field | Clear technical label. | `TECH_` plus `UpperCamelCase`. | For calculated or Apex-referenced fields not shown on layouts. |
| Reporting field | Clear reporting label. | `REP_` plus `UpperCamelCase`. | For report-only fields not shown on layouts. |
| Picklist value | User-facing value. | Uppercase words separated by underscores when used as integration identifiers. | Use global value sets only when values are shared by more than one object. |
| Record type | One or more words, first letter of each word uppercase. | `UpperCamelCase`; no underscore. | Avoid abbreviations and fill description. |
| Validation rule | `[Field Name] [Applied Rule]` or `[Group] [Applied Rule]`. | Keep meaningful and searchable. | Example: `Shipping Postal Code Is Required`. |
| Workflow rule | `WF - [Brief Description]`. | `WF_[LabelWithoutSpaces]`. | Legacy only unless project still uses workflow rules. |
| Profile | Function, department, or company plus user type. | `UpperCamelCase`. | Prefer permission sets for new access design where possible. |
| Permission set | Same as single permission or verb/perimeter/user type. | Project convention. | Example: `Manage Invoices`, `Invoice User`. |
| Lightning home page | `Home [App Name]` or `[Client Name] Home`. | `UpperCamelCase`. | Rename through Lightning App Builder. |
| Lightning app page | `[App Name]`. | `UpperCamelCase`. | Avoid underscores. |
| Lightning record page | `[Object] Record Page`. | `UpperCamelCase`. | Keep object name explicit. |
| Page layout | `[Function] Layout` or `[Object] Layout`. | Project convention. | Keep layout purpose visible. |
| Button, link, action | `[Verb] [Name]`. | Project convention. | Use action-oriented labels. |
| Custom report type | Descriptive business label. | Meaningful concise name. | Description must explain content and use. |
| Report | Descriptive business label. | Meaningful concise name. | Avoid unclear abbreviations where possible. |
| Dashboard | Descriptive business label. | `UpperCamelCase`. | Example: `AdoptionDashboard`. |
| Public group / queue | Clear audience or ownership label. | Project convention. | Keep operational purpose visible. |

## Apex And Component Naming

| Component | Naming convention | Notes |
| --- | --- | --- |
| Service Manager | `SMXXX_ServiceName` | Business logic; no SOQL and no callouts. |
| Entity Manager | `EMXXX_ObjectName` | Data preparation and manipulation rules; no SOQL and no callouts. |
| Data Manager | `DMXXX_ObjectName` | SOQL, DML, callouts, and database access. |
| Batch class | `BAXXX_BatchName` | May also implement `Schedulable` when that keeps the feature cohesive. |
| Queueable class | `QUXXX_QueueableName` | Prefer Queueable over new `@future` work. |
| Web service | `WSXXX_WebServiceName` | Request: `requestNameRequest`; response: `requestNameResponse`. |
| Wrapper | `WRP_WrapperName` | Exposed wrappers must be documented and sanitized. |
| Invocable class | `INVXXX_InvocableName` | Only one `@InvocableMethod` per class; method label should match class name. |
| Visualforce page | `VFXX_PageName` | Legacy only unless the project still uses Visualforce. |
| Visualforce controller | `VFCXX_PageName` | Controller for matching Visualforce page. |
| Lightning Apex controller | `LTNXXX_ComponentName` | Use `@AuraEnabled` only on methods and wrappers called by the component. |
| Aura component | `MOD_ComponentName` | `MOD` is up to 3 letters from project, module, or feature. |
| LWC component | `modComponentName` | Start lowercase; `mod` is up to 3 letters from project, module, or feature. |
| Test class | `ClassName_TEST` | One Apex class should have at least one matching test class. |
| SOAP mock | `ClassName_MockImpl` | Reusable mocks may be separate test classes. |
| REST mock | `ClassName_HttpMock` | Mark mocks with `@IsTest`. |

## Apex Layering Pattern

Use the project pattern unless the existing codebase or client standard defines another pattern.

- Service Managers contain business logic and call Entity Managers.
- Entity Managers prepare data and enforce object-level manipulation rules, then call Data Managers.
- Data Managers contain SOQL, DML, callouts, and database access.
- One Data Manager should focus on one object.
- Matching EM and DM classes should use the same numeric identifier when the pattern is already used in the project.
- SM tests should cover business behavior, bulk behavior, and governor-limit-sensitive behavior.

## Trigger Rules

- Use only one trigger per object.
- Put no business logic in the trigger body.
- Use the shared trigger handler framework when one exists.
- Use object-specific handler classes named according to the project convention, such as `TH_ObjectName`.
- Test trigger behavior through actual DML events, not only by calling handler methods directly.
- Trigger bypass should be deliberate and auditable, commonly through hierarchical custom settings or equivalent metadata.
- Use one bypass checkbox per feature or user story when bypass is required.

## Coding Rules

- Use 4 spaces as the indentation unit.
- Method names start with a lowercase verb and use `camelCase`, such as `setOpportunityStatus`.
- Variable names must be self-explanatory.
- Collection prefixes are allowed when the project uses them: `lst` or `list` for lists, `set` for sets, and `map` for maps.
- Constants use uppercase words separated by underscores.
- Opening braces stay at the end of the declaration line; closing braces use their own line.
- Remove `console.log` and `System.debug` before delivery unless logging is explicitly required and safe.
- Prefer `let` over `var` in JavaScript because `let` is block-scoped.
- Use SLDS-equivalent patterns for Lightning UI.
- Use component events rather than Aura application events unless there is a documented reason.
- Use lazy loading and conditional rendering for heavy Lightning UI.

## Golden Rules

- No SOQL, SOSL, DML, callouts, or `@future` work inside loops.
- Bulkify every method; prefer collection parameters over single-record parameters for shared logic.
- Do not hardcode IDs, picklist values, parameters, URLs, or org-specific values.
- Always check collection size and null values before use.
- Follow DRY: use Service Managers and utility classes to regroup repeated behavior.
- Refactor old code step by step when touching it; a full rewrite is not mandatory unless the user or client asks for it.
- Delete unused code only when references are checked and the code is protected by version control.

## Test Class Rules

- A development is not done until tests are written or updated and relevant tests pass.
- Aim for 90 percent coverage or higher where possible; Salesforce production deployment still requires at least 75 percent coverage.
- New features must not reduce meaningful test coverage.
- `SeeAllData=true` is forbidden unless a rare project exception is explicitly approved.
- Tests must not rely on existing org data.
- Use `@TestSetup` and test data factories where appropriate.
- Create admin and non-admin test users when behavior depends on profile, sharing, or permissions.
- Use `System.runAs` for user-context behavior.
- Use `Test.startTest()` and `Test.stopTest()` to reset limits and execute async behavior.
- Test positive and negative cases.
- Bulk test trigger logic with more than 200 records when trigger behavior is involved.
- Each test method must contain at least one assertion.
- Assertion messages must explain the behavior being verified.
- The first assert parameter is expected value; the second is actual value.
- Use record type developer names, not labels.
- Query with `ORDER BY` when assert order matters.

## Starting A Project

- Create required environments before development starts.
- For projects with custom development or external integrations, use at least DEV and UAT or PREPROD sandboxes.
- Use a custom profile or equivalent controlled access model for unit tests where the project requires it.
- Disable email sending in non-production environments to avoid accidental messages to end users.
- Optionally suffix email addresses with the environment name in lower environments.
- Confirm whether project tools such as `zProject` are part of the client-approved setup before installing anything.

## Lightning Configuration Recommendations

- Use Lightning pages as the default recommended view unless client standards differ.
- Separate Details, Related Lists, Chatter, and Activities into useful regions or tabs.
- Disable quick create when validation and field control cannot be guaranteed.
- Use separate loading of Related Lists when available to improve record page performance.
- Consider collapsible sections and record hover details where they improve usability.
