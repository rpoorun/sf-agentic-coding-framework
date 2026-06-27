---
name: sf-platform-data
description: "Salesforce data operations with 130-point scoring. Use this skill to create, update, delete, bulk import/export, generate test data, and clean up org records using sf CLI and anonymous Apex. TRIGGER when: user creates test data, performs bulk import/export, uses sf data CLI commands, needs data factory patterns for Apex tests, or needs to seed/clean records in a Salesforce org. DO NOT TRIGGER when: SOQL query writing only (use platform-soql-query), Apex test execution (use platform-apex-test-run), or metadata deployment (use platform-metadata-deploy)."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-data-manage
    - Clientell-Ai/salesforce-skills :: sf-data
---

# sf-platform-data: Data Management

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-data` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-data-manage; Clientell-Ai/salesforce-skills :: sf-data |

Use this skill when the user needs **Salesforce data work**: record CRUD, bulk import/export, test data generation, cleanup scripts, or data factory patterns for validating Apex, Flow, or integration behavior.

## When This Skill Owns the Task

Use `platform-data-manage` when the work involves:
- `sf data` CLI commands
- record creation, update, delete, upsert, export, or tree import/export
- realistic test data generation
- bulk data operations and cleanup
- Apex anonymous scripts for data seeding / rollback

Delegate elsewhere when the user is:
- writing SOQL only → [platform-soql-query](../platform-soql-query/SKILL.md)
- running or repairing Apex tests → [platform-apex-test-run](../platform-apex-test-run/SKILL.md)
- deploying metadata first → [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md)
- creating or modifying custom objects / fields → [platform-custom-object-generate](../platform-custom-object-generate/SKILL.md) or [platform-custom-field-generate](../platform-custom-field-generate/SKILL.md)

---

## Important Mode Decision

Confirm which mode the user wants:

| Mode | Use when |
|---|---|
| Script generation | they want reusable `.apex`, CSV, or JSON assets without touching an org yet |
| Remote execution | they want records created / changed in a real org now |

Do not assume remote execution if the user may only want scripts.

---

## Required Context to Gather First

Ask for or infer:
- target object(s)
- org alias, if remote execution is required
- operation type: query, create, update, delete, upsert, import, export, cleanup
- expected volume
- whether this is test data, migration data, or one-off troubleshooting data
- any parent-child relationships that must exist first

---

## Core Operating Rules

- `platform-data-manage` acts on **remote org data** unless the user explicitly wants local script generation.
- Objects and fields must already exist before data creation.
- For automation testing, prefer **251+ records** when bulk behavior matters.
- Plan cleanup before creating large or noisy datasets — untracked records accumulate across runs and pollute org state.
- Use synthetic, non-identifying data in test records — real PII creates compliance risk and cannot be safely removed after bulk import.
- Prefer **CLI-first** for straightforward CRUD; use anonymous Apex when the operation truly needs server-side orchestration.

If metadata is missing, stop and hand off to:
- [platform-custom-object-generate](../platform-custom-object-generate/SKILL.md) or [platform-custom-field-generate](../platform-custom-field-generate/SKILL.md) to create the missing schema, then [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md) to deploy it before retrying the data operation

---

## Recommended Workflow

### 1. Verify prerequisites
Confirm object / field availability, org auth, and required parent records.

### 2. Run describe-first pre-flight validation when schema is uncertain
Before creating or updating records, use object describe data to validate:
- required fields
- createable vs non-createable fields
- picklist values
- relationship fields and parent requirements

See [references/sf-cli-data-commands.md](references/sf-cli-data-commands.md) for the `sf sobject describe` command and jq filter patterns for inspecting fields, picklist values, and createable constraints.

### 3. Choose the smallest correct mechanism
| Need | Default approach |
|---|---|
| small one-off CRUD | `sf data` single-record commands |
| large import/export | Bulk API 2.0 via `sf data ... bulk` |
| parent-child seed set | tree import/export |
| reusable test dataset | factory / anonymous Apex script |
| reversible experiment | cleanup script or savepoint-based approach |

### 4. Execute or generate assets
Use the built-in templates under `assets/` when they fit:
- `assets/factories/`
- `assets/bulk/`
- `assets/cleanup/`
- `assets/soql/`
- `assets/csv/`
- `assets/json/`

### 5. Verify results
Check counts, relationships, and record IDs after creation or update.

### 6. Apply a bounded retry strategy
If creation fails:
1. try the primary CLI shape once
2. retry once with corrected parameters
3. re-run describe / validate assumptions
4. pivot to a different mechanism or provide a manual workaround

Do **not** repeat the same failing command indefinitely.

### 7. Leave cleanup guidance
Provide exact cleanup commands or rollback assets whenever data was created.

---

## High-Signal Rules

### Bulk safety
- use bulk operations for large volumes
- test automation-sensitive behavior with 251+ records where appropriate
- avoid one-record-at-a-time patterns for bulk scenarios

### Data integrity
- include required fields
- validate picklist values before creation
- verify parent IDs and relationship integrity
- account for validation rules and duplicate constraints
- exclude non-createable fields from input payloads

### Cleanup discipline
Prefer one of:
- delete-by-ID
- delete-by-pattern
- delete-by-created-date window
- rollback / savepoint patterns for script-based test runs

---

## Common Failure Patterns

| Error | Likely cause | Default fix direction |
|---|---|---|
| `INVALID_FIELD` | wrong field API name or FLS issue | verify schema and access |
| `REQUIRED_FIELD_MISSING` | mandatory field omitted | include required values from describe data |
| `INVALID_CROSS_REFERENCE_KEY` | bad parent ID | create / verify parent first |
| `FIELD_CUSTOM_VALIDATION_EXCEPTION` | validation rule blocked the record | use valid test data or adjust setup |
| invalid picklist value | guessed value instead of describe-backed value | inspect picklist values first |
| non-writeable field error | field is not createable / updateable | remove it from the payload |
| bulk limits / timeouts | wrong tool for the volume | switch to bulk / staged import |

---

## Output Format

When finishing, report in this order:
1. **Operation performed**
2. **Objects and counts**
3. **Target org or local artifact path**
4. **Record IDs / output files**
5. **Verification result**
6. **Cleanup instructions**

Suggested shape:

```text
Data operation: <create / update / delete / export / seed>
Objects: <object + counts>
Target: <org alias or local path>
Artifacts: <record ids / csv / apex / json files>
Verification: <passed / partial / failed>
Cleanup: <exact delete or rollback guidance>
```

---

## Cross-Skill Integration

| Need | Delegate to | Reason |
|---|---|---|
| create missing custom objects | [platform-custom-object-generate](../platform-custom-object-generate/SKILL.md) | schema must exist before data operations |
| create missing custom fields | [platform-custom-field-generate](../platform-custom-field-generate/SKILL.md) | field-level schema must exist before data creation |
| run bulk-sensitive Apex validation | [platform-apex-test-run](../platform-apex-test-run/SKILL.md) | test execution and coverage |
| deploy missing schema first | [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md) | metadata readiness |
| implement production Apex logic consuming the data | [platform-apex-generate](../platform-apex-generate/SKILL.md) | Apex class / trigger authoring |
| implement Flow logic consuming the data | [automation-flow-generate](../automation-flow-generate/SKILL.md) | Flow authoring and automation |

---

## Reference Map

### Start here
- [references/sf-cli-data-commands.md](references/sf-cli-data-commands.md)
- [references/test-data-best-practices.md](references/test-data-best-practices.md)
- [references/orchestration.md](references/orchestration.md)
- [references/test-data-patterns.md](references/test-data-patterns.md)
- [references/test-data-factory-usage.md](references/test-data-factory-usage.md)

### Query / bulk / cleanup
- [references/soql-relationship-guide.md](references/soql-relationship-guide.md)
- [references/relationship-query-examples.md](references/relationship-query-examples.md)
- [references/bulk-operations-guide.md](references/bulk-operations-guide.md)
- [references/cleanup-rollback-guide.md](references/cleanup-rollback-guide.md)
- [references/cleanup-rollback-example.md](references/cleanup-rollback-example.md)

### Examples / limits
- [references/crud-workflow-example.md](references/crud-workflow-example.md)
- [references/bulk-testing-example.md](references/bulk-testing-example.md)
- [references/anonymous-apex-guide.md](references/anonymous-apex-guide.md)
- [references/governor-limits-reference.md](references/governor-limits-reference.md)

### Validation scripts
- [scripts/soql_validator.py](scripts/soql_validator.py) — validate SOQL queries before execution
- [scripts/validate_data_operation.py](scripts/validate_data_operation.py) — pre-flight check for data operations (required fields, picklist values, createable fields)

### Asset templates
- `assets/factories/` — Apex test data factory scripts (account, contact, opportunity, lead, user, etc.)
- `assets/bulk/` — Bulk API 2.0 Apex templates (insert 200, 500, 10000 records; upsert by external ID)
- `assets/cleanup/` — Cleanup and rollback scripts (delete by name, date, pattern; transaction rollback)
- `assets/soql/` — SOQL query templates (aggregate, subquery, parent-to-child, child-to-parent, polymorphic)
- `assets/csv/` — CSV import templates for Account, Contact, Opportunity, custom objects
- `assets/json/` — JSON tree import templates (account-contact, account-opportunity, full hierarchy)

---

## Score Guide

| Score | Meaning |
|---|---|
| 117+ | strong production-safe data workflow |
| 104–116 | good operation with minor improvements possible |
| 91–103 | acceptable but review advised |
| 78–90 | partial / risky patterns present |
| < 78 | blocked until corrected |

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `sf-data` (Clientell-Ai/salesforce-skills :: sf-data)

# Data Migration & Management

You are a Salesforce data specialist. Handle data operations safely and efficiently.

## Data Operations

### Query and Export
```bash
# Query records
sf data query -q "SELECT Id, Name, Industry FROM Account WHERE Industry != null LIMIT 100" --target-org myOrg

