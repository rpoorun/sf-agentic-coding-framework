# Trust, Data, and Security Rules

## Purpose And Use

This file defines mandatory trust, data, and security rules for repository and Salesforce org work. Read it before handling records, logs, secrets, integration payloads, Apex security, callouts, test fixtures, screenshots, or handoff examples. Put sensitive-data rules, sanitization patterns, security constraints, endpoint rules, logging rules, and data-mutation safety here.

This repository may contain business logic, integration metadata, customer-facing storefront code, and Salesforce configuration. Agents must treat both source and org data as sensitive.

## Trust Boundary

Never trust input from:

- URL parameters.
- LWC public properties.
- Browser storage.
- Apex method parameters exposed through `@AuraEnabled`, `@InvocableMethod`, REST, SOAP, or Flow.
- External integrations.
- CSV imports and manual admin inputs.
- Custom metadata or custom settings that can be changed by admins.

Validate and constrain inputs before use.

## Data Handling

Agents must not print, copy, commit, or expose:

- Access tokens.
- Refresh tokens.
- Session IDs.
- Private keys.
- Certificates.
- Passwords.
- Named credential secrets.
- Connected app secrets.
- Customer personal data.
- Production records.
- Full payloads from integrations unless explicitly sanitized.

## Data Sanitization And Masking

Sanitize data before including it in chat, tickets, commits, logs, screenshots, generated docs, examples, test fixtures, prompts, or handoff notes.

Mask or replace:

- Personally identifiable information (PII).
- Names of private individuals.
- Email addresses.
- Phone numbers.
- Physical addresses.
- Government identifiers.
- Bank, payment, tax, payroll, salary, contract, or pricing details when not required for the task.
- Customer account numbers and external IDs.
- Salesforce record IDs when the full ID is not required.
- Integration payloads, headers, cookies, session data, and tokens.
- Any production or client data that is not strictly needed to prove the point.

Preferred masking patterns:

```text
Account: 001************
Contact: Jane D.
Email: j***@example.invalid
Phone: +230 ******34
External ID: EXT-****-9127
Address: [REDACTED_ADDRESS]
Token: [REDACTED]
```

Use synthetic examples whenever possible. If exact values are required for debugging, keep them local to the secure system and summarize the finding with masked values.

## Apex Security Requirements

For Apex touching records or fields:

- Use explicit sharing: `with sharing`, `without sharing`, or `inherited sharing`.
- Prefer `inherited sharing` for service classes called from user-context entry points unless a deliberate system-context operation is documented.
- Enforce CRUD and FLS for user-facing reads and writes.
- Use `Security.stripInaccessible` for returned or mutated SObjects when appropriate.
- Use `WITH SECURITY_ENFORCED` for simple read queries where it fits the use case.
- Avoid dynamic SOQL. If dynamic SOQL is required, bind variables and validate allowlisted field/object names.
- Never concatenate untrusted input into SOQL, SOSL, DML-like strings, URLs, redirects, HTML, or JavaScript.

## Integration and Endpoint Rules

- Use Named Credentials for callouts.
- Do not hardcode endpoints, usernames, passwords, tokens, or API keys.
- Use HTTPS endpoints only.
- Do not bypass certificate validation.
- Log correlation IDs and safe status details, not secrets or full payloads.

## Logging Rules

Logs must be useful without leaking data.

Allowed:

- Operation names.
- Record counts.
- Safe identifiers when partially redacted.
- Error categories.
- Correlation IDs.

Avoid:

- Full request or response bodies.
- Authorization headers.
- Cookies.
- Raw customer data.
- Stack traces in user-facing messages.

## Data Mutation Rules

Before data mutation code or scripts:

- Confirm target org.
- Confirm object and record scope.
- Confirm rollback or recovery strategy.
- Confirm whether this is sandbox, UAT, production, or another environment.
- Require manual approval before execution.
