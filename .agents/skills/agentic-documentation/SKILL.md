---
name: agentic-documentation
description: "Reusable documentation workflow. Use to generate or update source-verified docs, Diataxis docs, release documentation, post-ship docs, diagrams-in-docs, markdown-to-PDF handoffs, and stale documentation checks."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: document-release
    - garrytan/gstack :: document-generate
    - garrytan/gstack :: make-pdf
---

# agentic-documentation: Documentation

| Field | Value |
| --- | --- |
| Skill ID | `agentic-documentation` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: document-release; garrytan/gstack :: document-generate; garrytan/gstack :: make-pdf |

Use this skill with `DOCUMENTATION.md`. Source verification remains mandatory.

## Documentation Types

- **Tutorial**: teach a first successful path.
- **How-to**: solve a specific task.
- **Reference**: document exact APIs, metadata, commands, fields, or contracts.
- **Explanation**: describe why the system is shaped this way.
- **Release docs**: update docs to match what changed in a shipped scope.
- **Publishable handoff**: convert approved Markdown to PDF/DOCX only when requested and tooling is available.

## Workflow

1. Identify the audience and document type.
2. Read the actual source, metadata, tests, and existing docs.
3. Remove or flag stale claims.
4. Write only what is implemented or explicitly planned.
5. Link diagrams and source references where helpful.
6. Update indexes, dates, and cross-links when the docs tree uses them.
7. Validate that links and tables render.

## Hard Rules

- Do not invent code examples, picklist values, coverage numbers, object names, or behavior.
- Do not duplicate full reference data in multiple docs.
- Keep release docs scoped to what actually changed.
- Keep private data and secrets out of examples.
