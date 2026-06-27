# Documentation Standards

## Purpose And Use

This file defines how to write and maintain technical documentation that describes a Salesforce implementation's actual Apex, LWC, configuration, and automation. Read it before generating, updating, or reviewing anything under a project's `docs/` tree (architecture write-ups, data-model docs, security model docs, automation inventories, glossaries). Put documentation structure, sourcing/verification rules, style conventions, and content inclusion/exclusion rules here.

This file documents *how to write project documentation*. It is not the same as `sf-platform-docs`, which looks up official Salesforce product documentation — use this file when the deliverable is documentation *about this project's own code and configuration*.

## Persona

Write as a Salesforce technical expert producing documentation for functional experts, technical architects, and developers. Precise and factual, concise without being shallow, technical but readable. Never use marketing language or superlatives.

## Core Principle: Document Only What Exists

This is the non-negotiable rule of this file: **never invent code, configuration, or values.**

| Do | Don't |
| --- | --- |
| Read the source file before documenting a class, object, or flow | Invent a code example |
| Verify picklist values against the metadata file or Standard Value Set | Assume a field's possible values without checking |
| Run the actual test suite to get real coverage numbers | State a coverage percentage that wasn't measured |
| Document only what is deployed/implemented | Document a planned or partially-built feature as if it were live |

## Mandatory Source Verification

Before documenting any element, verify it against its source file. Do not document from memory or from the ticket description alone.

| Element | Source to verify |
| --- | --- |
| Apex class | `force-app/main/default/classes/{ClassName}.cls` |
| Record Type | `force-app/main/default/objects/{Object}/recordTypes/*.xml` |
| Custom field | `force-app/main/default/objects/{Object}/fields/*.xml` |
| Flow | `force-app/main/default/flows/{FlowName}.flow-meta.xml` |
| Custom Metadata | `force-app/main/default/customMetadata/*.md-meta.xml` |
| Custom Label | `force-app/main/default/labels/CustomLabels.labels-meta.xml` |
| Permission Set | `force-app/main/default/permissionsets/*.permissionset-meta.xml` |
| Validation Rule | `force-app/main/default/objects/{Object}/validationRules/*.xml` |

Verification commands:

```bash
# Class exists?
ls force-app/main/default/classes/{ClassName}.cls

# Search for a pattern across Apex
grep -r "PATTERN" force-app/main/default/classes/

# List Record Types for an object
ls force-app/main/default/objects/{Object}/recordTypes/

# Picklist values: field-level or Standard Value Set
cat force-app/main/default/objects/{Object}/fields/{Field}.field-meta.xml
cat force-app/main/default/standardValueSets/{ValueSet}.standardValueSet-meta.xml

# Real test coverage (requires an authenticated org; org reads are allowed for this without further confirmation per AGENTS.md)
sf apex run test --target-org {alias} --code-coverage --result-format json
```

## Documentation Tree

Recommended structure for a project's `docs/` folder — adapt numbering and domain folder names to the project, but keep the shape:

```
docs/
├── 00-index.md                      # Landing page and navigation
├── 01-architecture/
│   ├── overview.md                  # Architectural decisions
│   ├── data-model.md                # Objects and fields
│   └── integrations.md              # External APIs
├── 02-{functional-domain-1}/
│   └── {process}.md
├── 03-{functional-domain-2}/
│   └── {process}.md
├── 04-security/
│   ├── security-model.md            # Profiles, Permission Set Groups, sharing
│   ├── authentication-sso.md        # SSO, if applicable
│   └── apex-security-practices.md   # Code-level security patterns
├── 05-automation/
│   ├── flows-architecture.md        # Flow inventory and logic
│   └── validation-rules.md
└── 06-appendix/
    ├── naming-conventions.md
    ├── test-coverage.md             # Test data factories and coverage
    └── glossary.md
```

`00-index.md` must contain: a short project summary (2-3 lines), functional scope and context, an architecture-principles summary, a complete table of contents linking every document, a "quick access by use case" section, and a version history.

## Writing Conventions

### Language

Use the project's established documentation language for prose (labels, descriptions, titles) — do not assume English or any other language; follow whatever the repository's existing docs, README, or the user already use. Regardless of prose language, always keep the following in their original, unverified form: Apex code, variable names, API names, class names, and method names — never translate or paraphrase a code identifier.

