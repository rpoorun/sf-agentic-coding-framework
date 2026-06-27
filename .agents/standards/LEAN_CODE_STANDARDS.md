# Lean Code Standards

## Purpose And Use

This file defines the lean-coding, DRY, and token-efficient decision discipline that applies before and during any Apex, LWC, or other Salesforce code generation. Read it before writing new code, refactoring existing code, or reviewing a diff for unnecessary scope. Put cross-cutting "write the least correct code" rules here; put Apex-specific or LWC-specific implementation rules in [SALESFORCE_APEX_STANDARDS.md](SALESFORCE_APEX_STANDARDS.md) and the `sf-platform-apex` / `sf-platform-lwc` skills instead.

This standard is synthesized from two general-purpose (non-Salesforce-specific) open-source agent instruction repositories and refactored for Salesforce development. Do not consult those repositories directly for Apex or LWC guidance; their general web-dev guidance must always be translated into this Salesforce-specific form before use, per [AGENTIC_FRAMEWORK.md](../directives/AGENTIC_FRAMEWORK.md#installing-this-framework-into-a-new-repository):

- [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) — the "lazy senior developer" decision ladder (YAGNI-first, reuse-first, minimum-code-last).
- [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — token-efficient communication and surgical, scope-bounded editing discipline.

## The Lean Decision Ladder (Apex/LWC Refactor Of Ponytail)

Before writing any Apex class, trigger, LWC component, or Flow-supporting code, stop at the first rung that holds. Climb only after you understand the requirement and have traced the existing code/metadata it touches — the ladder runs after comprehension, never instead of it.

1. **Does this need to be built at all?** Check whether a declarative Salesforce feature (Validation Rule, Flow, Formula Field, Approval Process, Duplicate Rule, Assignment/Escalation Rule, Sharing Rule) already satisfies the requirement before writing Apex or a component. Apply YAGNI: do not build for a hypothetical future requirement.
2. **Does it already exist in this codebase?** Reuse the existing Selector, Service, Domain, Utility class, or LWC base/shared component instead of writing a new one. Search before adding.
3. **Does the Apex standard library or a Lightning Base Component already do this?** Prefer `String.isBlank`, `Map`/`Set`/`List` built-ins, `Schema` describe calls, and standard `lightning-*` base components over hand-rolled equivalents.
4. **Does a native platform feature cover it?** Prefer Platform Cache, Custom Metadata, Custom Labels, `WITH USER_MODE`/`Security.stripInaccessible`, and wire adapters (`@wire`) over custom plumbing for the same concern.
5. **Does an already-installed dependency or existing shared LWC/Apex module solve it?** Use the project's existing logging utility, test data factory, or shared LWC utility module rather than writing a parallel one.
6. **Can this be one method, one line, or one existing component property?** Prefer the smallest correct unit.
7. **Only then: write the minimum new Apex/LWC code that satisfies the requirement.**

Bug fixes follow the same root-cause discipline: a ticket names a symptom, not necessarily the cause. Before patching, search for every caller of the function, trigger context, or wire/handler being touched. Fix the shared method or component once rather than patching only the path the ticket names and leaving a sibling caller broken.

## Lean Rules

- No abstractions (new interfaces, base classes, wrapper layers, generic frameworks) that were not explicitly requested or already required by the existing layering pattern (Service/Selector/Domain, or the project's established LWC component structure).
- No new dependency, library, or static resource if an existing one or a platform feature can be used instead.
- No boilerplate nobody asked for: no speculative `@AuraEnabled` methods, no unused `@api` properties, no scaffolding for object types the ticket does not mention.
- Prefer deletion over addition when removing dead code, unused fields, or unused imports is in scope.
- Shortest correct diff wins — but only once the problem is understood. A small diff in the wrong layer (e.g. business logic inlined in a trigger to avoid creating a handler class) is a second bug, not a lean solution; it still violates [SALESFORCE_APEX_STANDARDS.md](SALESFORCE_APEX_STANDARDS.md) layering rules.
- Question requests that imply more code than needed: if a user asks for a new Apex utility class for something a single SOQL bind variable or one Selector method already covers, say so before building it.
- Where two equally-sized approaches exist, pick the bulkification-safe and CRUD/FLS-safe one. Lean means less code, not a weaker safety posture — see "Not Lazy About" below.
- Mark an intentional simplification with a one-line comment naming its ceiling and the upgrade path (e.g. `// lean: single-batch only, no chaining; revisit if volume exceeds one batch window`) instead of silently under-building.

## Not Lazy About (Never Skip These For Leanness)

- Understanding the requirement and tracing the real Apex/Flow/LWC execution path before picking a rung on the ladder.
- Input validation and CRUD/FLS enforcement at trust boundaries (`@AuraEnabled`, `@RestResource`, Flow-invocable inputs).
- Error handling that prevents data loss (DML partial-failure handling, `try/catch` around callouts and JSON parsing).
- Security: sharing keywords, allowlisted dynamic SOQL, no hardcoded secrets.
- Accessibility in LWC (labels, keyboard behavior, focus states, aria attributes, loading/empty/error states).
- Anything the user explicitly requested, even if it looks like avoidable scope.
- Bulkification: lean code must still work correctly for one record and for 200+ records. Never use the ladder to justify a non-bulkified shortcut.

Non-trivial logic should leave one runnable check behind proportional to its risk: a test method for new Apex (see `sf-platform-test`), or a Jest test for new LWC logic. Trivial one-line getters/setters or pure pass-through bindings do not need a dedicated test.

## Token-Efficient Collaboration (Refactor Of Caveman)

These rules govern how an agent communicates about Salesforce work, not the generated Apex/LWC code itself — code and commit messages are always written in full, normal form regardless of communication mode:

- Default to concise, signal-dense status updates and review comments: state location, problem, and fix; drop throat-clearing ("I noticed that...", "You might want to consider...") and restating what a line already shows.
- Code review comment format: `<file>:L<line>: <problem>. <fix>.` with an optional severity tag (bug/risk/nit/question) when a diff mixes severities.
- Never compress or abbreviate actual code, commit messages, PR descriptions, security warnings, irreversible-action confirmations, or exact error strings — terseness applies to prose narration only, never to the artifacts themselves or to safety-critical communication.
- Keep edits surgical and scope-bounded: prefer the smallest correct diff across the fewest files, and call out explicitly when a request's true scope exceeds what was asked (e.g. "this touches 4 files; confirm before I proceed" rather than silently expanding scope or silently refusing).
- Do not narrate routine tool calls; report outcomes, not process, except where this framework's other directives (manual confirmation gates, risk reporting) require explicit narration.
