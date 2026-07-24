---
name: agentic-devex-review
description: "Reusable developer-experience review workflow. Use for framework onboarding, repository setup, bootstrap flows, local development, docs friction, CI/dev tooling, skill usability, or time-to-first-success analysis."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: plan-devex-review
    - garrytan/gstack :: devex-review
---

# agentic-devex-review: Developer Experience Review

| Field | Value |
| --- | --- |
| Skill ID | `agentic-devex-review` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: plan-devex-review; garrytan/gstack :: devex-review |

Use this skill to evaluate whether another developer or agent can succeed without hidden knowledge.

## Review Modes

- **Plan-stage DX**: review a proposed workflow before it is built.
- **Live DX**: walk the actual setup or contribution path and record friction.
- **Triage**: find the smallest change that removes the biggest blocker.

## Checklist

Evaluate:

- Time to first successful command or useful artifact.
- Required tools and whether they are discoverable.
- Error messages and recovery paths.
- Documentation truthfulness versus real source behavior.
- Cross-platform command coverage, especially PowerShell and Bash.
- Credential and secret handling.
- Whether the workflow leaves durable state in the correct tier.
- Whether a fresh agent can pick the right skill or workflow from router files.

## Output

Report:

- Persona tested.
- Path attempted.
- Friction points.
- Missing or stale docs.
- Recommended fixes, ordered by impact.
- Verification command or manual check.
