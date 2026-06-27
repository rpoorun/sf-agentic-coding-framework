# Requirement and Specification Rules

## Purpose And Use

This file defines how agents validate requirements for this project before feasibility analysis or implementation. Read it before interpreting tickets, PDFs, Jira extracts, client comments, solution tables, or acceptance criteria. Put durable requirement-source rules, validity gates, client-specific overrides, and known requirement-risk patterns here.

This is a boilerplate template. Ticket requirements, client request documents, solution tables, and uploaded requirement extracts must be treated as inputs to validate, not as automatically correct implementation instructions.

## Requirement Validity Gate

Before feasibility analysis or implementation, evaluate whether the requirement itself is valid against the current repo and, when org reads are allowed, the target Salesforce org.

Check at least:

1. The requested base object matches the solution table, field list, layouts, permission sets, and integration flow.
2. The requested field API name, field label, data type, external ID requirement, uniqueness, requiredness, and picklist values match the stated business purpose.
3. The requested metadata members exist locally or in the target org, and their deployable API names are known.
4. The requested change does not conflict with current org metadata, local source state, existing Experience Cloud configuration, or integration contracts.
5. Any ambiguity, mismatch, missing object, missing field, wrong data type, or uncertain environment target is called out before editing.

If the requirement has contradictions, pause the implementation path and report the mismatch clearly. Do not silently choose one interpretation when the client wording and org reality disagree.

## Illustrative Requirement-Risk Pattern

Historically, ticket requirements or solution tables can be ambiguous or incorrectly defined. Assume a requirement may need correction until proven otherwise. The example below illustrates the kind of mismatch to watch for; replace it with this project's own verified pattern once one is observed (cite the ticket ID only in the local install, not in content proposed back to the master framework repository):

- The implementation base object was identified as one SObject (e.g. `PricebookEntry`).
- The solution table pointed to a different SObject instead (e.g. `Account`).
- The requested field was described as storing an external ID.
- The supplied field definition treated the value as a Boolean.

That combination is not a straightforward build request. It requires a validity check and clarification before feasibility can be considered reliable.