# Export to CSV
sf data query -q "SELECT Id, Name, Industry FROM Account" --target-org myOrg --result-format csv > accounts.csv

# Export to JSON
sf data query -q "SELECT Id, Name FROM Account" --target-org myOrg --result-format json > accounts.json

# Bulk query (large datasets)
sf data query -q "SELECT Id, Name FROM Account" --target-org myOrg --bulk
```

### Import and Upsert
```bash
# Insert records from CSV
sf data import tree -f data/accounts.json --target-org myOrg

# Bulk upsert
sf data upsert bulk -s Account -f accounts.csv -i External_Id__c --target-org myOrg

# Insert with plan (preserves relationships)
sf data import tree -p data/plan.json --target-org myOrg
```

### Data Plan for Related Records
```json
[
    {
        "sobject": "Account",
        "saveRefs": true,
        "resolveRefs": false,
        "files": ["Account.json"]
    },
    {
        "sobject": "Contact",
        "saveRefs": false,
        "resolveRefs": true,
        "files": ["Contact.json"]
    }
]
```

### Sandbox Seeding Script
```bash
#!/bin/bash
# seed-sandbox.sh — Create test data in a sandbox

ORG_ALIAS="${1:-sandbox}"

echo "Seeding data in $ORG_ALIAS..."

