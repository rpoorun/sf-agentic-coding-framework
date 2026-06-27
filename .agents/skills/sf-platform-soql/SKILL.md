---
name: sf-platform-soql
description: "SOQL query generation, optimization, and analysis with 100-point scoring. Use this skill when the user needs SOQL/SOSL authoring or optimization: natural-language-to-query generation, relationship queries, aggregates, query-plan analysis, and performance or safety improvements for Salesforce queries. TRIGGER when: user writes, optimizes, or debugs SOQL/SOSL queries, touches .soql files, or asks about relationship queries, aggregates, or query performance. DO NOT TRIGGER when: bulk data operations (use platform-data-manage), Apex DML logic (use platform-apex-generate), or report/dashboard queries."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-soql-query
    - Clientell-Ai/salesforce-skills :: sf-soql
---

# sf-platform-soql: SOQL/SOSL Query Design

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-soql` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-soql-query; Clientell-Ai/salesforce-skills :: sf-soql |

Use this skill when the user needs **SOQL/SOSL authoring or optimization**: natural-language-to-query generation, relationship queries, aggregates, query-plan analysis, and performance/safety improvements for Salesforce queries.

## When This Skill Owns the Task

Use `platform-soql-query` when the work involves:
- `.soql` files
- query generation from natural language
- relationship queries and aggregate queries
- query optimization and selectivity analysis
- SOQL/SOSL syntax and governor-aware design

Delegate elsewhere when the user is:
- performing bulk data operations → [platform-data-manage](../platform-data-manage/SKILL.md)
- embedding query logic inside broader Apex implementation → [platform-apex-generate](../platform-apex-generate/SKILL.md)
- debugging via logs rather than query shape → [platform-apex-logs-debug](../platform-apex-logs-debug/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- target object(s)
- fields needed
- filter criteria
- sort / limit requirements
- whether the query is for display, automation, reporting-like analysis, or Apex usage
- whether performance / selectivity is already a concern

---

## Recommended Workflow

### 1. Generate the simplest correct query
Prefer:
- only needed fields
- clear WHERE criteria
- reasonable LIMIT when appropriate
- relationship depth only as deep as necessary

### 2. Choose the right query shape
| Need | Default pattern |
|---|---|
| parent data from child | child-to-parent traversal |
| child rows from parent | subquery |
| counts / rollups | aggregate query |
| records with / without related rows | semi-join / anti-join |
| text search across objects | SOSL |

### 3. Optimize for selectivity and safety
Check:
- indexed / selective filters
- no unnecessary fields
- no avoidable wildcard or scan-heavy patterns
- security enforcement expectations

### 4. Validate execution path if needed
If the user wants runtime verification, hand off execution to:
- [platform-data-manage](../platform-data-manage/SKILL.md)

---

## High-Signal Rules

- never use `SELECT *` style thinking; query only required fields
- do not query inside loops in Apex contexts
- prefer filtering in SOQL rather than post-filtering in Apex
- use aggregates for counts and grouped summaries instead of loading unnecessary records
- evaluate wildcard usage carefully; leading wildcards often defeat indexes
- account for security mode / field access requirements when queries move into Apex

---

## Output Format

When finishing, report in this order:
1. **Query purpose**
2. **Final SOQL/SOSL**
3. **Why this shape was chosen**
4. **Optimization or security notes**
5. **Execution suggestion if needed**

Suggested shape — use `references/soql-syntax-reference.md` for exact syntax:

```
Query goal: <summary>
Query: <soql or sosl>
Design: <relationship / aggregate / filter choices>
Notes: <selectivity, limits, security, governor awareness>
Next step: <run in platform-data-manage or embed in Apex>
```

---

## Cross-Skill Integration

| Need | Delegate to | Reason |
|---|---|---|
| run the query against an org | [platform-data-manage](../platform-data-manage/SKILL.md) | execution and export |
| embed the query in services/selectors | [platform-apex-generate](../platform-apex-generate/SKILL.md) | implementation context |
| analyze slow-query symptoms from logs | [platform-apex-logs-debug](../platform-apex-logs-debug/SKILL.md) | runtime evidence |
| wire query-backed UI | [experience-lwc-generate](../experience-lwc-generate/SKILL.md) | frontend integration |

---

## Score Guide

| Score | Meaning |
|---|---|
| 90+ | production-optimized query |
| 80–89 | good query with minor improvements possible |
| 70–79 | functional but performance concerns remain |
| < 70 | needs revision before production use |

---

## Reference File Index

| File | When to read |
|------|-------------|
| `references/soql-syntax-reference.md` | Syntax, operators, date literals, relationship query patterns |
| `references/query-optimization.md` | Selectivity rules, indexing strategy, governor limits, security patterns |
| `references/soql-reference.md` | Quick reference — operators, date functions, aggregate functions, WITH clauses |
| `references/anti-patterns.md` | Common SOQL mistakes and their fixes — read before finalizing any query |
| `references/selector-patterns.md` | Apex selector layer patterns — read when embedding queries in Apex classes |
| `references/field-coverage-rules.md` | Field coverage validation — read when generating SOQL used inside Apex code |
| `references/cli-commands.md` | sf CLI query execution, bulk export, query plan commands |
| `assets/basic-queries.soql` | Starter query examples for common objects |
| `assets/relationship-queries.soql` | Parent-to-child and child-to-parent relationship query patterns |
| `assets/aggregate-queries.soql` | COUNT, SUM, GROUP BY, ROLLUP query patterns |
| `assets/optimization-patterns.soql` | Selective filter and index-aware query patterns |
| `assets/bulkified-query-pattern.cls` | Apex Map-based bulk query pattern for trigger contexts |
| `assets/selector-class.cls` | Full selector class implementation template |
| `scripts/post-tool-validate.py` | Post-write hook — runs static SOQL validation and live query plan analysis after `.soql` file edits |

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `sf-soql` (Clientell-Ai/salesforce-skills :: sf-soql)

# SOQL Query Builder & Optimizer

You are a Salesforce SOQL specialist. Build optimized, secure queries.

## Security First
- ALWAYS use `WITH USER_MODE` to enforce CRUD/FLS
- NEVER use string concatenation for dynamic SOQL — use bind variables
- Use `Database.query()` only when dynamic queries are truly needed

```apex
// GOOD
List<Account> accounts = [
    SELECT Id, Name, Industry
    FROM Account
    WHERE Industry = :industryFilter
    WITH USER_MODE
    LIMIT 200
];

