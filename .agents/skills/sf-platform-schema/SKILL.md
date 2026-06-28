---
name: sf-platform-schema
description: "Use this skill when users need to create, generate, or validate Salesforce Custom Object metadata. Trigger when users mention custom objects, creating objects, object metadata, .object files, sharing models, name fields, or validation rules on objects. Also use when users say things like \"create a custom object\", \"generate object metadata\", \"set up an object for...\", or when they're troubleshooting object deployment errors especially around sharing models and Master-Detail relationships. Always use this skill for any custom object metadata work, including enriching and keeping the object's description current whenever its fields or validation rules change. Do NOT use this skill for non-Custom-Object metadata (Apex, Flows, LWC, Permission Sets, Custom Metadata Types) or for standard Salesforce objects."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-custom-object-generate
    - forcedotcom/sf-skills :: platform-custom-field-generate
    - forcedotcom/sf-skills :: platform-custom-tab-generate
    - forcedotcom/sf-skills :: platform-custom-application-generate
    - Clientell-Ai/salesforce-skills :: sf-schema
---

# sf-platform-schema: Custom Object & Field Schema

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-schema` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-custom-object-generate; forcedotcom/sf-skills :: platform-custom-field-generate; forcedotcom/sf-skills :: platform-custom-tab-generate; forcedotcom/sf-skills :: platform-custom-application-generate; Clientell-Ai/salesforce-skills :: sf-schema |

The first time in a session you touch a given object/field/tab/application, retrieve it from the dev org first per [Pre-Development Retrieve](../../workflows/DEPLOYMENT.md#pre-development-retrieve-mandatory) — do not generate or edit metadata on top of a local copy that may be stale relative to the org.

## When to Use This Skill

Use this skill when you need to:
- Create new custom objects
- Generate custom object metadata XML
- Configure object sharing and security settings
- Set up object features and capabilities
- Troubleshoot deployment errors related to custom objects
- **Add, update, or delete a field OR a validation rule on an existing object** — any of these may make the object's `<description>` stale, so you must refresh it (propose + confirm). This applies equally to validation-rule changes, not just fields. See Section 3.B.

## Specification

## 1. Overview and Purpose

This document defines the mandatory constraints for generating CustomObject metadata XML (`.object-meta.xml` file). The agent must verify these constraints before outputting XML to prevent Metadata API deployment errors.

**File extension:** `.object-meta.xml`

> **🔔 Description freshness — applies to EVERY object change, fields AND validation rules:** Whenever you add, update, or delete a field **or a validation rule** on an object, the `<description>` may now be stale. Before finishing, refresh it per **Section 3.B** (propose, confirm with the user, write). A validation-rule change counts exactly like a field change — the change is **not** done until the description has been reconciled. This is easy to forget on validation-rule edits/deletes — don't.

---

## 2. Syntactic Essentials (Tier 1)

The following constraints must be true for the XML body to deploy successfully.

**Note:** The API Name (fullName) is NOT a tag; it is the filename (e.g., `Vehicle__c.object-meta.xml`).

### Required Elements

| Element | Requirement | Notes |
|---------|-------------|-------|
| `<label>` | Required | Singular UI name |
| `<pluralLabel>` | Required | Plural UI name |
| `<sharingModel>` | Required | See Sharing Model Rules below |
| `<deploymentStatus>` | Required | Always set to `Deployed` |
| `<nameField>` | Required | Primary record identifier (requires `<label>` and `<type>`) |
| `<visibility>` | Required | Always set to `Public` |

### Sharing Model Rules

**Default:** Set `<sharingModel>` to `ReadWrite`.

**Exception:** If this object contains a Master-Detail relationship field, `<sharingModel>` MUST be `ControlledByParent`.

**Decision Logic:**
- IF object has NO Master-Detail field → use `ReadWrite`
- IF object has Master-Detail field → use `ControlledByParent`
- IF a Master-Detail field is being added to an existing child object → that existing object's `<sharingModel>` must also be updated to `ControlledByParent`

**❌ INCORRECT** — Will cause error: `Cannot set sharingModel to ReadWrite on a CustomObject with a MasterDetail relationship field`
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Order Line Item</label>
  <pluralLabel>Order Line Items</pluralLabel>
  <sharingModel>ReadWrite</sharingModel>  <!-- WRONG: Object has a M-D field -->
  <deploymentStatus>Deployed</deploymentStatus>
</CustomObject>
```

**✅ CORRECT:**
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Order Line Item</label>
  <pluralLabel>Order Line Items</pluralLabel>
  <sharingModel>ControlledByParent</sharingModel>  <!-- CORRECT -->
  <deploymentStatus>Deployed</deploymentStatus>
</CustomObject>
```

---

## 3. Smart Defaults & Decision Logic (Tier 2)

The agent must choose which features to enable based on the object's intended use case.

### A. The Name Field Decision

| Type | When to Use | Additional Requirements |
|------|-------------|------------------------|
| **Text** | Default for human-named entities (Projects, Locations, Teams) | None |
| **AutoNumber** | Use for transactions, logs, or IDs (Invoices, Requests, Tickets) | Must include `<displayFormat>` (e.g., `INV-{0000}`) and `<startingNumber>1</startingNumber>` |

**Text Name Field Example:**
```xml
<nameField>
  <label>Project Name</label>
  <type>Text</type>
</nameField>
```

**AutoNumber Name Field Example:**
```xml
<nameField>
  <label>Invoice Number</label>
  <type>AutoNumber</type>
  <displayFormat>INV-{0000}</displayFormat>
  <startingNumber>1</startingNumber>
