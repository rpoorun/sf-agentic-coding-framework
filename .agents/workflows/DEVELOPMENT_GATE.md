# Development Gate

## Purpose And Use

This file owns the mandatory self-checklist that must be completed at two checkpoints: **Gate A — before any deployment manifest is generated** (the `build {KEY}` command, step 6 in [PROJECT_TRACKING.MD](PROJECT_TRACKING.MD)), and **Gate B — before any deployment is executed** (the `deploy {KEY}` command, before the user-confirmation request required by [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md)).

This gate checks the **content quality** of what will be deployed — naming, descriptions, access, tests, references. It is complementary to, and does not replace, the org-level gates in [DEPLOYMENT.md](DEPLOYMENT.md) (environment config check, pre-deploy conflict check, 95% Apex coverage gate). The review-readiness gates in [PULL_REQUEST.md](PULL_REQUEST.md) cover the same quality themes at review time — a completed Development Gate record is valid evidence for the overlapping PR checklist items.

## How To Run This Gate

1. **Determine applicability** — identify the metadata types in the ticket's change scope. Only the checklist sections that match the changed scope apply; mark every other section `N/A` explicitly. An empty applicability assessment is not allowed — every section is either checked or marked `N/A` with a one-line reason.
2. **Verify with evidence** — never tick an item from memory or assumption. Each ticked item must have been verified in the repo, the org, the generated package, or test output, and the record must name that evidence (file path, org component, test run ID, or diff).
3. **Record the result** — write the completed checklist (ticked items with evidence, `N/A` sections with reasons, failures with cause) into the ticket file's **Deployment & Validation Plan** section per [PROJECT_TRACKING.MD](PROJECT_TRACKING.MD).
4. **Block on failure** — any applicable item that cannot be ticked is a blocker:
   - At **Gate A**: do not generate the deployment manifest. Fix the failing item (or escalate to the user if the fix needs a decision) and re-run the gate.
   - At **Gate B**: do not request deploy confirmation and do not deploy. Report the failing item(s) to the user with the exact component and cause.
