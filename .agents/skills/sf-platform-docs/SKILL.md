---
name: sf-platform-docs
description: "Official Salesforce documentation retrieval skill. Use when you need authoritative Salesforce docs from developer.salesforce.com, help.salesforce.com, architect.salesforce.com, admin.salesforce.com, or lightningdesignsystem.com, especially when pages are JS-heavy, shell-rendered, or hard to extract with naive fetching. Use to ground answers in official Salesforce sources instead of third-party blogs or summaries. TRIGGER when: user asks for official Salesforce documentation, Apex or API reference, LWC docs, Agentforce docs, setup or help articles, or any doc from a Salesforce-owned domain. DO NOT TRIGGER when: user is asking for a code change, deployment task, or anything not requiring documentation retrieval — use the appropriate sf-* skill instead."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: platform-docs-get
    - Clientell-Ai/salesforce-skills :: sf-docs
---

# sf-platform-docs: Documentation Lookup

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-docs` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: platform-docs-get; Clientell-Ai/salesforce-skills :: sf-docs |

Use this skill to retrieve and ground answers in **official Salesforce documentation on the public web**. For writing or updating this *project's own* technical documentation (a `docs/` tree describing the implemented Apex, LWC, or config), use [DOCUMENTATION.md](../../standards/DOCUMENTATION.md) instead — that file governs project documentation authored about this codebase, not official Salesforce product docs.

This skill provides a **reliable online retrieval playbook** for Salesforce docs that are hard to fetch, especially `help.salesforce.com`, JS-heavy `developer.salesforce.com`, Lightning Design System docs on `lightningdesignsystem.com`, and other official Salesforce-owned doc pages such as `architect.salesforce.com` and `admin.salesforce.com`.

Optional extraction scripts are available in `scripts/` — see the Reference File Index below.

## Scope

| | |
|---|---|
| **In scope** | Official Salesforce doc retrieval: Apex, API, LWC, metadata, Agentforce, setup articles, SLDS, architect/admin guidance |
| **Out of scope** | Third-party blogs, PDF fallback, local corpus indexing, benchmark workflows, generating code or metadata |

## Required Inputs

Before fetching, identify:
- The exact concept, identifier, class, method, or feature name being requested
- The likely doc family (developer docs, help articles, design system, architect/admin)

No additional setup is required to use the retrieval playbook in this skill. The optional extraction scripts require `playwright` — see `requirements.txt`.

## Official Sources Only

Prefer Salesforce-owned documentation sources:
- `developer.salesforce.com`
- `help.salesforce.com`
- `architect.salesforce.com`
- `admin.salesforce.com`
- `lightningdesignsystem.com`
- other official Salesforce documentation pages when Salesforce uses them as the source of truth

Avoid third-party blogs, videos, or summary articles unless the user explicitly asks for them.

Do **not** fall back to PDFs.

## Retrieval Workflow

### 1. Classify the request first

Before fetching anything, identify the likely doc family.

| Family | Typical Source | Use For |
|---|---|---|
| Developer docs | `developer.salesforce.com/docs/...` | Apex, APIs, LWC, metadata, Agentforce developer docs |
| Help docs | `help.salesforce.com/...` | setup, admin, product configuration |
| Architect/Admin docs | `architect.salesforce.com/...`, `admin.salesforce.com/...` | best practices, patterns, well-architected guidance, admin enablement |
| Design system docs | `lightningdesignsystem.com/...` | SLDS, Cosmos, design tokens, component and styling guidance |
| Legacy atlas docs | `developer.salesforce.com/docs/atlas.en-us.*` | older official guide and reference docs |

### 2. Identify the exact concept

Extract the real target before you search:
- exact API/class/method name
- exact feature name
- exact product phrase
- exact setup concept

Examples:
- `Lightning Message Service`
- `Wire Service`
- `System.StubProvider`
- `Agentforce Actions`
- `Messaging for In-App and Web allowed domains`

### 3. Prefer targeted official retrieval

Do **not** broad-crawl Salesforce docs.

Instead:
1. identify the most likely official guide root or article
2. if search is needed, restrict it to official Salesforce domains only
3. fetch that official page
4. check whether the **exact concept actually appears on the page**
5. if not, inspect and follow the most relevant **1–3 official child links**
6. stop once you have grounded evidence

### 4. Do not stop at broad landing pages

A guide landing page is **not enough** unless it clearly contains the exact requested concept.

This is especially important for:
- LWC docs
- Agentforce docs
- broad platform guide homepages
- help landing pages that link to the real article

### 5. For `developer.salesforce.com`

Use this playbook:
- start with the most likely official guide root
- if the page is JS-heavy, prefer browser-rendered extraction
- check whether the exact concept appears on the page
- if the concept is missing, inspect official child links and follow the best matching 1–3 links
- prefer exact concept pages over broad guide roots
- legacy atlas pages are valid if they are the real official reference for the concept

### 6. For `help.salesforce.com`

Help pages often fail with naive fetching.

Use this playbook:
- prefer exact `articleView?id=...` URLs when available
- use browser-rendered extraction when plain fetch returns shell content
- treat outputs like `Loading`, `Sorry to interrupt`, `CSS Error`, or mostly chrome/navigation text as **failed extraction**, not evidence
- look for the **real article body**, not just header, nav, or footer text
- reject shell pages and soft-404 pages such as:
  - "We looked high and low but couldn't find that page"
  - generic empty help shells
- if starting from a nearby guide or hub page, follow linked Help articles until you reach the real article body
- if extraction still fails after targeted retries, return the best official Help URLs you found and explicitly say that article-body extraction was unsuccessful

## Acceptance Rules

A page is good enough to answer from only when at least one of these is true:
- the exact identifier appears on the page
- the exact concept phrase appears on the page
- multiple query-specific phrases appear in the correct official context

A page is **not** good enough when:
- it is only a broad landing page
- it is a shell page with little real article text
- it is from the wrong product area
- it does not contain the requested identifier or concept
- it is a third-party explanation when an official page should exist

## Rejection Rules

Reject these as final evidence:
- broad guide homepages without the exact concept
- release notes when a concept/reference page is expected
- admin blog posts when developer docs are requested
- third-party blogs when official docs are available
- shell-rendered pages with no real article body
- pages whose titles sound right but whose body does not contain the requested concept

## Grounding Requirements

When answering, include:
1. guide/article title
2. exact official URL
3. source type:
   - developer doc page
   - atlas reference page
   - help article page
4. any caveat if extraction was partial or browser-rendered

If evidence is weak, say so plainly.

## Examples

### Example: Lightning Message Service
Do **not** stop at the general LWC guide root.
Find the exact LWC page for Lightning Message Service or follow the most relevant child links from the LWC docs until the exact concept appears.

### Example: Wire Service
Do **not** answer from the LWC homepage unless `Wire Service` is actually present there.
Follow the relevant child doc page for wire service or wire adapters.

### Example: Agentforce Actions
Do **not** answer from a broad Agentforce landing page or a blog post.
Find the official Agentforce developer page for actions, or follow the best matching child pages from the official Agentforce docs.

### Example: Messaging for In-App and Web allowed domains
Prefer official Help articles and browser-rendered extraction.
Reject generic help shells. Follow linked Help articles from nearby official messaging docs if needed.

### Example: System.StubProvider
Prefer the official Salesforce reference/developer page where the exact identifier appears.
Do not substitute a broader Apex landing page if the identifier is absent.

## Non-Goals

This skill should **not**:
- maintain a local documentation corpus
- rely on a local index
- use PDF fallback
- run benchmark workflows
- depend on repo-specific scripts to be useful

## Output Expectations

For each retrieval, include:
1. Guide or article title
2. Exact official URL
3. Source type (developer doc page / atlas reference page / help article page)
4. Any caveat if extraction was partial or browser-rendered

If evidence is weak, say so plainly rather than forcing an answer.

---

## Reference File Index

| File | When to read |
|------|-------------|
| `scripts/extract_salesforce_doc.py` | Use to fetch any official Salesforce doc URL; automatically routes `help.salesforce.com` into the dedicated Help extractor and supports browser-rendered extraction for all Salesforce-owned doc hosts |
| `scripts/extract_help_salesforce.py` | Use directly when targeting `help.salesforce.com` `articleView` URLs; use when the wrapper is not appropriate |
| `scripts/runtime_bootstrap.py` | Imported by the extraction scripts to resolve the isolated platform-docs-get Python runtime and Playwright browser path; not called directly |
| `requirements.txt` | Lists Python dependencies (`playwright`, `playwright-stealth`) needed to run the extraction scripts |

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `sf-docs` (Clientell-Ai/salesforce-skills :: sf-docs)

# Salesforce Documentation Navigator

You are a Salesforce documentation specialist. Help users find the right official documentation quickly and accurately.

## Documentation Index

### Developer Guides

| Guide | Base URL | Use For |
|-------|----------|---------|
| Apex Developer Guide | `developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/` | Apex classes, triggers, async, governor limits, system methods |
| SOQL/SOSL Reference | `developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/` | Query syntax, WHERE clauses, aggregate functions, SOSL search |
| LWC Developer Guide | `developer.salesforce.com/docs/platform/lwc/guide/` | Lightning Web Components, wire adapters, lifecycle hooks, events |
| Metadata API Reference | `developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/` | Metadata types, deployments, package.xml, retrieve operations |
| REST API Developer Guide | `developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/` | REST endpoints, composite API, sObject resources, query via REST |
| SOAP API Developer Guide | `developer.salesforce.com/docs/atlas.en-us.api.meta/api/` | SOAP calls, describe, login, partner vs enterprise WSDL |
| Bulk API 2.0 Guide | `developer.salesforce.com/docs/atlas.en-us.api_asynch.meta/api_asynch/` | Bulk ingest, bulk query, job management, CSV format |
| Tooling API Reference | `developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/` | ApexClass, MetadataContainer, debug logs, code coverage |

### Platform Guides

| Guide | Base URL | Use For |
|-------|----------|---------|
| Flow Builder Guide | `help.salesforce.com/s/articleView?id=sf.flow.htm` | Record-triggered flows, screen flows, autolaunched flows, subflows |
| Platform Events Guide | `developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/` | Event-driven architecture, publish/subscribe, CometD, Pub/Sub API |
| Agentforce Developer Guide | `developer.salesforce.com/docs/einstein/genai/guide/` | Agent actions, prompt templates, models API, AI integration |
| Einstein AI / Models API | `developer.salesforce.com/docs/einstein/genai/guide/models-api.html` | LLM invocation, Models API, prompt management, AI trust layer |

### Security & Testing

| Guide | Base URL | Use For |
|-------|----------|---------|
| Security Guide | `developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_security_sharing_chapter.htm` | CRUD/FLS, `with sharing`, `stripInaccessible`, field-level security |
| Apex Testing Guide | `developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing.htm` | Test classes, `@isTest`, `Test.startTest()`, mocking, test data |
| Security Review Guide | `developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/security_review.htm` | ISV security review, AppExchange requirements, scanner |

### Deployment & CLI

| Guide | Base URL | Use For |
|-------|----------|---------|
| Salesforce CLI Reference | `developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/` | `sf` commands, project deploy, retrieve, test, data |
| Salesforce DX Guide | `developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/` | Scratch orgs, source tracking, project structure, devhub |

### Admin & Help

| Guide | Base URL | Use For |
|-------|----------|---------|
| Salesforce Help | `help.salesforce.com/` | Setup, configuration, admin how-tos, feature docs |
| Architect Guidance | `architect.salesforce.com/` | Well-architected patterns, decision guides, reference architectures |
| Lightning Design System | `lightningdesignsystem.com/` | SLDS components, design tokens, styling, Cosmos design system |

## CLI Help Commands

When users need command-specific help, guide them to built-in CLI docs:

```bash
# List all available commands
sf commands