# Insert accounts
sf data import tree -f data/seed/accounts.json --target-org "$ORG_ALIAS"

# Insert contacts (references accounts)
sf data import tree -f data/seed/contacts.json --target-org "$ORG_ALIAS"

# Insert opportunities
sf data import tree -f data/seed/opportunities.json --target-org "$ORG_ALIAS"

echo "Seeding complete."
```

### Anonymous Apex for Data Setup
```bash
# Run anonymous Apex for complex data setup
sf apex run -f scripts/seed-data.apex --target-org myOrg
```

```apex
// scripts/seed-data.apex
List<Account> accounts = new List<Account>();
for (Integer i = 0; i < 100; i++) {
    accounts.add(new Account(
        Name = 'Test Account ' + i,
        Industry = 'Technology',
        BillingState = 'CA'
    ));
}
insert accounts;
System.debug('Inserted ' + accounts.size() + ' accounts');
```

## Data Cleanup
```bash
# Delete records matching criteria
sf data delete bulk -s Account -f delete-ids.csv --target-org myOrg

# Delete all records of a type (careful!)
sf data query -q "SELECT Id FROM TempObject__c" --target-org myOrg --result-format csv > to-delete.csv
sf data delete bulk -s TempObject__c -f to-delete.csv --target-org myOrg
```

### Bulk API 2.0
Use for datasets >2,000 records. Significantly faster than standard API.
```bash
# Bulk upsert from CSV
sf data upsert bulk -s Account -f accounts.csv -i External_Id__c --target-org myOrg

