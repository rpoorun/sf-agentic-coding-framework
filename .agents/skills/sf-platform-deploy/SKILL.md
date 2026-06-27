---
name: sf-platform-deploy
description: "Salesforce DevOps automation using sf CLI v2. TRIGGER when: user deploys metadata, creates/manages scratch orgs or sandboxes, sets up CI/CD pipelines, or troubleshoots deployment errors with sf project deploy. DO NOT TRIGGER when: writing Apex code (use platform-apex-generate), building LWC components (use experience-lwc-generate), creating metadata definitions (use platform-custom-object-generate or platform-custom-field-generate), or querying org data (use platform-data-manage)."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-metadata-deploy
    - forcedotcom/sf-skills :: platform-metadata-retrieve
    - forcedotcom/sf-skills :: platform-metadata-api-context-get
    - Clientell-Ai/salesforce-skills :: sf-deploy
---

# sf-platform-deploy: Metadata Deployment

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-deploy` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-metadata-deploy; forcedotcom/sf-skills :: platform-metadata-retrieve; forcedotcom/sf-skills :: platform-metadata-api-context-get; Clientell-Ai/salesforce-skills :: sf-deploy |

Use this skill when the user needs **deployment orchestration**: dry-run validation, targeted or manifest-based deploys, CI/CD workflow advice, scratch-org management, failure triage, or safe rollout sequencing for Salesforce metadata.

Before any dry-run, validate-only, or real deploy to a sandbox/org, follow [DEPLOYMENT.md](../../workflows/DEPLOYMENT.md): run the mandatory pre-deploy org-conflict check (retrieve and diff the target org's current metadata; merge org-only elements into local before deploying, never overwrite an existing org feature outside scope) and the 95% Apex coverage gate (hard failure, cancels the deploy including dry-runs, if coverage is below 95% for any class/trigger in scope).

## When This Skill Owns the Task

Use `platform-metadata-deploy` when the work involves:
- `sf project deploy start`, `quick`, `report`, or retrieval workflows
- release sequencing across objects, permission sets, Apex, and Flows
- CI/CD gates, test-level selection, or deployment reports
- troubleshooting deployment failures and dependency ordering

Delegate elsewhere when the user is:
- authoring Apex code → [platform-apex-generate](../platform-apex-generate/SKILL.md)
- authoring LWC components → [experience-lwc-generate](../experience-lwc-generate/SKILL.md)
- creating custom objects or fields → [platform-custom-object-generate](../platform-custom-object-generate/SKILL.md), [platform-custom-field-generate](../platform-custom-field-generate/SKILL.md)
- building Flows → [automation-flow-generate](../automation-flow-generate/SKILL.md)
- doing org data operations → [platform-data-manage](../platform-data-manage/SKILL.md)
- authoring or testing Agentforce agents → [agentforce-generate](../agentforce-generate/SKILL.md)

---

## Critical Operating Rules

- Use **`sf` CLI v2 only**.
- On non-source-tracking orgs, deploy/retrieve commands require an explicit scope such as `--source-dir`, `--metadata`, or `--manifest`.
- Prefer **`--dry-run` first** before real deploys.
- For Flows, deploy safely and activate only after validation.
- Keep test-data creation guidance delegated to **`platform-data-manage`** after metadata is validated or deployed.

### Default deployment order
| Phase | Metadata |
|---|---|
| 1 | Custom objects / fields |
| 2 | Permission sets |
| 3 | Apex |
| 4 | Flows as Draft |
| 5 | Flow activation / post-verify |

This ordering prevents many dependency and FLS failures.

---

## Required Context to Gather First

Ask for or infer:
- target org alias and environment type
- deployment scope: source-dir, metadata list, or manifest
- whether this is validate-only, deploy, quick deploy, retrieve, or CI/CD guidance
- required test level and rollback expectations
- whether special metadata types are involved (Flow, permission sets, agents, packages)

Preflight checks:
```bash
sf --version
sf org list
sf org display --target-org <alias> --json
test -f sfdx-project.json
```

---

## Recommended Workflow

### 1. Preflight
Confirm auth, repo shape, package directories, and target scope.

### 2. Validate first
```bash
sf project deploy start --dry-run --source-dir force-app --target-org <alias> --wait 30 --json
```
Use manifest- or metadata-scoped validation when the change set is targeted.

### 3. If validation succeeds, offer the next safe workflow
After a successful validation, guide the user to the correct next action:
1. deploy now
2. assign permission sets
3. create test data via [platform-data-manage](../platform-data-manage/SKILL.md)
4. run tests / smoke checks
5. orchestrate multiple post-deploy steps in order

### 4. Deploy the smallest correct scope
```bash
# source-dir deploy
sf project deploy start --source-dir force-app --target-org <alias> --wait 30 --json

# manifest deploy
sf project deploy start --manifest manifest/package.xml --target-org <alias> --test-level RunLocalTests --wait 30 --json

# manifest deploy with Spring '26 relevant-test selection
sf project deploy start --manifest manifest/package.xml --target-org <alias> --test-level RunRelevantTests --wait 30 --json

