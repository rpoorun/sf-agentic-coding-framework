# Project Structure Guide

## Purpose And Use

This file documents the repository's durable structure and source orientation rules. Read it before changing Salesforce source, metadata, manifests, release documentation, or tooling configuration. Put verified repository paths, package layout, metadata locations, source-orientation checklists, and handoff expectations here.

This document helps agents orient themselves before changing source code. Adjust the examples to match the repository if the actual layout differs.

## Repository Map

Common Salesforce DX structure:

| Path | Purpose | Agent notes |
| --- | --- | --- |
| `sfdx-project.json` | Salesforce DX project definition and package directories. | Read this first to identify active package directories and `sourceApiVersion`. |
| `force-app/main/default/classes` | Apex classes and test classes. | Apex changes normally require matching tests. |
| `force-app/main/default/triggers` | Apex triggers. | Keep trigger logic thin; delegate to handler/service classes. |
| `force-app/main/default/lwc` | Lightning Web Components. | Check component metadata targets and parent wiring before changing behavior. |
| `force-app/main/default/aura` | Aura components. | Treat as legacy unless still wired into active pages. |
| `force-app/main/default/objects` | Objects, fields, record types, validation rules, compact layouts. | Avoid broad retrieve churn; edit only required metadata. |
| `force-app/main/default/flows` | Flow definitions. | Confirm active vs draft versions when org behavior matters. |
| `force-app/main/default/layouts` | Page layouts. | Layout metadata is noisy; keep diffs scoped. |
| `force-app/main/default/permissionsets` | Permission sets. | Confirm least-privilege access; do not assign users without approval. |
| `force-app/main/default/profiles` | Profiles. | Profile diffs are high-risk and often noisy. Avoid unless explicitly required. |
| `force-app/main/default/experiences` or `digitalExperiences` | Experience Cloud metadata. | Builder metadata can be fragile; validate page, route, and view scope carefully. |
| `manifest` | Package manifests for retrieve/deploy/validation. | Keep manifests task-specific. Do not use broad manifests for narrow tickets. |
| `deployment` | Deployment books, release inventories, manual handoff files. | Treat as release documentation, not generated noise. |
| `config/pmd` | Static-analysis rulesets. | PMD rules belong here unless the repo already has another convention. |
| `.agents` | Agent-facing instructions. | Keep this framework current when workflow, safety, standards, skills, or durable project facts change. |

## Standards Baseline

The project-wide Salesforce baseline is documented in [Salesforce project best practices](../standards/SALESFORCE_PROJECT_BEST_PRACTICES.md). Apply it unless the client, repository README, architecture decision record, or ticket explicitly defines a different convention.

## Orientation Checklist

Before editing:

- Identify the active branch and whether the working tree is clean.
- Identify the ticket or user-requested scope.
- Locate existing implementation patterns for the same layer.
- Search for references before deleting, renaming, or moving metadata.
- Check whether the change is Apex, metadata-only, UI-only, data-only, or a mix.
- Determine whether org comparison is required and whether the user approved org reads or writes.

## Salesforce Source Rules

- Prefer targeted retrieves and manifest-scoped changes.
- Do not normalize, reorder, or reformat entire metadata files unless that is the requested change.
- Do not commit retrieved metadata just because the org returned it.
- Do not mix unrelated metadata cleanup into feature work.
- For Experience Cloud, separate standard/system views from custom/public pages before deployment.
- For flows, record whether the source represents active, latest, or draft org behavior.

## Agent Handoff Format

When done, report:

- Changed files and why they changed.
- Metadata members affected.
- Local checks run.
- Org checks run, if approved.
- Manual steps still required.
- Known risks or assumptions.
