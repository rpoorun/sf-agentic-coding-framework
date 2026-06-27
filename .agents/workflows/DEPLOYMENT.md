# Deployment Workflow

## Purpose And Use

This file owns the repeatable pre-deploy conflict-check and test-coverage gates for any Salesforce sandbox or org deployment. Read it before running `sf project deploy validate`, `sf project deploy start`, or any dry-run/quick-deploy variant. Put deployment-time conflict detection, org/local merge rules, and Apex coverage gates here; put the day-to-day Git/task sequence in [WORKFLOW.md](WORKFLOW.md), and the manual-approval gates for the deploy command itself in [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md).

## Pre-Deploy Conflict Check (Mandatory)

Before any deploy — dry-run, validate-only, or real — to any sandbox or org:

1. Identify the target org alias and the metadata scope (manifest, source-dir, or changed-file list) about to be deployed.
2. Retrieve the current org version of every metadata member in that scope (`sf project retrieve start` against the target org, scoped to the same manifest/members) and compare it against the local tracked version.
3. If the org and local versions match (no delta), proceed to the [Coverage Gate](#apex-test-coverage-gate-mandatory) below.
4. If the org is ahead of local — the org has elements, fields, picklist values, or logic not present in the local source — this is a conflict. Do not deploy local over the org as-is. Resolve it per [Conflict Resolution](#conflict-resolution) before continuing.

This check applies even when the user has not mentioned conflicts; do not skip it because a deploy "should" be clean.

## Conflict Resolution

When the org is ahead of local (org-only elements exist that local does not have):

1. Merge so that the org-only elements are preserved and the new local elements are added — never let the deploy silently drop or override an existing org feature that is outside the current requirement's scope.
2. The merge target is the **local working tree**, not the deploy payload directly: bring the org-only delta into local source first (e.g. merge retrieved picklist values, fields, or layout items into the local file), so the deployed result is org-state-plus-new-elements, not local-only.
3. Once merged locally, apply the [Scoped Staging Workflow](WORKFLOW.md#scoped-staging-workflow): when committing or staging the merge, select and stage only the lines relevant to the current requirement. Do not stage or commit the org-retrieved delta itself as if it were part of this change — it is there to prevent the deploy from overriding the org, not to become part of this ticket's diff. Note explicitly in the handoff which lines came from the org merge vs. the requirement.
4. If the conflict is a straightforward additive merge (org added unrelated picklist values/fields, local adds different unrelated picklist values/fields, no overlap), proceed without asking.
5. If resolving the conflict requires deciding between two values for the *same* element (the org and local both changed the same field/value/logic differently), or any override risk cannot be confidently ruled out, **stop and ask the user** before merging or deploying. State: which element conflicts, the org value, the local value, and what each resolution choice would do to the org's existing feature. Do not guess.

## Apex Test Coverage Gate (Mandatory)

This gate applies to **every** deploy of Apex — including dry-run and validate-only deploys, not just real deploys:

1. Identify every Apex class/trigger in the deploy scope and its associated test class(es) (see `sf-platform-test` for what "associated" means).
2. Run those test classes as part of the dry-run/validate-only step and again as part of the real deploy step — never validate or deploy Apex without executing its associated tests in that same step.
3. Read the resulting code coverage for the deployed Apex.
4. If coverage is below **95%** for any class/trigger in scope, treat this as a hard failure: raise an error and cancel the deployment — including the dry-run/validate-only step. Do not proceed to a real deploy on the basis of a dry-run that itself failed this gate, and do not deploy "anyway" because the org's org-wide default (typically 75%) would technically allow it. This project's bar is 95%, not the Salesforce platform minimum.
5. Report the exact coverage percentage per class and which class(es) caused the failure; do not just report "coverage too low."
6. Fixing a coverage shortfall is implementation work like any other change — generate or extend tests via `sf-platform-test`, then re-run this gate. Do not lower the threshold or skip the gate to make a deploy succeed.

## Reporting

Every deploy-related report (dry-run, validate, or real deploy) must state: target org/alias, scope deployed, pre-deploy conflict check result (clean / merged / escalated), and the coverage-gate result (pass with percentages, or fail with cause) — per [MANUAL_CONFIRMATION_GATES.md](../directives/MANUAL_CONFIRMATION_GATES.md), dry-runs and validations do not need separate approval to *run*, but their results, including a coverage-gate failure, must always be reported before any further deploy action is taken.
