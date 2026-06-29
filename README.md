# sf-agentic-coding-framework

A drop-in set of AI-agent operating instructions for Salesforce projects. Clone or copy this repo's `AGENTS.md` and `.agents/` folder into a Salesforce project, and any AI coding agent (Claude Code, Cursor, Codex, etc.) that reads `AGENTS.md` will follow a consistent set of guardrails, coding standards, and Salesforce-specific workflows when it touches Apex, LWC, Flow, metadata, or org state.

| Field | Value |
| --- | --- |
| Version | 0.0.5 |
| Author | Rishikesh Poorun |
| License | [Apache License 2.0](LICENSE) |
| Master repository | https://github.com/rpoorun/sf-agentic-coding-framework |

## Why this exists

AI agents are good at writing Salesforce code, but left alone they'll happily invent Apex patterns, skip bulkification, deploy over someone else's unreleased work, or pad your token bill with chatty status updates. This repo packages a Salesforce-specific operating manual for agents so every install behaves the same way: same naming conventions, same safety gates, same coding standards — regardless of which AI tool or model is doing the work.

## How it works

1. **`AGENTS.md`** is the entry point. It's the first file any agent reads, and it routes to everything else: mandatory directives, coding standards, capability "skills," repeatable workflows, and project-specific facts.
2. **`.agents/`** holds the actual instruction files, organized by what kind of rule they are:

```
.agents/
├── directives/   # Non-negotiable rules: safety gates, confirmation requirements, framework governance
├── standards/    # Quality bar: Apex/LWC conventions, lean coding, ApexDoc, trigger/constants frameworks
├── skills/       # Capability routing: 26 sf-{cloud}-{name} skills covering Apex, LWC, Flow, SOQL, deploy, etc.
├── workflows/    # Repeatable processes: bootstrap interview, deployment gates, Git/PR flow, testing
└── project/      # This project's own facts: org aliases, architecture, schema — boilerplate until you fill it in
```

3. **First time you open a project with this framework installed**, the agent runs a short bootstrap interview (one question at a time) to learn your dev org, your Git remote, your team's release process, and whether the framework itself should be committed to your repo or kept local-only — see [`.agents/workflows/PROJECT_BOOTSTRAP.md`](.agents/workflows/PROJECT_BOOTSTRAP.md).
4. **From then on**, every Apex/LWC/metadata task, every deploy, and every Git action runs through the matching directive, standard, skill, or workflow file automatically — you don't have to remind the agent of the rules each time.

## What you get, concretely