# quick deploy after successful validation
sf project deploy quick --job-id <validation-job-id> --target-org <alias> --json
```

### 5. Verify
```bash
sf project deploy report --job-id <job-id> --target-org <alias> --json
```
Then verify tests, Flow state, permission assignments, and smoke-test behavior.

### 6. Report clearly
Summarize what deployed, what failed, what was skipped, and what the next safe action is.

Output template: [references/deployment-report-template.md](references/deployment-report-template.md)

---

## High-Signal Failure Patterns

| Error / symptom | Likely cause | Default fix direction |
|---|---|---|
| `FIELD_CUSTOM_VALIDATION_EXCEPTION` | validation rule or bad test data | adjust data or rule timing |
| `INVALID_CROSS_REFERENCE_KEY` | missing dependency | include referenced metadata first |
| `CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY` | trigger / Flow / validation side effect | inspect automation stack and failing logic |
| tests fail during deploy | broken code or fragile tests | run targeted tests, fix root cause, revalidate |
| field/object not found in permset | wrong order | deploy objects/fields before permission sets |
| Flow invalid / version conflict | dependency or activation problem | deploy as Draft, verify, then activate |

Full workflows: [references/orchestration.md](references/orchestration.md), [references/trigger-deployment-safety.md](references/trigger-deployment-safety.md)

---

## CI/CD Guidance

Default pipeline shape:
1. authenticate
2. validate repo / org state
3. static analysis
4. dry-run deploy
5. tests + coverage gates
6. deploy
7. verify + notify

- When org policy and release risk allow it, consider `--test-level RunRelevantTests` for Apex-heavy deployments.
- Pair this with modern Apex test annotations such as `@IsTest(testFor=...)` and `@IsTest(isCritical=true)` — see [platform-apex-generate](../platform-apex-generate/SKILL.md) for authoring guidance.

Static analysis now uses **Code Analyzer v5** (`sf code-analyzer`), not retired `sf scanner`.

Deep reference: [references/deployment-workflows.md](references/deployment-workflows.md)

---

## Agentforce Deployment Note

Use this skill to orchestrate **deployment/publish sequencing** around agents, but use the agent-specific skill for authoring decisions:
- [agentforce-generate](../agentforce-generate/SKILL.md) for `.agent` authoring, Agent Builder, Prompt Builder, and metadata config

For full agent DevOps details, including `Agent:` pseudo metadata, publish/activate, and sync-between-orgs, see:
- [references/agent-deployment-guide.md](references/agent-deployment-guide.md)

---

## Cross-Skill Integration

| Need | Delegate to | Reason |
|---|---|---|
| custom object creation | [platform-custom-object-generate](../platform-custom-object-generate/SKILL.md) | define objects before deploy |
| custom field creation | [platform-custom-field-generate](../platform-custom-field-generate/SKILL.md) | define fields before deploy |
| Apex authoring / fixes | [platform-apex-generate](../platform-apex-generate/SKILL.md) | code authoring and repair |
| Flow creation / repair | [automation-flow-generate](../automation-flow-generate/SKILL.md) | Flow authoring and activation guidance |
| test data or seed records | [platform-data-manage](../platform-data-manage/SKILL.md) | describe-first data setup and cleanup |
| Agent authoring and publish readiness | [agentforce-generate](../agentforce-generate/SKILL.md) | agent-specific correctness |

---

## Reference Map

### Start here
- [references/orchestration.md](references/orchestration.md)
- [references/deployment-workflows.md](references/deployment-workflows.md)
- [references/deployment-report-template.md](references/deployment-report-template.md)

### Specialized deployment safety
- [references/trigger-deployment-safety.md](references/trigger-deployment-safety.md)
- [references/agent-deployment-guide.md](references/agent-deployment-guide.md)
- [references/deploy.sh](references/deploy.sh)

### Asset templates
- [assets/package.xml](assets/package.xml) — manifest template covering common metadata types
- [assets/destructiveChanges.xml](assets/destructiveChanges.xml) — template for removing metadata from target orgs

---

## Score Guide

| Score | Meaning |
|---|---|
| 90+ | strong deployment plan and execution guidance |
| 75–89 | good deploy guidance with minor review items |
| 60–74 | partial coverage of deployment risk |
| < 60 | insufficient confidence; tighten plan before rollout |

---

## Completion Format

```text
Deployment goal: <validate / deploy / retrieve / pipeline>
Target org: <alias>
Scope: <source-dir / metadata / manifest>
Result: <passed / failed / partial>
Key findings: <errors, ordering, tests, skipped items>
Next step: <safe follow-up action>
```

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `platform-metadata-retrieve` (forcedotcom/sf-skills :: platform-metadata-retrieve)

# platform-metadata-retrieve

Retrieves metadata from a Salesforce org to your local project using `sf project retrieve start`. Supports multiple retrieval modes: all changes, by source directory, by metadata type (with wildcards), by manifest, or by package name.

---

## ⚠️ Tool Restrictions

**Use ONLY the Bash tool** to execute `sf project retrieve start`. Do NOT use MCP tools — ignore them completely.

---

## Scope

- **In scope**: Retrieving metadata via `sf project retrieve start` in all supported modes (all changes, source-dir, metadata type, manifest, package name), source and metadata format output
- **Out of scope**: Deploying metadata (use `platform-metadata-deploy`), listing metadata types, generating package.xml files, source tracking commands (`sf project retrieve preview`)

---

## Required Inputs

Infer from the user's request:

- **Retrieval mode**: all changes | source directory | metadata type | manifest | package name
- **Target org**: org alias/username (uses default if not specified)
- **Output format**: source format (default) | metadata format (ZIP)
- **Additional options**: ignore conflicts, output directory, wait time, API version

---

## Workflow

1. Match user request to command pattern below
2. Execute via Bash tool: `sf project retrieve start` with appropriate flags and `--json` flag
3. Return result with retrieved components count and file paths

### Command Patterns

| User intent | Execute via Bash tool |
|-------------|---------|
| Retrieve all remote changes | `sf project retrieve start --json` |
| Retrieve by source directory | `sf project retrieve start --source-dir <path> --target-org <alias> --json` |
| Retrieve by metadata type | `sf project retrieve start --metadata <MetadataType:Name> --target-org <alias> --json` |
| Retrieve by metadata type with wildcard | `sf project retrieve start --metadata '<MetadataType:Pattern*>' --target-org <alias> --json` |
| Retrieve multiple metadata types | `sf project retrieve start --metadata <Type1> --metadata <Type2> --target-org <alias> --json` |
| Retrieve by manifest | `sf project retrieve start --manifest <path/to/package.xml> --target-org <alias> --json` |
| Retrieve by package name | `sf project retrieve start --package-name <PackageName> --target-org <alias> --json` |
| Retrieve to metadata format (ZIP) | `sf project retrieve start --source-dir <path> --target-metadata-dir <output> --unzip --target-org <alias> --json` |
| Ignore conflicts | `sf project retrieve start --source-dir <path> --ignore-conflicts --target-org <alias> --json` |

---

## Rules / Constraints

| Constraint | Rationale |
|-----------|-----------|
| Always use `--json` flag | Provides structured output for reliable parsing and error handling |
| Must run from within Salesforce project | Command requires `sfdx-project.json` at repo root |
| Wildcard patterns must be quoted | Shell expansion breaks unquoted wildcards like `ApexClass:My*` |
| Cannot mix --manifest with --metadata or --source-dir | Mutually exclusive flags — command will error |
| Retrieve all changes requires source tracking | Production orgs don't support source tracking — must use other retrieval modes |
| --ignore-conflicts only works on trackable orgs | No effect on production orgs; applies to scratch/sandbox only |
| --output-dir must be inside project directory | Command validates output path is within project boundary |
| --output-dir cannot match package directory | Command fails if target matches `sfdx-project.json` packageDirectories |
| Default wait time is 33 minutes | Use --wait flag to override for large retrievals |
| Package retrieval is for reference only | Retrieved package metadata should not be added to source control for development |
| CustomField retrieval auto-includes CustomObject | When retrieving CustomField, CLI automatically adds CustomObject to get full context |

---

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| "This command is required to run from within an SFDX project" | Not in Salesforce project directory — cd to project root with `sfdx-project.json` |
| "No org found for <alias>" error | Org alias doesn't exist or isn't authenticated — verify with `sf org list` |
| "This org does not support source tracking" | Production org doesn't allow "retrieve all changes" mode — use --source-dir, --metadata, or --manifest instead |
| "ERROR running project retrieve start: Cannot mix --manifest with --metadata or --source-dir" | Remove conflicting flags — use one retrieval mode only |
| Wildcard pattern retrieves nothing | Pattern not quoted — wrap in single quotes: `'ApexClass:My*'` |
| "The package directory path in sfdx-project.json does not exist" | Output directory conflicts with package directory — use different path |
| "Output directory must be inside the project" | --output-dir path is outside project boundary — use relative path inside project |
| Retrieve times out | Increase wait time with `--wait 60` for large metadata volumes |
| Retrieved files overwrite local changes | Use `--output-dir` to retrieve to separate location, or commit local changes first |
| SourceConflictError with conflict table | Conflicts detected between local and remote on trackable org (scratch/sandbox) — resolve conflicts manually or use --ignore-conflicts to force overwrite |

---

## Output Expectations

The command returns JSON output with retrieved components details.

See `examples/success_output.json` and `examples/error_output.json` for response structures.

---

## Cross-Skill Integration

| Need | Delegate to |
|------|-------------|
| Deploy metadata to org | `platform-metadata-deploy` skill |
| Preview retrieve without executing | Execute `sf project retrieve preview --target-org <alias> --json` |
| List available metadata types | Execute `sf org list metadata-types --target-org <alias> --json` |

---

## Reference File Index

| File | When to read |
|------|-------------|
| `examples/success_output.json` | To understand successful retrieve response structure |
| `examples/error_output.json` | To handle common error scenarios |
| `references/retrieval_modes.md` | For detailed explanation of all retrieval modes and when to use each |
| `references/cli_flags.md` | For complete flag reference with usage patterns |

### Supplemental Guidance from `platform-metadata-api-context-get` (forcedotcom/sf-skills :: platform-metadata-api-context-get)

# Salesforce Metadata API Skill

This skill provides comprehensive documentation for all **604 Salesforce Metadata API types**. Use this skill to create, understand, and modify Salesforce metadata XML files in your Salesforce DX projects.

## Overview

The Salesforce Metadata API allows you to retrieve, deploy, create, update, or delete customizations for your org. This skill gives you access to detailed documentation for each metadata type, including:

- Field definitions and data types
- Required vs. optional fields
- WSDL schema definitions
- Sample XML structures
- File naming conventions
- Directory locations in Salesforce DX projects

## How to Use This Skill

### ⚡ CRITICAL: Section-Specific Consumption

**ALWAYS consume only the specific sections you need from JSON files, NOT entire files.**

**CRITICAL: For `data/metadata_api/*.json` files, always use `jq` or programmatic JSON parsing to extract only the specific sections you need.** Do not load these files whole via `Read`, `cat`, `read_file`, or any other tool that injects the complete file — they contain verbose WSDL segments and other sections that waste 60-80% of tokens. (Loading small files like this SKILL.md or the index table with `Read` is fine; the rule applies specifically to the large metadata-type JSON files.)

Each JSON file contains multiple sections (fields, description, wsdl_segment, etc.). Most use cases only require 1-2 sections:

- **For field definitions**: Load only the `fields` section
- **For understanding purpose**: Load only the `description` section
- **For XML examples**: Load only the `declarative_metadata_sample_definition` section
- **Skip by default**: `wsdl_segment` (verbose schema), `file_information`, `directory_location`

This reduces token consumption by **60-80% per file**.

### Quick Start

To get information about a specific metadata type:

1. **Section-specific** (BEST): "Show me only the 'fields' section from CustomObject.json"
2. **Multiple sections**: "Show me 'fields' and 'description' from Flow.json"
3. **Avoid loading entire files**: Don't ask for "the CustomObject metadata type" - specify sections

### Example Queries (Section-Specific)

- ✅ "Show me only the 'fields' section from CustomObject.json"
- ✅ "What fields are in the 'fields' section of Profile.json?"
- ✅ "Load the 'description' and 'fields' sections from Flow.json"
- ✅ "Give me just the 'declarative_metadata_sample_definition' from ApexClass.json"
- ❌ "Show me the CustomObject metadata type" (too broad - entire file)
- ❌ "Load CustomObject.json" (includes unnecessary WSDL and other sections)

## JSON File Structure

Each metadata type is stored as a JSON file in `data/metadata_api/` with the following structure:

```json
{
  "sections": ["title", "description", "fields", "wsdl_segment", ...],
  "title": "MetadataTypeName - Metadata API",
  "description": "Plain-text description of the metadata type.",
  "fields": {
    "fieldName": {
      "type": "string",
      "description": "Field description",
      "required": true
    }
  },
  "file_information": ".object",
  "directory_location": "objects",
  "wsdl_segment": "<xsd:complexType>...</xsd:complexType>",
  "declarative_metadata_sample_definition": [
    {
      "description": "Example description",
      "code": "<?xml version=\"1.0\"?>\n<MetadataType>...\n</MetadataType>"
    }
  ]
}
```

> **Note:** string values (`title`, `description`, `file_information`, `directory_location`, `wsdl_segment`) are stored as **plain text** — no markdown headers (`#`/`##`) or code fences. `file_information` holds just the file suffix (e.g. `.object`, `.ai`) and `directory_location` just the SFDX folder name (e.g. `objects`, `aiApplications`).

### Available Sections

The `sections` array indicates which top-level keys are present in each file. Common sections include:

- `title`: The metadata type name and header
- `description`: What the metadata type represents
- `fields`: The type's own fields, with types and descriptions
- `sub_types`: (composite types only) a map of referenced sub-type name → that sub-type's fields, e.g. `Flow` → `sub_types.FlowActionCall`
- `file_information`: File naming conventions and extensions
- `directory_location`: Where files are stored in SFDX projects
- `wsdl_segment`: XML schema definition from the WSDL
- `declarative_metadata_sample_definition`: Example XML code

Some metadata types have additional sections specific to their functionality. See the [Index Table](references/metadata_index_table.md) for a complete breakdown.


> **More detail:** background on *why* token optimization matters, worked usage examples, common workflows, a full section glossary, and versioning/support notes live in [`references/usage_guide.md`](references/usage_guide.md). Load it with the `Read` tool only when needed.

## Token Optimization Strategies

**CRITICAL**: To minimize token usage and costs:
1. Load only the specific metadata type(s) you need, not the full corpus
2. **Load only specific sections from each file, not entire files**

### Section-Specific Loading (BEST PRACTICE)

**⚠️ CRITICAL WARNING: DO NOT use the `read_file` tool (or any whole-file reading tool) on these JSON files!**

`read_file` loads the entire file content into your context, defeating the purpose of section-specific consumption. You will waste 60-80% of your token budget loading unnecessary WSDL segments and verbose sections. (Using `Read` on small files such as this SKILL.md or the index table is fine — this rule is only about the large metadata-type JSON files.)

**Approach**: Programmatically parse the JSON file and extract ONLY the sections you need using code, not whole-file reading tools.

**Working Examples Available**:

We provide complete, working code examples in multiple languages:

- **Python**: [`examples/python_section_loading.py`](examples/python_section_loading.py) - Shows `json.load()` with section extraction
- **JavaScript/Node.js**: [`examples/javascript_section_loading.js`](examples/javascript_section_loading.js) - Shows `JSON.parse()` with section extraction
- **Bash + jq**: [`examples/bash_section_loading.sh`](examples/bash_section_loading.sh) - Shows `jq` command-line JSON processing

See [`examples/README.md`](examples/README.md) for complete documentation and usage instructions.

**Quick Pattern** (adapt to your language):
1. Read the JSON file
2. Parse it into a data structure
3. Extract ONLY the sections you need (e.g., `fields`, `description`)
4. Ignore verbose sections (`wsdl_segment`, `declarative_metadata_sample_definition`)

### What NOT to Do

**❌ NEVER use the `read_file` tool on these JSON files**:
```text
read_file data/metadata_api/CustomObject.json  # Loads entire file into context!
read_file data/metadata_api/Flow.json          # Wastes 60-80% tokens!
```

**❌ NEVER load all files**:
```text
read_file data/metadata_api/*.json  # This loads ~15MB of data!
```

**Token Impact**:
- Section-specific: **50-200 tokens** per metadata type
- Entire file: **500-2000 tokens** per metadata type
- **Savings: 60-80% per file**

### When to Load Multiple Types

- **Related types**: CustomObject + CustomField + ValidationRule
- **Permission sets**: Profile + PermissionSet + PermissionSetGroup
- **UI components**: Layout + CompactLayout + QuickAction
- **Automation**: Flow + WorkflowRule + ApexTrigger

### When to Load Specific Sections (STRONGLY RECOMMENDED)

Many metadata types have large WSDL segments or extensive field lists. **Always load only the specific sections you need from each JSON file** rather than consuming the entire file:

1. **First, check available sections** by reading just the `sections` array from the JSON
2. **Extract only the sections you need** (e.g., `fields` for field definitions, `description` for overview)
3. **Skip WSDL segments** unless you specifically need schema validation
4. **Skip declarative_metadata_sample_definition** unless you need complete XML examples

This approach can reduce token consumption by **60-80%** per file by excluding verbose WSDL definitions and lengthy examples.

## Conceptual Approach to Using This Skill

### Step 1: Identify Your Need

Ask yourself:
- What am I trying to build or modify?
- Which Salesforce metadata type(s) am I working with?
- **Which specific information do I need?**
  - Field definitions only? → Load `fields` section
  - Understanding what it does? → Load `description` section
  - XML example? → Load `declarative_metadata_sample_definition` section
  - Schema validation? → Load `wsdl_segment` section (rarely needed)

### Step 2: Find the Right Type

Use one of these methods:
- **Direct reference**: If you know the type name (e.g., "CustomObject")
- **Index search**: Check `references/metadata_index_table.md` for related types
- **Common types**: See the "Quick Reference: Common Metadata Types" section below

### Step 3: Load Selectively (Section-Specific) ⚡

**Decision Tree for Section Loading**:

```text
Need field definitions?
  → Load ONLY 'fields' section (~50-200 tokens)

Need to understand what the type does?
  → Load ONLY 'description' section (~20-100 tokens)

Need XML structure example?
  → Load ONLY 'declarative_metadata_sample_definition' (~100-300 tokens)

Need all three?
  → Load 'fields' + 'description' + 'declarative_metadata_sample_definition'
  → Still skip 'wsdl_segment', 'file_information', 'directory_location'
  → Savings: ~60-70% vs loading entire file

Need schema validation?
  → Only then load 'wsdl_segment' (this is verbose)
```

**Request format**:
- **Single section** (BEST): "Show me only the 'fields' section from ApexClass.json"
- **Multiple sections**: "Load 'fields' and 'description' from CustomObject.json"
- **Skip verbose sections**: Never load `wsdl_segment` unless explicitly needed

### Step 4: Apply to Your Code

Use the loaded information to:
- Create new metadata XML files
- Understand existing files in your project
- Validate field names and types
- Generate correct XML structure with proper namespaces

## File Location

All metadata type JSON files are located in:

```text
data/metadata_api/
├── CustomObject.json
├── Flow.json
├── ApexClass.json
├── Profile.json
└── ... (600 more files)
```


### Path Resolution

When using this skill, files are referenced as:
- Absolute: `data/metadata_api/CustomObject.json`
- Relative to skill root: `./data/metadata_api/CustomObject.json`

The skill will automatically resolve paths based on the working directory.

## Metadata File Generation Requirements

When generating Salesforce metadata XML files, follow these requirements to ensure valid, deployable files.

### XML Structure Requirements

All metadata files must:

1. **Include XML declaration**:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   ```

2. **Use correct namespace**:
   ```xml
   <CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
   ```

3. **Match root element to metadata type**:
   - CustomObject → `<CustomObject>`
   - Flow → `<Flow>`
   - Profile → `<Profile>`
   - etc.

### Namespace Declaration

The namespace is **required** and must be exactly:
```text
http://soap.sforce.com/2006/04/metadata
```

**Correct**:
```xml
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
```

**Incorrect**:
```xml
<CustomObject>  <!-- Missing namespace -->
<CustomObject xmlns="http://salesforce.com/metadata">  <!-- Wrong namespace -->
```

### Required vs. Optional Fields

Each metadata type has different field requirements:

- **Schema-required** (`required: true` in the JSON): the WSDL marks the field as required.
- **Effectively required** (not flagged but practically needed): in many cases the WSDL marks fewer fields as required than the authoring contract actually demands. CustomObject is the canonical example — the JSON marks only `externalDataSource`, `externalName`, `nameField` as `required: true` (the first two are external-object-only quirks), but a normal `__c` CustomObject also needs `label`, `pluralLabel`, `deploymentStatus`, and `sharingModel` to deploy. Always cross-check with the `declarative_metadata_sample_definition` examples.
- **Conditionally required**: some fields are required only when certain features are enabled.
- **Optional**: most fields can be omitted if not needed.

**Example from CustomObject** (note: practical authoring needs more than what `required: true` marks):
```json
{
  "fields": {
    "nameField": {
      "type": "CustomField",
      "description": "The name field for the custom object",
      "required": true
    },
    "label": {
      "type": "string",
      "description": "The label for the custom object (effectively required for normal __c objects)",
      "required": false
    },
    "sharingModel": {
      "type": "SharingModel (enumeration)",
      "description": "The sharing model for the object (effectively required for normal __c objects)",
      "required": false
    },
    "enableHistory": {
      "type": "boolean",
      "description": "Enable field history tracking",
      "required": false
    }
  }
}
```

### Validation Tips

Before deploying:

1. **Validate XML syntax**: Ensure well-formed XML (matching tags, proper nesting)
2. **Check required fields**: Verify all required fields are present
3. **Verify namespaces**: Namespace must be exact
4. **Test field types**: Ensure field values match expected types
5. **Use Salesforce CLI**: Run `sf project deploy validate` to catch errors

> **More detail:** field-type→XML mapping tables, file-naming/two-file/child-type conventions, and full well-formed-file examples are in [`references/usage_guide.md`](references/usage_guide.md).
## Duplicate and Ambiguous Type Names

Some Metadata API type names also exist as Enterprise/Data API or Tooling API object names. Examples include ApexClass, ApexTrigger, CustomField, CustomObject, EmailTemplate, Layout, Profile, PermissionSet, RecordType, StaticResource, WebLink, ValidationRule, and Flow.

When the prompt is ambiguous (e.g., "tell me about Profile" or "what fields are on ApexClass"), ask whether the user wants:

1. **Metadata API** XML structure for source/deployment authoring (this skill, e.g. `.profile-meta.xml`, `.cls-meta.xml`).
2. **Enterprise/Data API** runtime sObject/record reference (no dedicated skill currently — fall back to the Salesforce API family router).
3. **Tooling API** developer tooling record reference (no dedicated skill currently — fall back to the Salesforce API family router).

Heuristics that resolve most ambiguity without asking:

- Mentions of `package.xml`, `force-app/`, `sfdx`, `.meta.xml`, "deploy", "retrieve", "authoring", "blueprint", "template", "class definition", or "permissions" in a deployment sense → Metadata API (this skill).
- "What fields are on X" / "what columns" / "DML" / "SOQL" / "query" / "REST" / "sObject" / "record" / "runtime" → Enterprise/Data or Tooling API (other skill).
- Tooling-specific signals: "Tooling API", `ApexCodeCoverage`, `EntityDefinition`, `TraceFlag`, "code coverage", "compile errors", `SymbolTable`, debug logging → Tooling API.

**Default-when-no-signals rule**: if the prompt has none of the signals above AND this skill (`platform-metadata-api-context-get`) was invoked directly by name, default to the Metadata API interpretation and explicitly disclose the assumption to the user (e.g., "Interpreting this as the Metadata API type for `.cls-meta.xml` authoring; let me know if you meant the Tooling API record or Enterprise/Data sObject"). The skill-invocation context itself is a signal of authoring/deployment intent.

## Troubleshooting

### File Not Found

**Problem**: Cannot find metadata type file

**Solutions**:
- File names are **case-sensitive PascalCase** with no separators (e.g., `CustomObject.json`, NOT `customobject.json`, `Custom_Object.json`, or `Custom-Object.json`).
- Before declaring "not found", consult `references/metadata_index_table.md`. Use this two-pass recovery algorithm against the index:
  1. **Normalize-and-substring** (handles case + separator variants): strip non-alphanumeric characters and lowercase both the query and each index entry, then look for substring matches. Resolves: `customobject`, `Custom_Object`, `Custom-Object` → `CustomObject`.
  2. **On miss, fuzzy-match** (handles missing-letter typos): use `difflib.get_close_matches(query_normalized, index_normalized, n=3, cutoff=0.7)` or Levenshtein distance ≤ 2. Resolves: `customfeld` → `CustomField`, `apxclass` → `ApexClass`. Pure substring matching cannot recover character deletions.
- **Multi-hit tiebreaker**: when normalize-and-substring returns multiple matches (e.g., `customobject` matches both `CustomObject` and `CustomObjectTranslation`), prefer the entry whose normalized length **equals** the normalized query length; otherwise prefer the shortest match.
- Some types have unexpected naming conventions (no underscores, no spaces, no abbreviations like "OAuth"); the index is the source of truth.

### SOAP Envelope / Header Types (thin by design)

Two related patterns to recognize:

1. **Result types** (`AsyncResult`, `SaveResult`, `DeleteResult`, `UpsertResult`, `Error`, `DescribeMetadataResult`, etc.) — `fields` is empty AND `wsdl_segment` is populated. These are SOAP response wrappers; their schema lives entirely in `wsdl_segment`. Consume that section if you need their structure. They are not deployable source files.
2. **SOAP request headers** (`AllOrNoneHeader`, `SessionHeader`, `CallOptions`, `DebuggingHeader`, `OwnerChangeOptions`, etc.) — `fields` has 1–2 minimal entries, no `wsdl_segment`. These configure SOAP request behavior; they are call-time options, not metadata you author or deploy.

In both cases, the thin JSON output is correct. Don't try to author a `.AsyncResult-meta.xml` — these types have no source-file form.

### Missing Section

**Problem**: Expected section not in JSON file

**Solutions**:
- Check the `sections` array to see what's available
- Not all metadata types have all sections
- Some sections are type-specific (noted in index table)

### Incomplete Field Information

**Problem**: Field definition lacks details

**Solutions**:
- Check `wsdl_segment` for complete schema definition
- Some fields have complex types defined in WSDL
- Cross-reference with Salesforce documentation for enumerations

### Following Sub-Type Pointers (e.g., `ProfileObjectPermissions[]`)

When the `fields` section gives a complex type name like `ProfileObjectPermissions[]` or `LayoutItem[]` or `ApprovalStep[]`, the sub-fields of that nested type are NOT in the `fields` section — they live in `wsdl_segment` for that complex type. The skill's "skip wsdl_segment by default" rule is for token economy on the simple-field path; for nested types you need to drill in.

**Worked example** — find the sub-fields of `objectPermissions` on Profile:

```bash
# 1. Get the field type name from the fields section
jq '.fields.objectPermissions' data/metadata_api/Profile.json
# → {"type": "ProfileObjectPermissions[]", ...}

# 2. Pull just the matching complexType from wsdl_segment using grep -A
jq -r '.wsdl_segment' data/metadata_api/Profile.json   | grep -A 30 'complexType name="ProfileObjectPermissions"'
```

The `grep -A N` window keeps token cost ~150 tokens instead of loading the whole `wsdl_segment` (which can be 5K+ tokens on large types). Use this pattern any time `fields` returns a `Foo[]` type and you need Foo's sub-fields.

### XML Generation Errors

**Problem**: Generated XML fails validation

**Solutions**:
- Verify namespace is exactly: `http://soap.sforce.com/2006/04/metadata`
- Check all required fields are present
- Ensure field values match expected types
- Validate XML syntax (closing tags, proper nesting)

### Deployment Failures

**Problem**: Metadata file won't deploy

**Solutions**:
- Run `sf project deploy validate` first
- Check Salesforce API version compatibility
- Verify file naming matches conventions
- Ensure directory structure matches SFDX format

## Quick Reference: Common Metadata Types

Here are the most frequently used metadata types:

- **CustomObject**: defines the schema for a custom sObject, including fields, relationships, and settings
- **Flow**: automates business processes using a visual canvas of elements and connectors
- **ApexClass**: compiled Apex server-side class; includes body, API version, and status
- **ApexTrigger**: Apex code that executes before/after DML events on a specific sObject
- **Profile**: controls object/field permissions, app visibility, and login settings for a user profile
- **PermissionSet**: additive set of permissions granted to users independently of their profile
- **CustomField**: defines a field on a standard or custom object, including type, picklist values, and formula
- **Layout**: controls the arrangement of fields and related lists on a record detail/edit page
- **ValidationRule**: enforces data quality by preventing saves when a formula condition is true
- **ApexPage**: Visualforce page definition, including controller reference and markup
- **ApexComponent**: reusable Visualforce component that can be embedded in pages
- **CustomTab**: defines a tab pointing to a custom object, Visualforce page, or web URL
- **CustomApplication**: defines an app's tab bar, nav items, and branding
- **LightningComponentBundle**: LWC bundle including JS, HTML, and metadata descriptor
- **AuraDefinitionBundle**: Aura (Lightning) component bundle with component, controller, helper files
- **StaticResource**: uploaded file (JS, CSS, image, ZIP) accessible from Visualforce and LWC
- **EmailTemplate**: email template for use in workflow rules, Process Builder, or Apex
- **Report**: saved report definition including filters, groupings, and columns
- **Dashboard**: collection of dashboard components backed by reports

For a complete list of all metadata types, see [Index Table](references/metadata_index_table.md).

### Supplemental Guidance from `sf-deploy` (Clientell-Ai/salesforce-skills :: sf-deploy)

# Deployment Orchestrator

You are a Salesforce deployment specialist. Manage multi-step deployments with error handling and dependency resolution.

## Deployment Workflow

### 1. Pre-Deployment Checks
```bash
# Verify org connection
sf org display --target-org myOrg

# Check what will be deployed
sf project deploy preview -d force-app/

# Validate without deploying
sf project deploy start -d force-app/ --dry-run --target-org myOrg
```

### 2. Generate package.xml
```bash
# From org (full manifest)
sf project generate manifest --from-org myOrg --output-dir manifest/

# From local source
sf project generate manifest -d force-app/ --output-dir manifest/
```

### 3. Deployment Order (Dependencies First)
Deploy in this order to avoid dependency failures:
1. **Custom Objects & Fields** — schema must exist before code references it
2. **Custom Labels & Custom Metadata** — referenced by Apex and Flows
3. **Permission Sets & Custom Permissions** — required by bypass logic
4. **Apex Classes** — service classes, selectors, utilities first
5. **Apex Triggers** — depend on handler classes
6. **Flows** — may reference Apex actions
7. **LWC** — may wire to Apex controllers
8. **Layouts, FlexiPages, Profiles** — reference everything above

### 4. Deploy Commands
```bash
# Deploy specific directory
sf project deploy start -d force-app/main/default/classes/ --target-org myOrg

# Deploy with specific tests
sf project deploy start -d force-app/ --test-level RunSpecifiedTests --tests MyClassTest,MyOtherClassTest --target-org myOrg

# Deploy with all tests (production)
sf project deploy start -d force-app/ --test-level RunLocalTests --target-org myOrg

# Deploy specific metadata
sf project deploy start -m ApexClass:MyClass,ApexClass:MyClassTest --target-org myOrg

# Quick deploy (after successful validation)
sf project deploy quick --job-id <validationId> --target-org myOrg
```

### 5. Delta Deployments
For CI/CD, deploy only changed files:
```bash
# Using sfdx-git-delta
sfdx sgd:source:delta --from origin/main --to HEAD --output delta/
sf project deploy start -d delta/force-app/ --target-org myOrg
```

### Scratch Org Workflows
```bash
# Create scratch org from definition file
sf org create scratch -f config/project-scratch-def.json -a scratch1 -d 30

# Create from org shape (clones source org config)
sf org create scratch --source-org prodOrg -a scratch1

# Delete scratch org
sf org delete scratch -o scratch1 --no-prompt
```

### Package Development
```bash
# Create unlocked package
sf package create --name "My Package" --package-type Unlocked --path force-app

# Create package version
sf package version create --package "My Package" --installation-key test1234 --wait 10

# Install package in target org
sf package install --package 04t... --target-org myOrg --wait 10
```
- **Unlocked Packages**: Org-independent, no namespace lock, editable after install
- **2GP Managed**: Namespace-locked, IP protection, AppExchange distribution

### Destructive Changes
```xml
<!-- destructiveChangesPost.xml — deletes AFTER deployment -->
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>OldClass</members>
        <name>ApexClass</name>
    </types>
    <version>62.0</version>
</Package>
```
- `destructiveChangesPre.xml` — deletes BEFORE deploy (remove dependencies first)
- `destructiveChangesPost.xml` — deletes AFTER deploy (clean up replaced components)
- Deploy with: `sf project deploy start -d force-app/ --post-destructive-changes destructiveChangesPost.xml`

### Authentication Methods
| Method | Use Case | Command |
|--------|----------|---------|
| Web Login | Interactive / dev | `sf org login web` |
| JWT Bearer | CI/CD (headless) | `sf org login jwt --client-id ... --jwt-key-file ...` |
| SFDX Auth URL | CI/CD (simpler) | `sf org login sfdx-url --sfdx-url-file authUrl.txt` |
| Device Flow | Headless (no cert) | `sf org login device` |

### Salesforce Code Analyzer
```bash
# Run static analysis
sf scanner run --target force-app/ --format csv --outfile results.csv

# Run with specific rules
sf scanner run --target force-app/ --category "Security,Best Practices"
```

### Test Level Guide
| Level | When | Command Flag |
|-------|------|-------------|
| NoTestRun | Non-prod, metadata-only | `--test-level NoTestRun` |
| RunSpecifiedTests | Known affected tests | `--test-level RunSpecifiedTests --tests MyTest` |
| RunLocalTests | Production deploy | `--test-level RunLocalTests` |
| RunAllTestsInOrg | Full validation | `--test-level RunAllTestsInOrg` |

## Error Diagnosis

### Common Deployment Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Entity not found: CustomObject__c` | Missing dependency | Deploy custom object first |
| `Dependent class is invalid` | Compile error in dependency | Fix dependent class first |
| `Code coverage is below 75%` | Insufficient tests | Run `sf-test` skill to generate tests |
| `Component not found: c:myComponent` | Missing LWC dependency | Deploy LWC before FlexiPage |
| `Test failure: System.AssertException` | Test expecting wrong data | Fix test assertions |
| `FIELD_CUSTOM_VALIDATION_EXCEPTION` | Validation rule blocking test data | Update test data to pass validation |
| `INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY` | Sharing/permission issue | Check profile/permission set deployment |

### Diagnosing Failures
```bash
# Check deploy status
sf project deploy report --job-id <jobId>

# Get detailed error info
sf project deploy resume --job-id <jobId>
```

## CI/CD Pipeline (GitHub Actions)
```yaml
name: Salesforce CI/CD
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm install @salesforce/cli -g
      - name: Authenticate
        run: sf org login jwt --client-id ${{ secrets.SF_CLIENT_ID }} --jwt-key-file server.key --username ${{ secrets.SF_USERNAME }} --instance-url ${{ secrets.SF_INSTANCE_URL }} --alias ci-org
      - name: Validate
        run: sf project deploy start -d force-app/ --dry-run --test-level RunLocalTests --target-org ci-org

  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm install @salesforce/cli -g
      - name: Authenticate
        run: sf org login jwt --client-id ${{ secrets.SF_CLIENT_ID }} --jwt-key-file server.key --username ${{ secrets.SF_USERNAME }} --instance-url ${{ secrets.SF_INSTANCE_URL }} --alias prod-org
      - name: Deploy
        run: sf project deploy start -d force-app/ --test-level RunLocalTests --target-org prod-org
```

## Gotchas
- **Profiles cause merge conflicts** — prefer Permission Sets for deployable permissions
- Destructive changes **cannot be rolled back** — always validate first
- Quick deploy validations **expire after 10 days**
- Source tracking resets when scratch org expires
- Package dependencies must be installed **in dependency order**
- API version mismatches between components can cause **silent deployment failures**
- `RunLocalTests` skips managed package tests — `RunAllTestsInOrg` includes them
- Sandbox refresh **does not preserve manual configuration changes**

## Rollback Strategy
Salesforce has no native rollback. Mitigation:
1. Always validate (`--dry-run`) before deploying
2. Keep previous version in git — rollback = deploy previous commit
3. For destructive changes, prepare `destructiveChangesPost.xml`
4. Use scratch orgs / sandboxes for testing before production

## References
- [Deploy Patterns](references/deploy-patterns.md) — scratch orgs, packages, destructive changes, sandbox types, Code Analyzer, sfdx-git-delta, auth methods, DevOps Center

## Workflow
1. Verify org authentication and connection
2. Analyze what needs to be deployed
3. Resolve dependencies and determine deploy order
4. Validate deployment (dry-run)
5. Deploy with appropriate test level
6. Monitor deployment status
7. Diagnose and fix any errors
8. Verify deployment success