5. **Gate B re-verification** — Gate B does not blindly trust Gate A. Re-verify any item whose subject changed after the manifest was built (new commits, org drift found by the pre-deploy conflict check, manual org steps performed). If nothing changed, Gate B confirms the Gate A record is still current and checks the manifest itself (see [Manifest Integrity](#manifest-integrity-gate-b-only)).

---

## Plan And Risk Review

Before Gate A for non-trivial work, confirm there is evidence from [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for:

- Requirement discovery: accepted source, user intent, constraints, and exclusions are recorded.
- Plan review: the selected approach was checked from product, engineering, design/UX, security, test, and deployment perspectives that apply to the scope.
- Risk review: high-risk operations, large refactors, destructive metadata, production impact, data mutation, and branch/release actions are named with the relevant confirmation gate.
- Scope reduction: simpler declarative, standard platform, or existing-code options were considered before new code or metadata was generated.

If plan evidence is missing, pause Gate A and produce the smallest plan-review note needed to support the manifest. Do not use this checkpoint to create process theater for a trivial one-line fix; mark it `N/A - trivial scoped change` with the source evidence.

---

## Best Practice Checklist

### Validation, Matching, And Duplicate Rules

- [ ] No word-separating underscores in API names apart from approved prefixes and Salesforce suffixes such as `__c`
- [ ] Labels and API names use the client-approved language and casing convention (e.g. a French-language org uses French, camel-cased names — see the project [GLOSSARY.md](../documentation/GLOSSARY.md))
- [ ] Rule has a description referencing the Jira ticket number
- [ ] Isolated test classes exist for positive and negative testing of the rule
- [ ] Relevant regression tests were run to confirm the rule causes no regression (narrowest meaningful scope first, broadened when shared behavior is touched)

### New Or Updated Fields

- [ ] No word-separating underscores in API names apart from approved prefixes and Salesforce suffixes such as `__c`
- [ ] Labels and API names use the client-approved language and casing convention
- [ ] Field description references the Jira ticket number and the business or integration purpose
- [ ] FLS granted on the Admin profile and applicable custom profiles and/or permission sets
- [ ] Field added to the relevant page layouts and Lightning pages where applicable
- [ ] Test factory and mandatory-field setup updated for common/required fields

#### New Picklist Values

- [ ] New picklist value API names are camel-cased (or project-approved integration identifiers) with no spaces
- [ ] No accented characters in API names
- [ ] Apex-referenced picklists and picklist values are represented as constants (see [APEX_CONSTANTS_FRAMEWORK.md](../standards/APEX_CONSTANTS_FRAMEWORK.md))

#### Picklist Converted To Global Value Set

- [ ] Picklist manually converted in the target org **prior** to deployment (Salesforce requires the manual conversion step — flag this as a pre-deploy manual step in the manifest)

#### Renamed Or Deactivated Picklist Values

- [ ] Label prefixed with `[Old]` and value deactivated rather than deleted (deletion only with explicit approval)
- [ ] Retired picklist API value references removed from code, formulas, flows, validation rules, reports, and configuration
- [ ] Relevant regression tests run for the affected picklist references
- [ ] Referencing Apex classes recompiled

### New Or Updated Apex Classes

- [ ] Class-level header comment present per [SALESFORCE_APEX_STANDARDS.md](../standards/SALESFORCE_APEX_STANDARDS.md)
- [ ] Method-level documentation present for public, global, invocable, web-service, or complex methods
- [ ] Apex access granted on the Admin profile and applicable custom profiles and/or permission sets where invocation requires it

### New Or Updated Apex Methods

- [ ] Method-level header comment present
- [ ] Code logic reviewed against Salesforce best practices, PMD expectations, and explicit sharing posture
- [ ] SOQL, DML, and external calls live in the appropriate data/access layer for the local architecture (e.g. DM/EM layers where the project uses them)

#### Deleted Or Commented Apex Methods

- [ ] Removal comment includes the Jira reference or a clear removal explanation
- [ ] Test classes reviewed and run to confirm no regression

#### Refactored Apex Methods

- [ ] Class-level and method-level header comments updated
- [ ] Apex access re-verified on the Admin profile and applicable custom profiles and/or permission sets
- [ ] Refactored classes recompiled in the org prior to merge when that is part of the accepted release workflow

### Apex Test Classes

- [ ] Every test method has at least one meaningful assertion
- [ ] Test data created through `@TestSetup` or a test factory where reusable setup is appropriate
- [ ] Tests use `System.runAs` for user-context, permission, sharing, or portal behavior
- [ ] Code coverage meets the framework's **95% gate** for every class/trigger in scope (this project's bar per [DEPLOYMENT.md](DEPLOYMENT.md#apex-test-coverage-gate-mandatory) — not the Salesforce 75% platform minimum)
- [ ] Test factory updated for common/required-field changes

### Page Layouts And Lightning Pages

- [ ] No special characters in page layout / Lightning page names unless already required by the org convention
- [ ] Page layout assignments verified on profiles and permission sets
- [ ] Lightning app/page activation and visibility impacts reviewed

### General Best Practices

- [ ] Only evolutions and changes related to the ticket are staged (per the [Scoped Staging Workflow](WORKFLOW.md#scoped-staging-workflow))
- [ ] No hardcoded user-facing UI messages, IDs, URLs, profile names, record type IDs, credentials, or org-specific values
- [ ] Previous picklist API values deactivated instead of overwritten when they may be referenced by integrations or code
- [ ] Components deleted from source have a dedicated destructive changes package (and the dependency-impact evaluation in [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md#emergency-stop) was performed)

---

## Apex Framework Checklist

### Async Apex

- [ ] Async mechanism choice (Queueable / `@future` / Batchable / Platform Event) matches the atomicity and retry requirements (see the decision guidance in [sf-platform-deploy trigger safety](../skills/sf-platform-deploy/references/trigger-deployment-safety.md))
- [ ] Async paths are covered by tests, including failure/retry behavior where testable

### Integration — Web Services

- [ ] WS class exposed with the correct visibility and includes request-body / query-parameter validations
- [ ] WS class uses the project-approved response utility to handle responses (e.g. `UTIL_WebService`) when one exists
- [ ] WS class uses the project-approved logger (e.g. `UTIL_Logger`) to log exchanges and exceptions, without exposing secrets or personal data
- [ ] Wrapper class includes data validation, data quality, and integrity checks
- [ ] Data processing and manipulation handled by a helper class, outside the transport layer
- [ ] Dedicated permission set for API access, including sub-class, field, and object access
- [ ] WS tests cover all of the above plus positive and negative scenarios
- [ ] WS endpoint exported in OpenAPI v2 format and documented in Jira when required by the integration standard

---

## Manifest Integrity (Gate B Only)

Before requesting deploy confirmation, verify the manifest artifact itself:

- [ ] Every component in the manifest exists in the local working tree and matches the state that passed the Gate A dry-run
- [ ] No component in the deploy scope is missing from the manifest (compare against the ticket's file scope and `git status`)
- [ ] Pre-deploy and post-deploy manual steps recorded in the manifest are acknowledged (and completed where they must precede the deploy, e.g. global value set conversion)
- [ ] Destructive changes, if any, are in a dedicated destructive package and were explicitly approved

## Reporting

The gate result presented to the user (in chat at Gate B, and in the ticket file at both gates) must state: which sections applied, which were `N/A` and why, the evidence for each ticked item, and — on failure — the exact failing item, component, and cause. Do not compress a gate failure into a one-line status; the user needs enough detail to decide, per the decision-point exception in [AGENT_GUARDRAILS.md](../directives/AGENT_GUARDRAILS.md#chat-brevity-while-working).
