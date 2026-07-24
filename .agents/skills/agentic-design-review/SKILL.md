---
name: agentic-design-review
description: "Reusable UI and product design review workflow. Use for visual quality, interaction design, information hierarchy, accessibility, responsive behavior, design-system fit, or generating and evaluating design alternatives."
metadata:
  version: "1.0"
  family: "Agentic"
  synthesized: true
  sources:
    - garrytan/gstack :: design-consultation
    - garrytan/gstack :: design-review
    - garrytan/gstack :: design-shotgun
    - garrytan/gstack :: design-html
---

# agentic-design-review: Design Review

| Field | Value |
| --- | --- |
| Skill ID | `agentic-design-review` |
| Family | Agentic |
| Version | 1.0 |
| Synthesized | Yes - adapted from the source(s) below |
| Sources | garrytan/gstack :: design-consultation; garrytan/gstack :: design-review; garrytan/gstack :: design-shotgun; garrytan/gstack :: design-html |

Use this skill to make UI work intentional, usable, and consistent with its product context.

## Review Dimensions

Evaluate:

- Information hierarchy and task flow.
- Layout density, spacing, alignment, and scanability.
- Component choice and design-system fit.
- Responsive behavior and text fit.
- Loading, empty, error, disabled, and permission states.
- Accessibility: labels, focus order, keyboard behavior, contrast, and ARIA.
- Trust: clear outcomes, safe destructive actions, and transparent errors.
- Polish: no placeholder copy, generic filler, or visual drift from the existing system.

## Alternative Exploration

When the direction is not settled, propose two or three distinct directions:

- Conservative: closest to current system.
- Focused improvement: better hierarchy or workflow without major rebuild.
- Ambitious: higher-value interaction, clearly marked as optional.

Ask the user to choose before implementation when alternatives materially affect scope.

## Salesforce Adaptation

For Salesforce UI, combine this skill with `sf-platform-lwc`, `sf-design-slds-apply`, and `sf-design-slds-validate`. Prefer Lightning base components, SLDS blueprints, styling hooks, and accessibility-preserving patterns.
