# Pull Request Workflow

## Purpose And Use

This file owns the repeatable pull request, final commit, back-merge, and review-readiness checklist for this project work. Read it before staging final changes, preparing a commit, opening a pull request, updating a pull request description, requesting review, or back-merging.

Put PR description requirements, review gates, pre-review checklist items, and handoff evidence here. Keep detailed coding standards in `.agents/standards` and mandatory permission gates in `.agents/directives`.

## Pull Request Description

Every pull request must include:

- A concise description of the functional and technical changes.
- The issue or Jira ticket number and link.
- The validation evidence available at the time of review.
- Any assumptions, deferred work, manual org steps, destructive changes, or follow-up deployment notes.

Use `.github/pull_request_template.md` when creating or updating a pull request description.

## Review-Readiness Gates

Before requesting review, verify the following gates that apply to the actual changed scope. Do not mark a checklist item complete unless it was checked in the repo, org, generated package, or test evidence.

### Scope And Staging

- Stage only files that belong to the ticket or approved refactor.
- Exclude retrieved noise, generated scratch files, local CLI state, logs, credentials, and unrelated metadata drift.
- Confirm deleted source components have a dedicated destructive changes package when deletion is intended.
- Do not hardcode user-facing UI messages, IDs, URLs, profile names, record type IDs, credentials, or org-specific values.
- Prefer deactivating or preserving backward-compatible API values over overwriting or deleting values that may be referenced by integrations or code.

### Validation, Matching, And Duplicate Rules

- Names follow the client/project language and casing convention.
- Avoid word-separating underscores in custom API names except approved prefixes and Salesforce suffixes such as `__c`.
- Custom metadata has a description that references the Jira ticket when the metadata type supports a description.
- Validation, matching, and duplicate rules have isolated positive and negative tests where testable.
- Run the narrowest meaningful regression tests for the affected rules, then broaden test scope when shared behavior or high-risk metadata is touched.

### New Or Updated Fields

- API names follow the project naming convention and avoid word-separating underscores unless the project explicitly approves them.
- Labels and API names use the client-approved language and casing convention.
- Field description includes the Jira reference and the business or integration purpose.
- Field-level security is granted to the Admin profile and applicable custom profiles or permission sets.
- Field placement is reviewed for relevant page layouts and Lightning record pages.
- Test factories and required-field setup are updated when common test data or mandatory fields change.

### Picklists And Global Value Sets

- New picklist API values are camel-cased or project-approved integration identifiers without spaces.
- API values avoid accented characters.
- Apex-referenced picklist values are represented as constants.
- Picklists that must become global value sets are manually converted in the target org before deployment when Salesforce requires a manual conversion step.
- Renamed or retired values are prefixed with `[Old]` and deactivated rather than deleted unless deletion is explicitly approved.
- Removed picklist values are also removed from code, formulas, flows, validation rules, reports, and configuration references.
- Relevant tests are run and Apex classes are recompiled when picklist references changed.

### Apex Classes And Methods

- New or changed Apex classes include the required class-level header comment where the project standard expects one.
- New or changed public, global, invocable, web-service, or complex methods include useful method-level documentation.
- Apex access is granted through the Admin profile and applicable custom profiles or permission sets when invocation requires metadata access.
- Code follows Salesforce best practices, PMD expectations, explicit sharing posture, and repository layering.
- SOQL, DML, and external calls are handled in the appropriate data/access layer for the local architecture.
- Deleted or commented methods include a Jira reference or clear removal explanation when retained as comments.
- Refactored classes are recompiled in the org before merge when that is part of the accepted release workflow.

### Apex Tests

- Every test method has at least one meaningful assertion.
- Test data is created through `@TestSetup` or a test factory when reusable setup is appropriate.
- Tests use `System.runAs` for user-context, permission, sharing, or portal behavior.
- Positive, negative, empty, and bulk scenarios are covered according to risk.
- Code coverage remains above the Salesforce minimum and does not regress meaningful behavior.
- Test factories are updated for common or required-field changes.

### Layouts And Lightning Pages

- Page layout and Lightning page names avoid special characters unless already required by the org convention.
- Page layout assignments, Lightning app/page activation, profile visibility, and permission-set impacts are reviewed.
- Field additions are placed only on relevant page layouts and Lightning pages.

### Integration And Web Services

- Web-service classes are exposed with the correct visibility and validate request bodies, query parameters, and required identifiers.
- Web-service responses use the project-approved response utility when one exists.
- Integration exchanges and exceptions use the project-approved logger when one exists and do not expose secrets or personal data.
- Wrapper classes validate data quality, required fields, and integrity constraints.
- Helper classes handle transformation and processing outside the transport layer.
- API access has a dedicated permission set where appropriate, including subclass, field, and object access.
- Web-service tests cover positive, negative, validation, logging/error, and permission scenarios.
- The endpoint contract is documented in Jira and exported in OpenAPI v2 format when required by the integration standard.

## Back-Merge And Final Commit Checklist

Before final commit, PR creation, or back-merge:

- Re-check `git status --short` and preserve unrelated user changes.
- Re-check the diff for scope, credentials, generated artifacts, and unrelated formatting churn.
- Confirm the PR template is complete and every checked box has evidence.
- Run or record the relevant tests, PMD/static checks, validations, or explain why they were not run.
- Capture manual follow-ups, skipped validations, org-only steps, destructive package requirements, and deployment order in the PR body or final handoff.