// BAD — injection risk
String query = 'SELECT Id FROM Account WHERE Name = \'' + userInput + '\'';
```

## Query Patterns

### Parent-to-Child (Subquery)
```sql
SELECT Id, Name,
    (SELECT Id, FirstName, LastName FROM Contacts)
FROM Account
WHERE Industry = 'Technology'
WITH USER_MODE
```

### Child-to-Parent (Dot Notation)
```sql
SELECT Id, FirstName, Account.Name, Account.Industry
FROM Contact
WHERE Account.Industry = 'Technology'
WITH USER_MODE
```

### Aggregate Queries
```sql
SELECT Industry, COUNT(Id) cnt, SUM(AnnualRevenue) totalRevenue
FROM Account
WHERE Industry != null
WITH USER_MODE
GROUP BY Industry
HAVING COUNT(Id) > 5
ORDER BY COUNT(Id) DESC
```

### Polymorphic (TYPEOF)
```sql
SELECT Id, Subject,
    TYPEOF What
        WHEN Account THEN Name, Industry
        WHEN Opportunity THEN Name, StageName, Amount
    END
FROM Task
WITH USER_MODE
```

### Semi-Joins and Anti-Joins
```sql
-- Semi-join: Accounts WITH contacts
SELECT Id, Name FROM Account
WHERE Id IN (SELECT AccountId FROM Contact)
WITH USER_MODE

-- Anti-join: Accounts WITHOUT opportunities
SELECT Id, Name FROM Account
WHERE Id NOT IN (SELECT AccountId FROM Opportunity)
WITH USER_MODE
```

### SOSL (Search Language)
Use SOSL for full-text search across multiple objects:
```sql
FIND {SearchTerm} IN ALL FIELDS
RETURNING Account(Id, Name WHERE Industry = 'Tech'),
          Contact(Id, FirstName, LastName)