### Markdown Formatting

Underscores in prose are interpreted as italics — always wrap a literal identifier containing `_` in backticks:

```markdown
❌ | Suffix | Usage |
   | _CTL   | Controller |

✅ | Suffix  | Usage |
   | `_CTL` | Controller |
```

- Always use tables for structured lists (suffix conventions, field mappings, status values).
- Use Mermaid for diagrams (state diagrams, sequence diagrams, ERDs) — supported natively by GitHub, GitLab, and VS Code.
- Short, direct sentences. Bullet lists for enumerations. Tables for structured facts. Code examples copied from the actual project, never invented.
- No emojis unless the user explicitly asks for them. No marketing language or superlatives ("powerful", "seamless", "cutting-edge").

## Content: Include vs. Exclude

### Include (project-specific value)

| Type | Example |
| --- | --- |
| Architectural decisions | Why Person Account was chosen over standard Contact |
| Project-specific configuration | Actual Custom Metadata values, real delay-in-minutes settings |
| Business process | State diagrams, allowed transitions |
| Data mapping | External system field → Salesforce field |
| Key classes and methods | With the real method signature from source |
| Test coverage | Real, measured percentages per class |

### Exclude (generic noise)

| Type | Reason |
| --- | --- |
| Basic Salesforce platform concepts | Any Salesforce developer already knows them |
| Links to generic Salesforce product docs | Easily found independently; use `sf-platform-docs` to look them up live instead of duplicating them in project docs |
| Generic "best practice" platitudes | Too vague to be actionable ("clarity over brevity") |
| Empty or placeholder sections | Omitting a section is better than a stub that looks finished but isn't |
| Undeployed or unimplemented features | Creates false confidence about what actually exists |

## Verification Checklist Before Publishing

- [ ] Every class name referenced matches an actual `.cls` file.
- [ ] Every Record Type referenced matches an actual `recordType-meta.xml` file.
- [ ] Every picklist value was verified against its metadata file or Standard Value Set.
- [ ] Every code excerpt was copied from the real source file, not written from memory.
- [ ] Test coverage numbers come from an actual test run, not an estimate.
- [ ] Every cross-reference link points to a file that exists.
- [ ] Every table renders correctly in Markdown preview.
- [ ] No generic, non-project-specific content remains.

## Avoiding Redundancy

Acceptable (aids navigation): a short summary of a concept in one document with a link to the authoritative detail elsewhere; the same status table appearing once in a glossary and once inline in the relevant process doc.

Avoid (creates a maintenance burden): copy-pasting full lists between documents, duplicating code excerpts, or repeating detailed configuration values in more than one place. Use a cross-reference instead:

```markdown
See [Milestones and Deadlines](./milestones-deadlines.md) for the implementation detail.
```

## When To Update

Update the documentation when: a new feature is implemented and deployed, an existing configuration changes, an error is found in the existing documentation, or the org's Salesforce API version changes.

Update procedure: verify the source (code/metadata) before editing → update the affected content → update the date/version in `00-index.md` → check and fix any cross-references the change affects.

## Anti-Patterns

**Invented documentation** — never describe a class's behavior without having read it first:
```text
❌ "AccountService_SVC handles business logic for..." (never opened the file)
✅ Read it first: cat force-app/main/default/classes/AccountService_SVC.cls
   Then document what the code actually does.
```

**Assumed values** — never state picklist/status values from memory:
```text
❌ "Possible statuses are: New, In Progress, Closed" (invented)
✅ Verify in: force-app/main/default/standardValueSets/CaseStatus.standardValueSet-meta.xml
   or the field's field-meta.xml
```

**Generic code examples** — never substitute a made-up snippet for the real one:
```apex
❌ public class MyService {
       public void doSomething() { ... }
   }
✅ // copy the real method from the actual source file
```

**Marketing language**:
```text
❌ "This modern, innovative architecture enables maximum flexibility..."
✅ "The architecture uses Permission Set Groups for modular permission management."
```

## File Format

UTF-8 encoding, LF line endings, `.md` extension. Record a version number and last-updated date in `00-index.md` and bump both on every substantive update.
