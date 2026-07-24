---
name: agentic-diagram
description: "Reusable diagramming workflow. Use to turn an English description, architecture trace, process, state machine, data flow, or source-grounded facts into Mermaid diagrams or diagram-ready documentation."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: diagram
---

# agentic-diagram: Diagramming

| Field | Value |
| --- | --- |
| Skill ID | `agentic-diagram` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: diagram |

Use this skill for clear diagrams grounded in source or accepted requirements.

## Diagram Selection

- Flowchart: process, workflow, branching, deployment, or QA path.
- Sequence diagram: request/response, integration, async work, or UI-to-server interaction.
- State diagram: lifecycle, statuses, approvals, or retries.
- Class diagram: class/interface dependencies.
- ERD: data model and relationships.
- C4-style component diagram: system boundaries and ownership.

## Workflow

1. Identify the diagram question.
2. Read source or accepted plan before diagramming implemented behavior.
3. Pick the simplest diagram type.
4. Label nodes with concrete names, not vague roles.
5. Include failure paths when they are part of the workflow.
6. Keep diagrams small enough to render and review; split large diagrams by domain.

For Salesforce metadata diagrams, use `sf-tooling-diagram` as the authoritative skill.