LIMIT 20
```
- Use SOSL when: searching text across objects, fuzzy matching, partial words
- Use SOQL when: exact matches, relationship queries, aggregates, DML-related queries
- Governor limit: 20 SOSL queries per transaction

### Date Literals
| Literal | Meaning |
|---------|---------|
| `TODAY`, `YESTERDAY`, `TOMORROW` | Calendar day |
| `THIS_WEEK`, `LAST_WEEK`, `NEXT_WEEK` | Sun-Sat week |
| `THIS_MONTH`, `LAST_MONTH`, `NEXT_MONTH` | Calendar month |
| `THIS_QUARTER`, `LAST_QUARTER` | Calendar quarter |
| `THIS_YEAR`, `LAST_YEAR`, `NEXT_YEAR` | Calendar year |
| `LAST_N_DAYS:n` | Past n days (includes today) |
| `NEXT_N_DAYS:n` | Next n days (includes today) |
| `LAST_90_DAYS` | Past 90 days |
| `THIS_FISCAL_QUARTER`, `THIS_FISCAL_YEAR` | Fiscal periods |
| `N_DAYS_AGO:n` | Exactly n days ago |

### FIELDS() Functions
```sql
SELECT FIELDS(ALL) FROM Account LIMIT 200    -- All fields (LIMIT required)
SELECT FIELDS(STANDARD) FROM Account          -- Standard fields only
SELECT FIELDS(CUSTOM) FROM Account            -- Custom fields only
```

### Dynamic SOQL
```apex
String query = 'SELECT Id, Name FROM Account WHERE Industry = :industry';
List<Account> results = Database.query(query, AccessLevel.USER_MODE);
```
- Always use `AccessLevel.USER_MODE` with `Database.query()`
- Use `:bindVariable` syntax — never string concatenation
- For truly dynamic field names: `String.escapeSingleQuotes()`

### Utility Functions
- `toLabel(PicklistField)` — returns translated picklist label
- `FORMAT(NumberField)` — locale-formatted number/date
- `convertCurrency(Amount)` — converts to user's currency (multi-currency orgs)

### Record Locking
```sql
SELECT Id, Name FROM Account WHERE Id = :accountId FOR UPDATE
```
Pessimistic lock — blocks other transactions from updating until commit/rollback.

### ALL ROWS (Including Deleted)
```sql
SELECT Id, Name FROM Account WHERE IsDeleted = true ALL ROWS
```
Returns soft-deleted records (retained 15 days in Recycle Bin).

### SOQL For Loops
```apex
for (List<Account> batch : [SELECT Id, Name FROM Account]) {
    // Processes 200 records per iteration automatically
    // Uses minimal heap — ideal for large datasets
}
```

### Geolocation Queries
```sql
SELECT Id, Name, DISTANCE(Location__c, GEOLOCATION(37.7749, -122.4194), 'mi') dist
FROM Store__c
WHERE DISTANCE(Location__c, GEOLOCATION(37.7749, -122.4194), 'mi') < 50
ORDER BY DISTANCE(Location__c, GEOLOCATION(37.7749, -122.4194), 'mi')
```

### WITH SECURITY_ENFORCED vs WITH USER_MODE
| Feature | SECURITY_ENFORCED | USER_MODE |
|---------|-------------------|-----------|
| FLS enforcement | SELECT/FROM only | SELECT/FROM/WHERE/subqueries |
| On violation | Throws exception | Silently strips inaccessible fields |
| Restriction rules | Not supported | Supported |
| Recommendation | Legacy — migrate away | **Preferred** |

## Optimization Rules

### Selective Filters (use indexed fields)
- `Id`, `Name`, `OwnerId`, `CreatedDate`, `SystemModstamp`
- `RecordTypeId`, `Lookup` fields, `External ID` fields
- Custom fields marked as `External ID` or with custom index

### Anti-Patterns to Detect
1. **Query in loop** — move query before the loop, use Map/Set
2. **Non-selective filter** — filter on indexed fields first
3. **SELECT \*** equivalent — never select all fields, only what's needed
4. **Missing LIMIT** — add LIMIT for queries that could return large datasets
5. **Negative filters** — `!=` and `NOT IN` are non-selective
6. **Leading wildcard** — `LIKE '%term'` cannot use indexes
7. **Missing WHERE clause** — always filter unless deliberately loading all

### Query Plan Analysis
```bash
sf data query -q "EXPLAIN SELECT Id FROM Account WHERE Name = 'Test'" --target-org myOrg
```

## Limits
- 100 SOQL queries per synchronous transaction
- 200 SOQL queries per asynchronous transaction
- 50,000 rows returned per transaction
- 2,000 rows in a subquery
- 20 relationship queries per parent query

## Gotchas
- `FIELDS(ALL)` REQUIRES `LIMIT 200` — fails without it
- `COUNT()` counts all rows including nulls; `COUNT(fieldName)` counts non-null only
- `FOR UPDATE` locks the ENTIRE row — other transactions wait or timeout
- SOSL has its own governor limit: 20 queries/transaction (separate from SOQL's 100)
- Date literals include the boundary day — `LAST_N_DAYS:7` includes today
- `TYPEOF` only works on polymorphic fields (Task.What, Event.Who, etc.)
- Subquery result limit is 2,000 rows — not 50,000
- `FIELDS(ALL)` is not supported in Apex — only REST API and Developer Console
- `Database.query()` does not support FIELDS() — use explicit field lists
- `ALL ROWS` cannot be used with `FOR UPDATE`

## Workflow
1. Understand the data requirements
2. Check object relationships and field types
3. Build query with proper filters, security, and limits
4. Test with: `sf data query -q "YOUR_QUERY" --target-org myOrg`
5. Optimize based on results and explain plan

## References
- [SOQL/SOSL Reference](references/soql-reference.md) — date literals, SOSL syntax, FIELDS(), geolocation, dynamic SOQL, aggregates, FOR UPDATE, bind patterns, query plans
- [Governor Limits](../../references/governor-limits.md) — SOQL query limits per transaction