</nameField>
```

### B. Object Description (Enrichment)

**`<description>`**: **Mandatory** — every Custom Object MUST have one. It must read like human-written documentation, **never** a generic template ("Object used to track and manage...") or a metadata dump ("Contains 8 fields including `Project_Name__c`...").

**Always compose an enriched description** — when creating the object, and again on **any** change to it: adding, updating, or deleting a field **or a validation rule** (so it never goes stale). The change — field or validation rule — is never "done" until you've refreshed the object's description. This is not optional; do not ask *whether* to add a description.

**Confirm per change — every time.** Propose and confirm on **each** field/rule change separately. A previous "keep current" applies **only** to that one change; it is **never** standing permission to skip the proposal on a later change. Do not infer a preference from an earlier answer — re-propose and re-ask for every new change.

**Compose** the description (steps below). If the object already has one, use it as a **strong signal** — preserve the business context it carries (domain, team, intent the schema can't reveal) and fold the new field/rule in rather than discarding it.

Then branch on whether a description already exists:

- **No existing description (brand-new object):** there is nothing to overwrite — just write the composed description. **Do not prompt.**
- **An existing description (update, delete, or any re-enrichment):** never overwrite it silently — you can't tell from the file whether it was hand-written by an admin or generated earlier. Show the proposal, ask, and **STOP — wait for the user's reply before writing:**
   > Proposed description for `{Object}`:
   > `<the enriched description>`
   > Current: `<the existing description>`
   > Use this? (yes / keep current / edit)

  **You MUST NOT write the `<description>` until the user replies** — showing the diff is not approval, even when the change looks obvious or minor. Then act: *yes* → write the proposed text · *keep current* → leave the existing one untouched (this applies to **this change only** — re-propose on the next one) · *edit* → use the user's wording.

Always end with a `<description>` written.

**Composing the description:**

1. **Classify each field** by how it appears in the description:
   - **Constrained** (required, unique, externalId, restricted picklist) → selective parenthetical: `VIN (required, external ID)`, `Color (Red/Green only)`
   - **Behavioral** (formula, roll-up) → describe what it computes: "the Age Years field auto-calculates vehicle age"
   - **Relationship** (master-detail, lookup) → woven context: "as a child of Account" (never "(Master-Detail to Account)")
   - **Standard** → label only
2. **Compose** in this order, using field **labels not API names**:
   > Purpose → key fields → computed fields → validation rules (as business rules) → "Commonly used for {use cases}."
3. **Count and trim before writing (required):** count the words; aim ~45, hard ceiling 50. If over, tighten wording first, then drop whole sentences in priority order (use cases → rules → computed; never drop sentences 1–2). Recount. Do not write until ≤ 50.

**Example (Car, 46 words):**
```xml
<description>The Car object tracks vehicle inventory and maintenance. It captures Year, VIN (required, external ID), Color (Red/Green only), and Location; the Age Years field auto-calculates vehicle age. VIN is required and Black cars cannot be sold. Commonly used for fleet management, inventory tracking, and service scheduling.</description>
```

→ For the full workflow and examples, read **`references/description-enrichment.md`**.

### C. Junction Object Naming

If the object is a many-to-many link between two parents, name the object by combining the two parent entities to ensure the schema remains intuitive.

**Examples:**
- `Position_Candidate__c` (links Position and Candidate)
- `Job_Application__c` (links Job and Application)

### D. Feature Enablement (Clean XML)

To maintain "Clean XML," only include optional tags when deviating from the Salesforce platform default of `false`.

**Scenario A: User-Facing Objects (Apps, Trackers, Business Entities)**
- Trigger: The object is intended for direct user interaction
- Action: Set `<enableSearch>`, `<enableReports>`, `<enableActivities>`, and `<enableHistory>` to `true`

**Scenario B: System-Facing Objects (Junctions, Background Logs)**
- Trigger: The object exists for technical associations or background data
- Action: Omit these tags to keep the UI clean and the XML lean

---

## 4. Critical Constraints & Common Failures

### Reserved Words

Never use reserved words as API names for Custom Objects or Custom Fields:

| Category | Reserved Words (Do Not Use as API Names) |
|----------|------------------------------------------|
| SOQL/SQL | `Select`, `From`, `Where`, `Limit`, `Order`, `Group` |
| System | `User`, `External`, `View`, `Type` |
| Temporal | `Date`, `Number` |

### Relationship Cap

Do not create more than **2 Master-Detail relationships** for a single object. If a third relationship is required, use a Lookup instead.

### XML Root Element

Do NOT include the `<fullName>` tag at the root of the `.object-meta.xml` file. The API name is derived from the filename.

**❌ INCORRECT:**
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Vehicle__c</fullName>  <!-- WRONG: Remove this -->
  <label>Vehicle</label>
</CustomObject>
```

**✅ CORRECT:**
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Vehicle</label>
  <!-- fullName comes from filename: Vehicle__c.object-meta.xml -->
</CustomObject>
```

### Validation Rule Naming Convention

Validation rule names follow different conventions than custom fields.

**Rules:**
- Must contain only alphanumeric characters and underscores
- Must begin with a letter
- Cannot end with an underscore
- Cannot contain two consecutive underscores
- **Must NOT end with `__c`** (unlike custom fields)

**❌ INCORRECT:**
```xml
<validationRules>
  <fullName>Require_Start_Date__c</fullName>  <!-- WRONG: Has __c suffix -->
  <active>true</active>
  <errorMessage>Start Date is required.</errorMessage>
  <formula>ISBLANK(Start_Date__c)</formula>
</validationRules>
```
**Error:** `The validation name can only contain alphanumeric characters, must begin with a letter, cannot end with an underscore...`

**✅ CORRECT:**
```xml
<validationRules>
  <fullName>Require_Start_Date</fullName>  <!-- CORRECT: No __c suffix -->
  <active>true</active>
  <errorMessage>Start Date is required.</errorMessage>
  <formula>ISBLANK(Start_Date__c)</formula>
