---
name: agentic-skill-eval
description: "Reusable skill and model evaluation workflow. Use for benchmarking skill quality, comparing model outputs, evaluating with/without skill context, checking router behavior, or validating a new framework skill."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: benchmark-models
    - garrytan/gstack :: codex
---

# agentic-skill-eval: Skill Evaluation

| Field | Value |
| --- | --- |
| Skill ID | `agentic-skill-eval` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: benchmark-models; garrytan/gstack :: codex |

Use this skill for framework meta work, not normal delivery tasks.

## Evaluation Modes

- **Router sanity**: does the right skill trigger for realistic prompts?
- **With/without skill**: does skill context improve the output?
- **Cross-model comparison**: compare independent outputs using the same task and rubric.
- **Forward test**: ask a fresh agent to use a skill on a realistic task.
- **Regression check**: ensure a skill change did not weaken an existing workflow.

## Method

1. Define the task, expected success criteria, and rubric before running comparisons.
2. Use the same prompt and raw artifacts for every candidate.
3. Avoid leaking the desired answer into evaluation prompts.
4. Judge outputs against concrete criteria, not preference alone.
5. Record latency, cost, or token usage only when measured.
6. Keep evaluation artifacts free of secrets and project-private facts unless they stay local.

## Output

Produce:

- Task and rubric.
- Candidates compared.
- Scores or findings.
- Best output and why.
- Weaknesses to address.
- Recommended skill/router change.