# Search for a specific command
sf search <keyword>

# Get detailed help for any command
sf project deploy start --help
sf apex run test --help
sf data query --help
sf org login web --help

# Show CLI version and plugins
sf version
sf plugins
```

Key `sf` command families:
- `sf project deploy` / `sf project retrieve` — metadata deployment
- `sf apex run test` — run Apex tests
- `sf data query` / `sf data export` — SOQL queries and data ops
- `sf org login` / `sf org display` — org authentication
- `sf lightning generate component` — scaffold LWC components

## Trailhead Resources

Point users to Trailhead for guided learning:

| Domain | Trail / Module | URL |
|--------|---------------|-----|
| Apex | Apex Basics & Database | `trailhead.salesforce.com/content/learn/modules/apex_database` |
| Apex | Apex Triggers | `trailhead.salesforce.com/content/learn/modules/apex_triggers` |
| LWC | Lightning Web Components Basics | `trailhead.salesforce.com/content/learn/modules/lightning-web-components-basics` |
| LWC | Build LWC for Salesforce | `trailhead.salesforce.com/content/learn/trails/build-lightning-web-components` |
| Flow | Build Flows with Flow Builder | `trailhead.salesforce.com/content/learn/trails/build-flows-with-flow-builder` |
| Flow | Record-Triggered Flows | `trailhead.salesforce.com/content/learn/modules/record-triggered-flows` |
| Admin | Admin Beginner Trail | `trailhead.salesforce.com/content/learn/trails/force_com_admin_beginner` |
| Security | Data Security | `trailhead.salesforce.com/content/learn/modules/data_security` |
| Security | AppExchange Security | `trailhead.salesforce.com/content/learn/modules/isv_security_review` |
| Agentforce | Agentforce Basics | `trailhead.salesforce.com/content/learn/modules/agentforce-basics` |
| Integration | API Basics | `trailhead.salesforce.com/content/learn/modules/api_basics` |

## Release Notes

### Finding Current Release Notes
- **Latest Release Notes**: `help.salesforce.com/s/articleView?id=release-notes` — always check here first
- **Release-specific**: `help.salesforce.com/s/articleView?id=sf.rn_<season><year>.htm` (e.g., `rn_spring25`)

### Seasonal Release Cadence
| Season | Sandbox Preview | Production GA | Typical Months |
|--------|----------------|---------------|----------------|
| Spring | January | February | Feb–May |
| Summer | May | June | Jun–Sep |
| Winter | September | October | Oct–Jan |

### API Version Mapping (Recent)
| API Version | Release |
|-------------|---------|
| 62.0 | Winter '25 |
| 61.0 | Summer '24 |
| 60.0 | Spring '24 |
| 59.0 | Winter '24 |

When users ask about new features, check the release notes for their API version.

## Common Search Patterns

When users ask "how do I...", map to the right documentation:

| User Says | Point Them To |
|-----------|---------------|
| Governor limits / "too many SOQL" | Apex Developer Guide: Execution Governors and Limits |
| Wire adapters / `@wire` | LWC Dev Guide: Wire Service, `Use the Wire Service to Get Data` |
| Deploy errors / "deploy failed" | CLI Reference: `sf project deploy start`, Metadata API: Deploy |
| CRUD/FLS / field-level security | Security Guide: Enforcing CRUD and FLS, `stripInaccessible()` |
| Bulk data load | Bulk API 2.0 Guide: Ingest Jobs |
| Test coverage / "75% coverage" | Apex Testing Guide: Testing Best Practices |
| Trigger order of execution | Apex Developer Guide: Triggers and Order of Execution |
| LWC events / parent-child comms | LWC Dev Guide: Events, `Communicate with Events` |
| REST callouts / `HttpRequest` | Apex Developer Guide: Apex Integration, Named Credentials |
| Flow vs code / "when to use Flow" | Architect Guidance: Automation decision guide |
| Sharing rules / record access | Security Guide: Sharing Architecture |
| Package development / ISV | Packaging Guide: Second-Generation Managed Packages (2GP) |
| Custom metadata types | Apex Developer Guide: Custom Metadata Types |
| Platform events / CDC | Platform Events Guide: Defining and Publishing |
| Agentforce / AI agents | Agentforce Developer Guide: Building Agent Actions |
| Einstein models / LLM | Einstein AI: Models API Reference |
| Scratch org setup | DX Developer Guide: Scratch Org Definition |

## Gotchas

1. **Docs can lag behind releases** — New features may ship before docs are fully updated. Check release notes for the latest info on brand-new features.

2. **API version matters** — Documentation is version-specific. Apex docs for API 62.0 may describe features unavailable in API 58.0. Always confirm the user's target API version.

3. **Trailhead vs Developer Docs** — Trailhead is tutorial-oriented (great for learning). Developer Docs are reference-oriented (great for implementation). Point beginners to Trailhead; point builders to Developer Docs.

4. **Pilot/Beta features** — Some documented features are marked Pilot or Beta. These may change or be removed. Look for the "Pilot" or "Beta" badge in docs before recommending.

5. **`help.salesforce.com` is JS-heavy** — These pages are often hard to extract programmatically. If content looks like a shell page (just headers/nav), the real content failed to load.

6. **Legacy atlas URLs still work** — Many official guides use the older `atlas.en-us.*` URL pattern. These are still valid and often the canonical reference.

7. **Multiple docs for the same concept** — Security topics appear in the Apex guide, Help, and Architect guidance. Cross-reference when users need the full picture.

8. **Salesforce renames products** — Einstein AI became Einstein Copilot became Agentforce. Search across old and new names when docs seem missing.

## Workflow

1. **Understand the request** — Identify what the user is looking for: a concept, a specific API, a how-to, or troubleshooting help.

2. **Classify the doc family** — Determine whether this is a developer doc, help article, Trailhead module, or release note (use the Documentation Index above).

3. **Point to the specific section** — Don't just give the guide root. Identify the exact chapter or article within the guide using the Common Search Patterns table.

4. **Provide the URL** — Give the user the most specific official URL you can construct from the Documentation Index.

5. **Suggest CLI help if applicable** — If the question is about a `sf` command, remind them of `sf <command> --help`.

6. **Cross-reference when needed** — Some topics span multiple guides (e.g., security spans Apex guide + Security guide + Help). Provide multiple links when relevant.

7. **Recommend Trailhead for learning** — If the user seems to be learning (not just looking up a reference), suggest the relevant Trailhead trail alongside the docs.

8. **Flag version sensitivity** — If the answer depends on API version, ask which version the user is targeting.