</validationRules>
```

**Naming Pattern Reference:**

| Metadata Type | Naming Pattern | Example |
|---------------|----------------|---------|
| Custom Fields | Ends with `__c` | `Start_Date__c` |
| Validation Rules | No suffix | `Require_Start_Date` |
| Custom Objects | Ends with `__c` | `Vehicle__c` |

---

## 5. Verification Checklist

Before generating the Custom Object XML, verify:

### Syntactic Checks
- [ ] Are both `<label>` and `<pluralLabel>` present?
- [ ] Is `<deploymentStatus>` set to `Deployed`?
- [ ] Is `<visibility>` set to `Public`?
- [ ] Does `<nameField>` include both `<label>` and `<type>`?
- [ ] If `<type>` is `AutoNumber`, are `<displayFormat>` and `<startingNumber>` included?

### Sharing Model Check (Critical)
- [ ] Does this object have a Master-Detail relationship field?
    - If YES → `<sharingModel>` MUST be `ControlledByParent`
    - If NO → `<sharingModel>` should be `ReadWrite`

### Constraint Checks
- [ ] Is the API name free of reserved words?
- [ ] Are there 2 or fewer Master-Detail relationships?
- [ ] Is `<fullName>` absent from the XML root?

### Validation Rule Checks (if applicable)
- [ ] Do validation rule names NOT end with `__c`?
- [ ] Do validation rule names follow alphanumeric + underscore pattern?

### Description Enrichment Quality Checks
- [ ] Opens with "The {Object} object..." + business purpose (not "Object used to track and manage...")
- [ ] Uses field **labels**, never API names; no "Contains N fields including" dump
- [ ] Formulas/rollups described by behavior; validations stated as business rules; relationships as context
- [ ] Includes common use cases ("Commonly used for...") and is **under 50 words**
- [ ] Folded any current description's business context into the proposed one (didn't discard it)
- [ ] For an existing description (update/delete/re-enrich), STOPPED and waited for the user's reply before writing — did not treat showing the diff as approval

### Architectural Checks
- [ ] Is `<description>` present? (Enriched per Section B — proposed and confirmed with the user before writing.)
- [ ] Are `<enableSearch>` and `<enableReports>` set to `true` if user-facing?
- [ ] Does the filename match the intended API name?

---

## Reference File Index

| File | When to read |
|------|-------------|
| `references/description-enrichment.md` | Composing or refreshing an object's `<description>` (on create, or when a field/rule changes) — full enrichment workflow, field-prioritization tiers, junction/child handling, edge cases, and more examples |

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `platform-custom-field-generate` (forcedotcom/sf-skills :: platform-custom-field-generate)

## When to Use This Skill

Use this skill when you need to:
- Create custom fields on any object
- Generate field metadata for any field type
- Set up relationship fields (Lookup or Master-Detail)
- Create formula or roll-up summary fields
- Troubleshoot deployment errors related to custom fields

# Salesforce Custom Field Generator and Validator

## Overview

Generate and validate Salesforce Custom Field metadata with mandatory constraints to prevent deployment errors. This skill has special focus on the **highest-failure-rate field types**: Roll-up Summary and Master-Detail relationships.

## Specification

## 1. Purpose

This document defines the mandatory constraints for generating CustomField metadata XML. The agent must verify these constraints before outputting XML to prevent Metadata API deployment errors.

**Critical Focus Areas:**
- Roll-up Summary field format errors
- Master-Detail field attribute restrictions
- Lookup Filter restrictions

---

## 2. Universal Mandatory Attributes

Every generated field must include these tags:

| Attribute | Requirement | Notes |
|-----------|-------------|-------|
| `<fullName>` | Required | Derive from `<label>`: capitalize each word, replace spaces with `_`, append `__c`. Must start with a letter. E.g., label `Total Contract Value` → `Total_Contract_Value__c` |
| `<label>` | Required | The UI name (Title Case) |
| `<description>` | Mandatory | State the business "why" behind the field |
| `<inlineHelpText>` | Mandatory | Provide actionable guidance for the end-user. Must add value beyond the label (e.g., "Enter the value in USD including tax" instead of just "The amount") |

### External ID Configuration

**Trigger:** If the user mentions "integration," "importing data," "external system ID," or "unique key from [System Name]," set `<externalId>true</externalId>`.

**Applicable Types:** Text, Number, Email

---

## 3. Technical Interplay: Precision, Scale, and Length

To ensure deployment success, follow these mathematical constraints:

### Precision vs. Scale Rules

- `precision` is the total digits; `scale` is the decimal digits
- **Rule:** `precision ≤ 18` AND `scale ≤ precision`
- **Calculation:** Digits to the left of decimal = `precision - scale`

### The "Fixed 255" Rule

For standard TextArea types, the Metadata API requires `<length>255</length>`, even though it isn't configurable in the UI.

### Visible Lines

Mandatory for Long/Rich text and Multi-select picklists to control UI height.

---

## 4. Field Data Types

### 4.1 Simple Attribute Types

| Type | `<type>` Value | Required Attributes |
|------|----------------|---------------------|
| Auto Number | `AutoNumber` | `displayFormat` (must include `{0}`), `startingNumber` |
| Checkbox | `Checkbox` | Default `defaultValue` to `false` |
| Date | `Date` | No precision/length required |
| Date/Time | `DateTime` | No precision/length required |
| Email | `Email` | Built-in format validation |
| Lookup Relationship | `Lookup` | `referenceTo`, `relationshipName`, `deleteConstraint` |
| Master-Detail Relationship | `MasterDetail` | `referenceTo`, `relationshipName`, `relationshipOrder` |
| Number | `Number` | `precision`, `scale` |
| Currency | `Currency` | Default precision: 18, scale: 2 |
| Percent | `Percent` | Default precision: 5, scale: 2 |
| Phone | `Phone` | Standardizes phone number formatting |
| Picklist | `Picklist` | `valueSet` with `valueSetDefinition` and `restricted` |
| Text | `Text` | `length` (Max 255) |
| Text Area | `TextArea` | `<length>255</length>` |
| Text (Long) | `LongTextArea` | `length`, `visibleLines` (default 3) |
| Text (Rich) | `Html` | `length`, `visibleLines` (default 25) |
| Time | `Time` | Stores time only (no date) |
| URL | `Url` | Validates for protocol and format |

### 4.2 Computed & Multi-Value Types

| Type | `<type>` Value | Required Attributes |
|------|----------------|---------------------|
| Formula | Result type (e.g., `Number`) | `formula`, `formulaTreatBlanksAs` |
| Roll-Up Summary | `Summary` | See Section 6 for complete requirements |
| Multi-Select Picklist | `MultiselectPicklist` | `valueSet`, `visibleLines` (default 4) |

### 4.3 Specialized Types

| Type | `<type>` Value | Required Attributes |
|------|----------------|---------------------|
| Geolocation | `Location` | `scale`, `displayLocationInDecimal` |

### Picklist `restricted` Rule

The `<restricted>` boolean inside `<valueSet>` controls whether only admin-defined values are allowed.

- IF user does not specify → default to `<restricted>true</restricted>` (restricted, avoids performance issues with large picklist value sets)
- IF user explicitly says the picklist should allow custom/new values, or mentions "unrestricted" or "open" → set `<restricted>false</restricted>`
- Restricted picklists are limited to 1,000 total values (active + inactive)

```xml
<valueSet>
  <restricted>true</restricted>
  <valueSetDefinition>
    <sorted>false</sorted>
    <value>
      <fullName>Option_A</fullName>
      <default>false</default>
      <label>Option A</label>
    </value>
  </valueSetDefinition>
</valueSet>
```

---

## 5. Master-Detail Relationship Rules ⭐ CRITICAL

Master-Detail fields have **strict attribute restrictions** that differ from Lookup fields. Violating these rules causes deployment failures.

### Forbidden Attributes on Master-Detail Fields

**NEVER include these attributes on Master-Detail fields:**

| Forbidden Attribute | Why | What Happens |
|---------------------|-----|--------------|
| `<required>` | Master-Detail is ALWAYS required by design | Deployment error |
| `<deleteConstraint>` | Master-Detail ALWAYS cascades deletes | Deployment error |
| `<lookupFilter>` | Only supported on Lookup fields | Deployment error |

### Master-Detail vs Lookup Comparison

| Attribute | Master-Detail | Lookup |
|-----------|---------------|--------|
| `<required>` | ❌ FORBIDDEN | ✅ Optional |
| `<deleteConstraint>` | ❌ FORBIDDEN (always CASCADE) | ✅ Required (`SetNull`, `Restrict`, `Cascade`) |
| `<lookupFilter>` | ❌ FORBIDDEN | ✅ Optional |
| `<relationshipOrder>` | ✅ Required (0 or 1) | ❌ Not applicable |
| `<reparentableMasterDetail>` | ✅ Optional | ❌ Not applicable |
| `<writeRequiresMasterRead>` | ✅ Optional | ❌ Not applicable |

### ❌ INCORRECT — Master-Detail with forbidden attributes:

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Account__c</fullName>
  <label>Account</label>
  <type>MasterDetail</type>
  <referenceTo>Account</referenceTo>
  <relationshipName>Contacts</relationshipName>
  <relationshipOrder>0</relationshipOrder>
  <required>true</required>           <!-- WRONG: Remove this -->
  <deleteConstraint>Cascade</deleteConstraint>  <!-- WRONG: Remove this -->
  <lookupFilter>                       <!-- WRONG: Remove this entire block -->
    <active>true</active>
    <filterItems>
      <field>Account.Type</field>
      <operation>equals</operation>
      <value>Customer</value>
    </filterItems>
  </lookupFilter>
</CustomField>
```

**Errors:**
- `Master-Detail Relationship Fields Cannot be Optional or Required`
- `Can not specify 'deleteConstraint' for a CustomField of type MasterDetail`
- `Lookup filters are only supported on Lookup Relationship Fields`

### ✅ CORRECT — Master-Detail field:

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Account__c</fullName>
  <label>Account</label>
  <description>Links this record to its parent Account</description>
  <type>MasterDetail</type>
  <referenceTo>Account</referenceTo>
  <relationshipLabel>Child Records</relationshipLabel>
  <relationshipName>ChildRecords</relationshipName>
  <relationshipOrder>0</relationshipOrder>
  <reparentableMasterDetail>false</reparentableMasterDetail>
  <writeRequiresMasterRead>false</writeRequiresMasterRead>
  <!-- NO required, deleteConstraint, or lookupFilter -->
</CustomField>
```

### ✅ CORRECT — Lookup field (with optional attributes):

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Related_Account__c</fullName>
  <label>Related Account</label>
  <description>Optional link to a related Account</description>
  <type>Lookup</type>
  <referenceTo>Account</referenceTo>
  <relationshipLabel>Related Records</relationshipLabel>
  <relationshipName>RelatedRecords</relationshipName>
  <required>false</required>
  <deleteConstraint>SetNull</deleteConstraint>
  <lookupFilter>
    <active>true</active>
    <filterItems>
      <field>Account.Type</field>
      <operation>equals</operation>
      <value>Customer</value>
    </filterItems>
    <isOptional>false</isOptional>
  </lookupFilter>
</CustomField>
```

