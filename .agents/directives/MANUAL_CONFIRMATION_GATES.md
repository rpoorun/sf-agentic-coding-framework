# Manual Confirmation Gates

## Purpose And Use

This file defines actions that require human approval in the current task before an agent proceeds. Read it before any Salesforce org write, Git write, destructive local action, dependency change, integration/auth change, or production-like system access. Put approval gates, confirmation-request format, analysis-only rules, and emergency stop conditions here.

## Always Require Confirmation

| Category | Actions requiring confirmation |
| --- | --- |
| Salesforce deploy | Real `sf project deploy start`, quick deploy, destructive deploy, metadata deploys from IDEs or scripts that modify org metadata. |
| Salesforce data | Anonymous Apex, data import, data export containing sensitive records, data update, data delete, bulk API, scripts that call REST/SOAP/Composite APIs with write access. |
| Salesforce access | Permission assignments, profile changes, permission set group changes, user activation/freezing, password or MFA changes, sharing rule changes. |
| Auth and integrations | Named Credentials, External Credentials, Connected Apps, certificates, SSO, remote site settings, CORS, CSP, integration endpoints. |
| Salesforce org config | Switching default org globally, changing dev hub, installing Salesforce CLI plugins, creating scratch orgs, deleting scratch orgs, changing org settings. |
| Git writes | Commit, push, merge, rebase, branch deletion, tag creation, worktree deletion, reset, restore, checkout that discards changes. |
| Destructive local actions | Recursive delete, force delete, overwriting tracked files from generated output, deleting generated-but-unreviewed work. |
| Dependencies and CI | Package install/update, lockfile rewrite, CI/CD pipeline changes, release automation changes. |
| Production-like systems | Any write operation against production, pre-production, UAT, client org, shared sandbox, or customer environment. |

## Confirmation Request Format

When asking for approval, include:

- Exact command or action.
- Target org, branch, or path.
- Expected files or metadata affected.
- Whether the action is reversible.
- Why the action is needed.

Example:

```text
Please confirm whether I should run the real deploy against {client}-{project}-dev using manifest/package_PROJ-123.xml. The validation has passed, and this action will update Salesforce metadata in the target org.
```

## Actions Allowed Without Confirmation

Unless the user has requested analysis-only mode, agents may usually:

- Read files.
- Search files.
- Inspect Git status and diffs.
- Run local static checks that do not install dependencies or call external systems.
- Run local PMD or static-analysis checks when the required tool is already installed and the command does not call an org service.
- Run Salesforce deploy dry-runs and deploy validations, such as `sf project deploy start --dry-run` or `sf project deploy validate`, when the target org and scope are known.
- Run Apex tests, such as `sf apex run test`, when the target org and test scope are known.
- Create or edit files for the requested task.
- Generate draft manifests, docs, or handoff notes.

Dry-runs, validation deploys, and Apex test runs do not require separate confirmation because they are verification actions. They must still be reported with the target org, command shape, and result. This permission to run without confirmation is independent from, and does not bypass, the mandatory pre-deploy conflict check and 95% Apex coverage gate in [DEPLOYMENT.md](../workflows/DEPLOYMENT.md) — a dry-run that fails the coverage gate is still a hard failure, not a confirmation-optional action.

## Analysis-Only Mode

When the user says any of the following, the agent must stay read-only:

- "analysis only"
- "analyse only"
- "do not modify"
- "do not change the repo"
- "do not change the org"
- "for now only review"

In analysis-only mode:

- Do not edit files.
- Do not retrieve metadata into tracked source.
- Do not stage files.
- Do not validate deploy or run org tests unless the user explicitly allows verification checks in analysis-only mode.
- Do not deploy.
- Do not commit.
- Do not run data mutations.

## Emergency Stop

Stop and ask the user when:

- The target org is unclear.
- The branch is not what the user expected.
- Required files contain unrelated user changes.
- A deploy or validation would include metadata outside the requested scope.
- A script would touch many files or records.
- Secrets or sensitive data are discovered.
- Before deleting any Salesforce metadata, first evaluate dependency impact using available "where is this used" evidence, source search, org metadata references, and deployment validation output as appropriate. If the metadata is referenced by other components, do not proceed with the delete or destructive package as-is. Identify the dependent components, propose the dependency-resolution change, and seek explicit verbal confirmation in chat before modifying those dependencies or attempting the destructive action again.
- A destructive metadata action to delete an existing field is blocked while the objective is to replace that field with a newly named field. In this case, do not continue by removing dependent references or forcing a replacement path. Pause and let the user resolve the field rename/replacement manually, unless they explicitly provide a new instruction for those dependencies.