- **Safety gates** — the agent won't deploy, commit, push, mutate data, or change org config without your explicit go-ahead. See [`MANUAL_CONFIRMATION_GATES.md`](.agents/directives/MANUAL_CONFIRMATION_GATES.md).
- **Deploy-time protection** — before any deploy (dry-run included), the agent checks whether the target org has moved ahead of local source, merges org-only changes in rather than overriding them, and hard-fails the deploy if Apex coverage drops below 95%. See [`DEPLOYMENT.md`](.agents/workflows/DEPLOYMENT.md).
- **A mandatory trigger framework** — every Apex trigger extends a single `TriggerHandler` base class (context dispatch, recursion guard, bypass API), based on [kevinohara80/sfdc-trigger-framework](https://github.com/kevinohara80/sfdc-trigger-framework). See [`APEX_TRIGGER_FRAMEWORK.md`](.agents/standards/APEX_TRIGGER_FRAMEWORK.md).
- **A mandatory constants pattern** — no hardcoded picklist values; every object gets a `{SObject}Constants` singleton (`AccountConstants`, `LeadConstants`, …) exposed via `Constants.{OBJECT}`, adapted from [beyond-the-cloud-dev/apex-consts](https://github.com/beyond-the-cloud-dev/apex-consts). See [`APEX_CONSTANTS_FRAMEWORK.md`](.agents/standards/APEX_CONSTANTS_FRAMEWORK.md).
- **Lean-coding discipline** — agents check declarative options and existing code before writing anything new, and keep their own chat narration to one short phrase while working (full detail only when you're asked to decide something). See [`LEAN_CODE_STANDARDS.md`](.agents/standards/LEAN_CODE_STANDARDS.md) and [`AGENT_GUARDRAILS.md`](.agents/directives/AGENT_GUARDRAILS.md).
- **Full ApexDoc on everything** — every class and method gets a header with description, author, last-modified date, group, params/return, and a link to its test class. See [`SALESFORCE_APEX_STANDARDS.md`](.agents/standards/SALESFORCE_APEX_STANDARDS.md).
- **26 synthesized Salesforce skills** — Apex, LWC, Flow, SOQL, metadata deploy/retrieve, permission sets, SLDS, security audit, Agentforce, OmniStudio, and more, each merged from multiple upstream skill libraries into one consistent format. See [`SALESFORCE_SKILLS.md`](.agents/skills/SALESFORCE_SKILLS.md).
- **Documentation standards** for writing accurate, source-verified project docs (never invented code samples or guessed picklist values). See [`DOCUMENTATION.md`](.agents/standards/DOCUMENTATION.md).

## Repository structure

```
sf-agentic-coding-framework/
├── AGENTS.md                # Agent-facing entry point and router (read this first if you're an agent)
├── README.md                # This file — human-facing overview
├── LICENSE                  # Apache License 2.0
└── .agents/
    ├── directives/           # AGENTIC_FRAMEWORK, AGENT_GUARDRAILS, TRUST_DATA_SECURITY, MANUAL_CONFIRMATION_GATES
    ├── standards/             # Apex, lean-coding, trigger, constants, documentation, PMD, project-baseline standards
    ├── skills/                # 26 sf-{cloud}-{name} skill folders + SALESFORCE_SKILLS.md router
    ├── workflows/             # PROJECT_BOOTSTRAP, WORKFLOW, DEPLOYMENT, PULL_REQUEST, TESTING, IMPLEMENTATION_PLAN
    └── project/               # Boilerplate facts to fill in per installation (org aliases, architecture, schema, ...)
```

## Installing this into your own Salesforce project

1. Copy `AGENTS.md` and `.agents/` into your project's repository root.
2. Open the project with your AI coding agent. On first read, it will run the [bootstrap interview](.agents/workflows/PROJECT_BOOTSTRAP.md): your dev org, your Git remote/team setup, and whether to commit this framework to your remote or keep it local-only.
3. From there, just work normally — ask the agent to build the Apex class, LWC component, or Flow you need, and it applies the standards and gates automatically.
4. To pull future updates from this master repository, or to contribute a generally-useful improvement back, see [Master Framework Repository And Sync Workflow](.agents/directives/AGENTIC_FRAMEWORK.md#master-framework-repository-and-sync-workflow).

## Acknowledgements and sources

This framework's skills and standards are built by synthesizing, refactoring, or adapting (with attribution) the open-source work of:

| Source | Used for |
| --- | --- |
| [forcedotcom/sf-skills](https://github.com/forcedotcom/sf-skills) | Primary source for most `sf-platform-*` and other skills |
| [Clientell-Ai/salesforce-skills](https://github.com/Clientell-Ai/salesforce-skills) | Secondary/merged source for the same skills, plus `sf-security-audit` |
| [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | Lean-coding decision ladder doctrine |
| [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Token-efficient communication and surgical-diff doctrine |
| [kevinohara80/sfdc-trigger-framework](https://github.com/kevinohara80/sfdc-trigger-framework) | `TriggerHandler` base class (vendored verbatim, MIT) |
| [beyond-the-cloud-dev/apex-consts](https://github.com/beyond-the-cloud-dev/apex-consts) | `Constants`/`{SObject}Constants` pattern (adapted, MIT) |

Full detail and links: [Acknowledgements And Sources in `AGENTS.md`](AGENTS.md#acknowledgements-and-sources).

## License

[Apache License 2.0](LICENSE).