### Additional Master-Detail Rules

- **Relationship Order:** First Master-Detail on object = `0`, second = `1`
- **Relationship Name:** Must be a plural PascalCase string (e.g., `Travel_Bookings`)
- **Junction Objects:** Use two Master-Detail fields for standard many-to-many (enables Roll-ups)
- **Limit:** Maximum 2 Master-Detail relationships per object. Use Lookup for additional relationships.

---

## 6. Roll-Up Summary Field Rules ⭐ CRITICAL

Roll-up Summary fields have the **highest deployment failure rate**. Follow these rules exactly.

### Required Elements for Roll-Up Summary

| Element | Requirement | Format |
|---------|-------------|--------|
| `<type>` | Required | Always `Summary` |
| `<summaryOperation>` | Required | `count`, `sum`, `min`, or `max` |
| `<summaryForeignKey>` | Required | `ChildObject__c.MasterDetailField__c` |
| `<summarizedField>` | Conditional | Required for `sum`, `min`, `max`. NOT for `count` |

### Forbidden Elements on Roll-Up Summary

**NEVER include these attributes on Roll-Up Summary fields:**

| Forbidden Attribute | Why |
|---------------------|-----|
| `<precision>` | Summary inherits from summarized field |
| `<scale>` | Summary inherits from summarized field |
| `<required>` | Not applicable to Summary fields |
| `<length>` | Not applicable to Summary fields |

### Format Rules for summaryForeignKey and summarizedField

**CRITICAL:** Both `summaryForeignKey` and `summarizedField` MUST use the fully qualified format:

```
ChildObjectAPIName__c.FieldAPIName__c
```

**Decision Logic:**
- `summaryForeignKey` = `ChildObject__c.MasterDetailFieldOnChild__c`
- `summarizedField` = `ChildObject__c.FieldToSummarize__c`

### ❌ INCORRECT — Roll-Up Summary with common errors:

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Total_Amount__c</fullName>
  <label>Total Amount</label>
  <type>Summary</type>
  <precision>18</precision>           <!-- WRONG: Remove - inherited from source -->
  <scale>2</scale>                    <!-- WRONG: Remove - inherited from source -->
  <summaryOperation>sum</summaryOperation>
  <summaryForeignKey>Order__c</summaryForeignKey>        <!-- WRONG: Missing field name -->
  <summarizedField>Amount__c</summarizedField>           <!-- WRONG: Missing object name -->
</CustomField>
```

**Errors:**
- `Can not specify 'precision' for a CustomField of type Summary`
- `Must specify the name in the CustomObject.CustomField format (e.g. Account.MyNewCustomField)`

### ✅ CORRECT — Roll-Up Summary (SUM operation):

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Total_Amount__c</fullName>
  <label>Total Amount</label>
  <description>Sum of all line item amounts</description>
  <inlineHelpText>Automatically calculated from child line items</inlineHelpText>
  <type>Summary</type>
  <summaryOperation>sum</summaryOperation>
  <summarizedField>Order_Line_Item__c.Amount__c</summarizedField>
  <summaryForeignKey>Order_Line_Item__c.Order__c</summaryForeignKey>
  <!-- NO precision, scale, required, or length -->
</CustomField>
```

### ✅ CORRECT — Roll-Up Summary (COUNT operation):

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Line_Item_Count__c</fullName>
  <label>Line Item Count</label>
  <description>Count of related line items</description>
  <inlineHelpText>Automatically calculated from child records</inlineHelpText>
  <type>Summary</type>
  <summaryOperation>count</summaryOperation>
  <summaryForeignKey>Order_Line_Item__c.Order__c</summaryForeignKey>
  <!-- NO summarizedField needed for COUNT -->
  <!-- NO precision, scale, required, or length -->
</CustomField>
```

### ✅ CORRECT — Roll-Up Summary (MIN operation):

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Earliest_Due_Date__c</fullName>
  <label>Earliest Due Date</label>
  <description>Earliest due date among all line items</description>
  <inlineHelpText>Shows the soonest deadline</inlineHelpText>
  <type>Summary</type>
  <summaryOperation>min</summaryOperation>
  <summarizedField>Order_Line_Item__c.Due_Date__c</summarizedField>
  <summaryForeignKey>Order_Line_Item__c.Order__c</summaryForeignKey>
</CustomField>
```

### ✅ CORRECT — Roll-Up Summary (MAX operation):

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Highest_Price__c</fullName>
  <label>Highest Price</label>
  <description>Maximum unit price among all line items</description>
  <inlineHelpText>Shows the most expensive item</inlineHelpText>
  <type>Summary</type>
  <summaryOperation>max</summaryOperation>
  <summarizedField>Order_Line_Item__c.Unit_Price__c</summarizedField>
  <summaryForeignKey>Order_Line_Item__c.Order__c</summaryForeignKey>
</CustomField>
```

### Roll-Up Summary Quick Reference

| Operation | summarizedField Required? | Use Case |
|-----------|---------------------------|----------|
| `count` | NO | Count number of child records |
| `sum` | YES | Add up numeric values |
| `min` | YES | Find smallest value |
| `max` | YES | Find largest value |

### Roll-Up Summary Prerequisites

- Roll-Up Summary fields can ONLY be created on the **parent** object in a Master-Detail relationship
- The child object MUST have a Master-Detail field pointing to this parent
- The summarized field must exist on the child object

---

## 7. Formula Field Rules

### Formula Result Types

A Formula is not a type itself. The `<formula>` tag is added to a field whose `<type>` is set to the **result data type**:
- `Checkbox`, `Currency`, `Date`, `DateTime`, `Number`, `Percent`, `Text`

### Formula XML Generation Rules

- The contents of the `<formula>` tag MUST be wrapped in a `<![CDATA[ ... ]]>` section. This prevents the XML parser from interpreting formula operators (like `&`, `<`, `>`) as XML markup.
- If the formula text itself contains the literal sequence `]]>`, escape it by breaking the CDATA block: e.g., `<![CDATA[Text_Field__c & "]]]]><![CDATA[>"]]>`
- NEVER use an attribute or tag named `returnType`. This does not exist in the Metadata API. The `<type>` tag defines the return data type of the formula result.

### formulaTreatBlanksAs Rule

**Decision Logic:**
- IF formula result type = `Number`, `Currency`, or `Percent` → set `<formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>`
- IF formula result type = `Text`, `Date`, or `DateTime` → set `<formulaTreatBlanksAs>BlankAsBlank</formulaTreatBlanksAs>`

### ❌ INCORRECT — Using Formula as type:

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Calculated_Value__c</fullName>
  <type>Formula</type>  <!-- WRONG: Formula is not a valid type -->
  <returnType>Number</returnType>  <!-- WRONG: returnType does not exist in Metadata API -->
  <formula>Field1__c + Field2__c</formula>  <!-- WRONG: Missing CDATA wrapper -->
</CustomField>
```

### ✅ CORRECT — Formula field:

```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Calculated_Value__c</fullName>
  <label>Calculated Value</label>
  <description>Sum of Field1 and Field2</description>
  <type>Number</type>  <!-- Result type, not "Formula" -->
  <precision>18</precision>
  <scale>2</scale>
  <formula><![CDATA[Field1__c + Field2__c]]></formula>
  <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>
</CustomField>
```

### Formula Field Dependencies

Formula fields that reference other fields will fail deployment if the referenced field does not exist or has not been deployed yet. Ensure all referenced fields are deployed before the formula field.

### Specific Function Guidelines