# Bulk delete from CSV (Id column required)
sf data delete bulk -s Account -f delete-ids.csv --target-org myOrg

# Check job status
sf data bulk results -i <jobId> --target-org myOrg
```
- Job timeout: 10 minutes for ingest, 15 minutes for query
- Max file size: 150 MB per CSV
- Max 150M records per 24-hour rolling window

### External ID Best Practices
- Choose fields that are **unique across source and target orgs**
- Mark as External ID AND Unique for upsert idempotency
- Cannot use masked fields as external IDs (Data Mask limitation)
- For cross-org sync: use a UUID or composite key (OrgId + RecordId)

### Relationship Loading Order
1. Independent objects (no required lookups)
2. Parent objects (Account before Contact)
3. Master-detail parents MUST exist before child insert
4. Junction objects (M2M) load after both parent objects
5. Self-referential records: two-pass load (insert without self-ref, then update)

### Record Type Mapping
- Export record type developer names (not IDs) — IDs differ between orgs
- Validate picklist values exist in target before loading
- Map with: `sf data query -q "SELECT Id, DeveloperName FROM RecordType WHERE SObjectType='Account'"`

### File Migration (ContentVersion)
```apex
ContentVersion cv = new ContentVersion();
cv.Title = 'My File';
cv.PathOnClient = 'myfile.pdf';
cv.VersionData = Blob.valueOf('file content'); // or Base64-decoded
insert cv;
```
- ContentDocumentLink associates files with records
- Max file size: 2 GB (Salesforce Files)
- Attachments (legacy) → migrate to ContentVersion

## Rules
- Always verify target org before data operations
- Use `--dry-run` or `LIMIT` clauses when testing queries
- Preserve referential integrity — load parent records before children
- Use External IDs for upsert operations to avoid duplicates
- Back up data before destructive operations
- Use Bulk API for datasets > 200 records

## Gotchas
- Master-detail parent record MUST exist before child insert — otherwise `ENTITY_IS_DELETED` or `REQUIRED_FIELD_MISSING`
- External ID fields **cannot be masked** in Salesforce Data Mask
- Bulk API jobs timeout after 10-15 minutes — split large datasets
- Polymorphic lookups (e.g., Task.WhatId) need `TYPEOF` in export queries
- ContentVersion requires `PathOnClient` AND `VersionData` — both mandatory
- Self-referential records (e.g., Account.ParentId) require two-pass load
- Bulk API 2.0 returns success for the job even if individual records fail — always check results
- Data Loader truncates field values silently if they exceed field length

## References
- [Data Patterns](references/data-patterns.md) — Bulk API 2.0, Composite API, tree export, external IDs, large data volumes, Big Objects, file upload, multi-currency, ETL, backup/recovery

## Workflow
1. Verify target org connection
2. Analyze data requirements (objects, relationships, volume)
3. Export or generate source data
4. Create import plan with correct object order
5. Execute import with appropriate method (tree, bulk, anonymous Apex)
6. Verify data integrity post-import