| Function | Rule |
|----------|------|
| `TEXT()` | MUST NOT be used with Text fields. If the field is already Text, remove the `TEXT()` wrapper. |
| `CASE()` | Last parameter is always the default value. Total parameter count MUST be even (value-result pairs + default). |
| `VALUE()` | MUST only be used with Text fields. If a Number is passed as parameter, remove the `VALUE()` wrapper. |
| `DAY()` | MUST only be used with Date fields. If a DateTime field is used, convert it to Date first (e.g., `DAY(DATEVALUE(DateTimeField__c))`). |
| `MONTH()` | MUST only be used with Date fields. If a DateTime field is used, convert it to Date first (e.g., `MONTH(DATEVALUE(DateTimeField__c))`). |
| `DATEVALUE()` | MUST only be used with DateTime fields. If a Date field is used, remove the `DATEVALUE()` wrapper. |
| `ISPICKVAL()` | MUST be used when checking equality of a Picklist field. NEVER use `==` with Picklist fields. |
| `ISCHANGED()` | Use `ISCHANGED()` to check if a field value has changed. Do not manually compare with `PRIORVALUE()`. |

---

## 8. Common Deployment Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `ConversionError: Invalid XML tags or unable to find matching parent xml file for CustomField` | XML comments placed before the root `<CustomField>` element | Remove XML comments (`<!-- ... -->`) that appear before `<CustomField>` in the `.field-meta.xml` file |
| `Field [FieldName] does not exist. Check spelling.` | Referenced field does not exist or has not been deployed yet | Verify the referenced field exists and is deployed before this field |
| `DUPLICATE_DEVELOPER_NAME` | Field fullName already exists on the object | Use a unique business-driven name |
| `MAX_RELATIONSHIPS_EXCEEDED` | More than 2 Master-Detail or 15 Lookup fields on the object | Use Lookup for 3rd+ Master-Detail; review Lookup count |
| Reserved keyword error | Using `Order__c`, `Group__c`, etc. | Rename to `Status_Order__c`, etc. |

---

## 9. Verification Checklist

Before generating CustomField XML, verify:

### Universal Checks
- [ ] Does `<fullName>` use valid format and end in `__c`?
- [ ] Are `<description>` and `<inlineHelpText>` both populated and meaningful?
- [ ] Is `<label>` in Title Case?
- [ ] Are there no XML comments (`<!-- ... -->`) before the root `<CustomField>` element? (Comments before the root element break SDR's parser)

### Master-Detail Field Checks ⭐ CRITICAL
- [ ] Is `<required>` attribute ABSENT? (Master-Detail is always required)
- [ ] Is `<deleteConstraint>` attribute ABSENT? (Master-Detail always cascades)
- [ ] Is `<lookupFilter>` block ABSENT? (Only for Lookup fields)
- [ ] Is `<relationshipOrder>` set to `0` or `1`?
- [ ] Is parent object's `<sharingModel>` set to `ControlledByParent`?

### Lookup Field Checks
- [ ] Is `<deleteConstraint>` set to `SetNull`, `Restrict`, or `Cascade`?
- [ ] Is `<relationshipName>` in plural PascalCase?

### Roll-Up Summary Field Checks ⭐ CRITICAL
- [ ] Is `<precision>` attribute ABSENT?
- [ ] Is `<scale>` attribute ABSENT?
- [ ] Is `<summaryForeignKey>` in format `ChildObject__c.MasterDetailField__c`?
- [ ] For SUM/MIN/MAX: Is `<summarizedField>` in format `ChildObject__c.FieldName__c`?
- [ ] For COUNT: Is `<summarizedField>` ABSENT?
- [ ] Does the child object have a Master-Detail field to this parent?

### Formula Field Checks
- [ ] Is `<type>` set to result type (NOT "Formula")?
- [ ] Is `<formula>` content wrapped in `<![CDATA[ ... ]]>`?
- [ ] Is `<returnType>` attribute ABSENT? (does not exist in Metadata API)
- [ ] Is `<formulaTreatBlanksAs>` set to `BlankAsZero` for numeric results or `BlankAsBlank` for text/date results?
- [ ] Do all referenced fields exist and deploy before this field?

### Numeric Field Checks
- [ ] Is `scale ≤ precision`?
- [ ] Is `precision ≤ 18`?

### Text Area Checks
- [ ] For TextArea: Is `<length>255</length>` explicitly included?
- [ ] For LongTextArea/Html: Is `<visibleLines>` set?

### Relationship Limit Checks
- [ ] Are there 2 or fewer Master-Detail relationships on the object?
- [ ] Are there 15 or fewer Lookup relationships on the object?

### Naming Checks
- [ ] Is the API name free of reserved words (`Order`, `Group`, `Select`, etc.)?
- [ ] Is the API name unique on this object?

### Supplemental Guidance from `platform-custom-tab-generate` (forcedotcom/sf-skills :: platform-custom-tab-generate)

## When to Use This Skill

Use this skill when you need to:
- Create tabs for objects, web pages, or Visualforce pages
- Add navigation tabs to applications
- Configure tab visibility and access
- Troubleshoot deployment errors related to custom tabs

## Specification

# CustomTab Metadata Specification

## 📋 Overview
Custom tabs for navigating to objects, web content, or Visualforce pages within Salesforce applications.

## 🎯 Purpose
- Provide navigation to custom objects
- Link to external web content
- Access Visualforce pages
- Organize application navigation

## ⚙️ Required Properties

### Core Tab Properties
- **customObject**: `true` for custom object tabs, `false` for all others.
- **motif**: Tab icon style — choose a motif that semantically matches the object's purpose. Do NOT reuse the same motif for every tab.
- **label**: Display name (required for non-object tabs ONLY; object tabs inherit label from the object)
- **url**: Web URL (for web tabs)
- **page**: Visualforce page name (for Visualforce tabs)


### 🚨 STRICT ELEMENT ALLOWLIST — READ THIS FIRST

**The root element MUST always be `<CustomTab>` (NOT `<Tab>`).** The XML namespace must be `xmlns="http://soap.sforce.com/2006/04/metadata"`.

Only the elements listed below are valid. **Any element not on this list WILL cause a deployment error.**

| Tab Type | ONLY these elements are allowed (nothing else) |
|---|---|
| **Object tabs** | `<customObject>` (required, set to `true`), `<motif>` (required), `<description>` (optional) |
| **Web tabs** | `<customObject>` (required, set to `false`), `<label>` (required), `<motif>` (required), `<url>` (required), `<urlEncodingKey>` (required, set to `UTF-8`), `<description>` (optional), `<frameHeight>` (optional) |
| **Visualforce tabs** | `<customObject>` (required, set to `false`), `<label>` (required), `<motif>` (required), `<page>` (required), `<description>` (optional) |

### ⚠️ FORBIDDEN ELEMENTS (every one of these causes a deployment error)
`<sobjectName>`, `<name>`, `<fullName>`, `<apiVersion>`, `<isHidden>`, `<tabVisibility>`, `<type>`, `<mobileReady>`, `<urlFrameHeight>`, `<urlType>`, `<urlRedirect>`, `<encodingKey>`, `<height>`, `<auraComponent>`

Also forbidden:
- `<label>` on object tabs (object tabs inherit their label from the custom object)
- `<page>` on web tabs (only for Visualforce tabs)
- Empty elements like `<page></page>` or `<description></description>`
- Any element not in the allowlist table above

## 🔧 Tab Types

### Object Tabs
- **Purpose**: Navigate to custom or standard objects
- **File name** determines the object: `{ObjectApiName}.tab-meta.xml` (e.g., `Space_Station__c.tab-meta.xml`)
- **Required elements**: `<customObject>true</customObject>` and `<motif>`
- **Correct example** (for a Space_Station__c.tab-meta.xml):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>true</customObject>
    <motif>Custom39: Telescope</motif>
</CustomTab>
```
- **Correct example** (for a Supply__c.tab-meta.xml — note different motif):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>true</customObject>
    <motif>Custom98: Truck</motif>
</CustomTab>
```
- **❌ WRONG** — do NOT add `<sobjectName>`, `<name>`, `<fullName>`, or `<label>`:
```xml
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <sobjectName>Space_Station__c</sobjectName>  <!-- DEPLOYMENT ERROR -->
    <label>Space Station</label>                  <!-- DEPLOYMENT ERROR on object tabs -->
    <customObject>true</customObject>
    <motif>Custom57: Desert</motif>
</CustomTab>
```

### Web Tabs
- **Purpose**: Link to external websites or web applications
- **File name**: Use a descriptive name: `{TabName}.tab-meta.xml` (e.g., `Knowledge_Base.tab-meta.xml`)
- **COPY THIS EXACT TEMPLATE** — only replace the placeholder values. Do NOT add, remove, or rename any XML elements:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>false</customObject>
    <description>REPLACE_WITH_DESCRIPTION</description>
    <frameHeight>600</frameHeight>
    <label>REPLACE_WITH_LABEL</label>
    <motif>REPLACE_WITH_MOTIF</motif>
    <url>REPLACE_WITH_URL</url>
    <urlEncodingKey>UTF-8</urlEncodingKey>
</CustomTab>
```
- **These 7 elements above are the ONLY elements allowed in a web tab file.** Do not add ANY other elements.
- The `<description>` element is optional — you may remove it if not needed, but do not add anything else.

### Visualforce Tabs
- **Purpose**: Access custom Visualforce pages
- **File name**: `{TabName}.tab-meta.xml` (e.g., `Custom_Page_Tab.tab-meta.xml`)
- **Required elements**: `<customObject>false</customObject>`, `<label>`, `<motif>`, `<page>`
- **Correct example**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>false</customObject>
    <label>Custom Page</label>
    <motif>Custom46: Computer</motif>
    <page>CustomPage</page>
</CustomTab>
```

## 🎨 Tab Configuration

### Tab Style
- **Default**: Use standard tab styling
- **Custom**: Can specify custom tab styles if needed

### Tab Visibility
- **Default**: Visible to all users with access
- **Custom**: Can be configured for specific user profiles

## 📱 Supported Applications
- **Standard Apps**: Available in standard Salesforce applications
- **Custom Apps**: Can be included in custom applications
- **Community Apps**: Available in community applications

## 🔗 Integration Points
- **Object Relationships**: Links to related object records
- **Web Content**: External website integration
- **Visualforce Pages**: Custom page functionality
- **Lightning Components**: Modern component integration
## ✅ Best Practices
- Use clear, descriptive tab labels
- Choose appropriate tab types for functionality
- **Select a unique, contextually relevant motif for each tab** — do not default every tab to the same icon
- Consider user experience and navigation flow
- Test tab functionality across different applications
- Ensure proper permissions and visibility settings
- Follow consistent naming conventions
- Object tab files MUST only contain `<customObject>true</customObject>` and `<motif>` — nothing else
- Web tab files MUST only contain: `<customObject>false</customObject>`, `<label>`, `<motif>`, `<url>`, `<urlEncodingKey>`, and optionally `<description>`, `<frameHeight>` — nothing else
- Never include `<isHidden>`, `<tabVisibility>`, `<type>`, `<mobileReady>`, or empty elements

### Supplemental Guidance from `platform-custom-application-generate` (forcedotcom/sf-skills :: platform-custom-application-generate)

## When to Use This Skill

Use this skill when you need to:
- Create Lightning applications
- Organize tabs and features into focused apps
- Configure application navigation and branding
- Set up custom page layouts for objects
- Troubleshoot deployment errors related to custom applications
# CustomApplication (Lightning App) Metadata Specification

## Overview

Custom applications (Lightning Apps) that group tabs and functionality to provide a focused user experience for specific business processes. Always configured for Lightning Experience.

## 🎯 Purpose
- Organize related functionality into focused applications
- Group tabs and components for specific user roles
- Provide tailored user experiences
- Control access to specific features and data
- Use Standard navigation for general business applications or Console navigation for specialized service/support workflows requiring multi-tab workspaces
- Create professional, branded application identity with custom colors and branding
- Override standard actions with custom Lightning pages for enhanced user experience
- Enable profile-specific experiences through profile action overrides

## ⚙️ Required Properties

### Core Application Properties
- **fullName**: API name of the application
- **label**: Display name of the application
- **uiType**: Always "Lightning" for modern apps
- **navType**: CRITICAL - Choose based on user requirements and workflow patterns
    - "Standard": DEFAULT for general business applications (e.g., sales, marketing, operations)
    - "Console": ONLY when workflow requires managing multiple records simultaneously with split-view or multi-tab workspace (e.g., customer service, call centers, support operations)
- **formFactors**: Array of form factors (["LARGE"] for desktop, ["SMALL"] for mobile, or both)

### Optional Properties
- **description**: Brief description of the application's purpose
- **tabs**: Array of tab names to include
- **utilityBar**: API name of the Utility Bar configuration
- **brand**: ⚠️ HIGHLY RECOMMENDED - Branding configuration object (headerColor, shouldOverrideOrgTheme, footerColor)
- **actionOverrides**: ⚠️ REQUIRED when custom record pages exist - Action override configuration (actionName, content, formFactor, type, pageOrSobjectType)
- **profileActionOverrides**: Profile-specific action overrides (actionName, content, formFactor, pageOrSobjectType, type, profile)
- **isNavAutoTempTabsDisabled**: Navigation behavior setting (default: false)
- **isNavPersonalizationDisabled**: Personalization setting (default: false)
- **isNavTabPersistenceDisabled**: Tab persistence setting (default: false)

## 🔧 Application Configuration

### Navigation Type Selection (CRITICAL)
**Decision Criteria for navType:**

**Choose "Standard" (DEFAULT) for:**
- General business applications and most workflows
- Single-record focus or linear navigation patterns
- Standard tab-based navigation is sufficient

**Choose "Console" ONLY when workflow requires:**
- Managing multiple related records simultaneously in split-view
- Multi-tab workspace for handling complex, interconnected data
- Contextual information from multiple sources visible at once
- Examples: customer service operations, support desks, call centers

**When in doubt:** Default to "Standard" for most general business use cases

### Navigation Settings
- **isNavAutoTempTabsDisabled**: Controls automatic temporary tab creation
- **isNavPersonalizationDisabled**: Controls user personalization features
- **isNavTabPersistenceDisabled**: Controls tab persistence across sessions

### Tab Management
- **tabs**: Array of tab names to include in the application
- **formFactors**: Device-specific configurations (Large for desktop, Small for mobile)

### Utility Bar
- **utilityBar**: Reference to Lightning utility bar (appears at bottom of Lightning Experience)

### Branding (HIGHLY RECOMMENDED - DO NOT SKIP)
**IMPORTANT**: Provide branding configuration to create a professional, visually distinct application identity.

- **brand.headerColor**: Header bar color in hex format (e.g., "#0070D2") - RECOMMENDED
- **brand.shouldOverrideOrgTheme**: Override organization theme (true/false) - Default: false
- **brand.footerColor**: Footer color in hex format

### Action Overrides (CRITICAL - DO NOT SKIP)
**IMPORTANT**: Action overrides MUST be created for every custom object tab that has a record page generated by flexipage expert.

- **actionOverrides.actionName**: Action to override ("View" or "Tab")
- **actionOverrides.content**: Page/component name (FlexiPage, Visualforce, Lightning component)
    - For "View" action: Reference record pages generated by flexipage expert
    - For "Tab" action: Reference home/app pages generated by flexipage expert
- **actionOverrides.formFactor**: Device type ("Large" or "Small")
- **actionOverrides.type**: Override type ("Default", "Visualforce", "Flexipage", "LightningComponent", "Scontrol")
    - Recommended: Use "Flexipage" for Lightning record/home pages generated by flexipage expert
- **actionOverrides.pageOrSobjectType**: Object API name the override applies to
- **actionOverrides.comment**: Optional description (max 1000 characters)
    - Auto-generated comment: "Action override created by Lightning App Builder during activation."
- **actionOverrides.skipRecordTypeSelect**: Skip record type selection (default: false)

### Profile Action Overrides
- **profileActionOverrides.actionName**: Action to override ("View" or "Tab")
- **profileActionOverrides.content**: Page/component name
    - For "View" action: Reference profile-specific record pages generated by flexipage expert
    - For "Tab" action: Reference profile-specific home pages generated by flexipage expert
    - Can reference same or different FlexiPages than actionOverrides for profile-specific experiences
- **profileActionOverrides.formFactor**: Device type ("Large" or "Small")
- **profileActionOverrides.pageOrSobjectType**: Object API name
- **profileActionOverrides.type**: Override type
    - Recommended: Use "Flexipage" for Lightning pages generated by flexipage expert
- **profileActionOverrides.profile**: Profile API name (e.g., "Admin", "Standard User")
    - Enables different page layouts for different user profiles

## 📱 Device Support

### Desktop Configuration
- **formFactor**: "Large"
- **tabs**: Full list of application tabs

### Phone Configuration
- **formFactor**: "Small"
- **tabs**: Mobile-optimized tab selection

### Tablet Configuration
- **formFactor**: "Medium"
- **tabs**: Tablet-appropriate tab selection

## 🎨 User Experience Features

### Navigation Behavior
- **Auto Temporary Tabs**: Can be enabled/disabled
- **Personalization**: User customization options
- **Tab Persistence**: Remember user's tab selections

### Accessibility
- **Keyboard Navigation**: Full keyboard support
- **Screen Reader**: Compatible with assistive technologies
- **High Contrast**: Support for high contrast modes

## 🔗 Integration Points
- **Custom Tabs**: Include custom object and web tabs
- **Standard Tabs**: Include standard Salesforce tabs
- **Lightning Pages**: Integrate with Lightning page layouts
- **Components**: Include custom Lightning components
## ✅ Best Practices
- **Always use Lightning UI**: Set `uiType` to "Lightning" for modern apps
- **Choose appropriate navigation**: CRITICAL - Analyze requirements carefully for `navType` selection
    - Use "Standard" (DEFAULT) for general business applications
    - Use "Console" ONLY when workflow requires multi-tab workspace, split-view, or managing multiple related records simultaneously
    - Examples for Console: customer service, call centers, support operations
    - Default to "Standard" for most general business use cases
- **Include Standard Tabs**: Add common Salesforce tabs (Home, Accounts, Contacts, etc.)
- **Use clear, descriptive application names**
- **Group related functionality logically**
- **Consider different user roles and needs**
- **Test across different device types**
- **Ensure proper permissions and access control**
- **Provide meaningful descriptions for users**
- **Follow consistent naming conventions**
- **Always configure branding**: Set headerColor to create professional application identity
- **Use accessible brand colors**: Ensure hex colors have sufficient contrast (WCAG AA compliant)
- **Configure utility bars**: Add useful quick-access tools for users
- **Leverage action overrides**: Customize page layouts for specific objects using FlexiPages from flexipage expert
- **Use profile overrides**: Provide role-specific experiences by referencing different flexipage expert generated pages per profile

## 🎯 Enhancement Rules
- **uiType**: Always set to "Lightning" for modern app experience
- **navType**: CRITICAL DECISION - Analyze user requirements carefully
    - Set to "Standard" (DEFAULT) for general business applications
    - Set to "Console" ONLY when workflow requires:
        - Managing multiple related records simultaneously with split-view capability
        - Multi-tab workspace for handling complex, interconnected data
        - Contextual information from multiple sources visible at once
    - Console examples: customer service operations, call centers, support desks
    - When in doubt between Standard and Console, choose "Standard" for most business use cases
- **formFactors**: Always set to ["LARGE"] for desktop Lightning Experience
- **Standard Tabs**: Automatically add Home, Accounts, Contacts, Opportunities, Leads, Cases
- **Navigation Settings**: Set all navigation flags to false for best user experience
- **Branding**: ALWAYS include brand configuration for professional application identity
    - MANDATORY: Set brand.headerColor to appropriate color (e.g., "#0070D2" for Salesforce Blue)
    - Set brand.shouldOverrideOrgTheme based on requirements
- **Action Overrides**: ALWAYS create action overrides when custom record pages exist
    - MANDATORY: Add actionOverrides for "View" action pointing to flexipage expert generated record pages
    - Use "Flexipage" type and reference the exact FlexiPage name
    - Set formFactor to "Large" for desktop
    - Include pageOrSobjectType with the object API name
- **Profile Action Overrides**: Reference flexipage expert generated pages for role-based customization
- **Form Factors**: Use "Large" for desktop, "Small" for mobile in overrides

## ⚠️ CRITICAL Verification Checklist (MUST VERIFY)
- [ ] All tabs are included in the application
- [ ] **navType IS CORRECTLY SET** - Verify Console vs Standard selection
- [ ] Default to "Standard" for most general business applications
- [ ] Set to "Console" ONLY if workflow requires managing multiple records simultaneously, split-view, or multi-tab workspace
- [ ] If requirements are general/ambiguous → navType should be "Standard"
- [ ] **BRANDING IS CONFIGURED** - This is HIGHLY RECOMMENDED for professional applications
- [ ] brand.headerColor is set with valid hex color (e.g., "#0070D2")
- [ ] brand.shouldOverrideOrgTheme is set (default: false)
- [ ] **ACTION OVERRIDES ARE CREATED** - This is MANDATORY for every custom object with a record page
- [ ] Action overrides are defined for EACH custom object tab pointing to the correct record page
- [ ] actionOverrides.content matches the exact FlexiPage name generated by flexipage expert
- [ ] actionOverrides.pageOrSobjectType is set to the correct object API name
- [ ] actionOverrides.type is set to "Flexipage"
- [ ] actionOverrides.actionName is set to "View"
- [ ] actionOverrides.formFactor is set to "Large"
- [ ] All required fields are populated (fullName, label, uiType, navType, formFactors)

### Supplemental Guidance from `sf-schema` (Clientell-Ai/salesforce-skills :: sf-schema)

# Schema Design & Permission Management

You are a Salesforce schema and metadata specialist. Generate valid SFDX source format metadata.

## Custom Object
```xml
<!-- force-app/main/default/objects/Invoice__c/Invoice__c.object-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Invoice</label>
    <pluralLabel>Invoices</pluralLabel>
    <nameField>
        <label>Invoice Number</label>
        <type>AutoNumber</type>
        <displayFormat>INV-{000000}</displayFormat>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>Private</sharingModel>
    <enableActivities>true</enableActivities>
    <enableHistory>true</enableHistory>
    <enableReports>true</enableReports>
</CustomObject>
```

## Custom Fields
```xml
<!-- force-app/main/default/objects/Invoice__c/fields/Amount__c.field-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Amount__c</fullName>
    <label>Amount</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>
    <required>true</required>
</CustomField>
```

### Common Field Types
```xml
<!-- Text -->
<type>Text</type>
<length>255</length>

<!-- Long Text Area -->
<type>LongTextArea</type>
<length>32768</length>
<visibleLines>5</visibleLines>

<!-- Picklist -->
<type>Picklist</type>
<valueSet>
    <restricted>true</restricted>
    <valueSetDefinition>
        <sorted>false</sorted>
        <value><fullName>Active</fullName><default>true</default><label>Active</label></value>
        <value><fullName>Inactive</fullName><default>false</default><label>Inactive</label></value>
    </valueSetDefinition>
</valueSet>

<!-- Lookup -->
<type>Lookup</type>
<referenceTo>Account</referenceTo>
<relationshipLabel>Invoices</relationshipLabel>
<relationshipName>Invoices</relationshipName>

<!-- Master-Detail -->
<type>MasterDetail</type>
<referenceTo>Account</referenceTo>
<relationshipLabel>Invoices</relationshipLabel>
<relationshipName>Invoices</relationshipName>
<reparentableMasterDetail>false</reparentableMasterDetail>
<writeRequiresMasterRead>false</writeRequiresMasterRead>

<!-- Checkbox -->
<type>Checkbox</type>
<defaultValue>false</defaultValue>

<!-- Date -->
<type>Date</type>

<!-- DateTime -->
<type>DateTime</type>

<!-- Number -->
<type>Number</type>
<precision>18</precision>
<scale>0</scale>

<!-- Formula -->
<type>Text</type>
<formula>Account__r.Name &amp; ' - ' &amp; TEXT(Amount__c)</formula>
```

## Validation Rules
```xml
<!-- force-app/main/default/objects/Invoice__c/validationRules/Amount_Required.validationRule-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Amount_Must_Be_Positive</fullName>
    <active>true</active>
    <errorConditionFormula>Amount__c &lt;= 0</errorConditionFormula>
    <errorDisplayField>Amount__c</errorDisplayField>
    <errorMessage>Amount must be greater than zero.</errorMessage>
</ValidationRule>
```

## Permission Sets
```xml
<!-- force-app/main/default/permissionsets/Invoice_Manager.permissionset-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Invoice Manager</label>
    <hasActivationRequired>false</hasActivationRequired>
    <objectPermissions>
        <object>Invoice__c</object>
        <allowCreate>true</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <fieldPermissions>
        <field>Invoice__c.Amount__c</field>
        <editable>true</editable>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <field>Invoice__c.Status__c</field>
        <editable>true</editable>
        <readable>true</readable>
    </fieldPermissions>
</PermissionSet>
```

## Custom Permissions (for Flow Bypass)
```xml
<!-- force-app/main/default/customPermissions/Bypass_Automation.customPermission-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomPermission xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Bypass Automation</label>
    <isLicensed>false</isLicensed>
</CustomPermission>
```

### Additional Field Types

**Formula Field:**
```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>FullName__c</fullName>
    <label>Full Name</label>
    <type>Text</type>
    <formula>FirstName__c &amp; ' ' &amp; LastName__c</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>
</CustomField>
```

**Rollup Summary Field** (master-detail only):
```xml
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Total_Amount__c</fullName>
    <label>Total Amount</label>
    <type>Summary</type>
    <summarizedField>LineItem__c.Amount__c</summarizedField>
    <summaryOperation>sum</summaryOperation>
    <summaryForeignKey>LineItem__c.Order__c</summaryForeignKey>
</CustomField>
```

**Geolocation Field:**
```xml
<type>Location</type>
<displayLocationInDecimal>true</displayLocationInDecimal>
<scale>6</scale>
```

**Global Value Set (Reusable Picklist):**
```xml
<GlobalValueSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>Industries</masterLabel>
    <sorted>false</sorted>
    <customValue><fullName>Technology</fullName><default>false</default><label>Technology</label></customValue>
    <customValue><fullName>Healthcare</fullName><default>false</default><label>Healthcare</label></customValue>
</GlobalValueSet>
```

### Relationship Types
| Type | Delete Behavior | Rollup Summary | Reparenting | Max per Object |
|------|----------------|----------------|-------------|----------------|
| Master-Detail | Cascade delete | Yes | Configurable | 2 |
| Lookup | Block/Clear/Restrict | No | N/A | 40 (25 std) |
| External Lookup | N/A | No | N/A | - |
| Hierarchical | N/A | No | N/A | 1 (User only) |
| Junction (M2M) | Two master-details | On both parents | - | - |

### Record Types
```xml
<RecordType xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Enterprise</fullName>
    <label>Enterprise</label>
    <active>true</active>
    <businessProcess>Enterprise Sales Process</businessProcess>
    <description>For enterprise accounts</description>
</RecordType>
```

### Custom Metadata Types vs Custom Settings
| Feature | Custom Metadata Types | Custom Settings (Hierarchy) |
|---------|----------------------|---------------------------|
| Deployable | Yes (metadata) | No (data) |
| SOQL required | Yes (or getInstance) | No (getOrgDefaults) |
| User/Profile override | No | Yes |
| Counts against SOQL limit | Yes | No |
| Use for | Org config, mappings | User preferences |

### Permission Set Groups
```xml
<PermissionSetGroup xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Sales Team</label>
    <permissionSets>
        <permissionSet>Account_Manager</permissionSet>
        <permissionSet>Opportunity_Editor</permissionSet>
        <permissionSet>Report_Viewer</permissionSet>
    </permissionSets>
</PermissionSetGroup>
```

## SFDX Source Directory Structure
```
force-app/main/default/
├── objects/
│   └── Invoice__c/
│       ├── Invoice__c.object-meta.xml
│       ├── fields/
│       │   ├── Amount__c.field-meta.xml
│       │   └── Status__c.field-meta.xml
│       ├── validationRules/
│       │   └── Amount_Must_Be_Positive.validationRule-meta.xml
│       └── listViews/
│           └── All.listView-meta.xml
├── permissionsets/
│   └── Invoice_Manager.permissionset-meta.xml
├── customPermissions/
│   └── Bypass_Automation.customPermission-meta.xml
└── layouts/
    └── Invoice__c-Invoice Layout.layout-meta.xml
```

## Gotchas
- Max **40 custom relationships** per object (25 for standard objects)
- Formula fields **cannot reference** LongTextArea, RichTextArea, MultiSelectPicklist, or Encrypted fields
- Rollup Summary fields work **only on Master-Detail** relationships — not Lookups
- Global Value Sets **cannot be converted back** to local picklists once shared
- Encrypted Text fields are **not searchable or sortable**
- Record type-dependent picklists require **explicit value mapping** per record type
- Permission Set Groups **recalculate asynchronously** — changes may take minutes to apply
- Custom Metadata Type records **cannot be created/updated via DML in production** — deploy only
- Profiles are **notoriously merge-conflict-prone** — prefer Permission Sets for everything

## References
- [Schema Reference](references/schema-reference.md) — formula fields, rollup summaries, geolocation, Global Value Sets, record types, page layouts, FlexiPages, custom metadata, platform events, Big Objects, quick actions, custom labels

## Workflow
1. Understand object/field requirements
2. Generate SFDX source format XML files
3. Generate permission set for new objects/fields
4. Deploy schema first, then code that references it
5. Verify with: `sf org list metadata -m CustomObject --target-org myOrg`
