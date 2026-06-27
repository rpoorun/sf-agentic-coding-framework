---
name: sf-dx-analyzer
description: "Run Salesforce Code Analyzer to scan code for security, performance, best practice, and code style violations. Supports all engines (PMD, ESLint, CPD, RetireJS, Flow, SFGE, ApexGuru), targets (files, folders, git diff), categories, and severities. Also handles post-scan exploration: filtering results by engine/severity/category/file, and explaining what specific rules mean. TRIGGER when: user says 'scan my code', 'check for security issues', 'run PMD/ESLint', 'find duplicates', 'analyze Flows', 'check vulnerable libraries', 'AppExchange review', 'lint my LWC', 'static analysis', 'code quality', 'show only security violations', 'what is this rule', 'explain ApexCRUDViolation', 'filter results', or mentions engines/file types (.cls, .trigger, .js, .flow-meta.xml). Use this skill for scanning, exploring results, understanding rules, and listing available rules. DO NOT TRIGGER when: user wants to fix code without scanning, or asks ONLY about installation/configuration."
metadata:
  version: "1.0"
  cloud: "DX"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: dx-code-analyzer-run
    - forcedotcom/sf-skills :: dx-code-analyzer-configure
---

# sf-dx-analyzer: Code Analyzer

| Field | Value |
| --- | --- |
| Skill ID | `sf-dx-analyzer` |
| Cloud | DX |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: dx-code-analyzer-run; forcedotcom/sf-skills :: dx-code-analyzer-configure |

## ⚠️ CRITICAL: Mandatory Script Usage

Every interaction with Code Analyzer results MUST go through the bundled scripts in `<skill_dir>/scripts/`. No exceptions.

### ❌ WRONG — never do this:

```bash
# WRONG: inline Python to parse results
python3 -c "import json; data = json.load(open('results.json'))..."

# WRONG: inline Node.js to parse results
node -e "const data = require('./results.json')..."

# WRONG: jq to filter results
cat results.json | jq '.violations[] | select(.engine=="pmd")'

# WRONG: reading the results file directly (it can be 10MB+)
Read tool → code-analyzer-results-*.json
```

Also forbidden: `run_code_analyzer` and any `mcp__*` tool — Bash only.

### ✅ RIGHT — always do this:

```bash
# Summarize scan results
node "<skill_dir>/scripts/parse-results.js" "./code-analyzer-results-TIMESTAMP.json"

# Filter/rank/query results (by engine, severity, file, rule, category)
node "<skill_dir>/scripts/query-results.js" "./code-analyzer-results-TIMESTAMP.json" --engine pmd --summary

# List/browse available rules (by engine, category, language, severity)
node "<skill_dir>/scripts/list-rules.js" "Security" --top 10

# Look up what a rule means
node "<skill_dir>/scripts/describe-rule.js" "ApexCRUDViolation" --engine pmd

# Discover fixable violations
node "<skill_dir>/scripts/discover-fixes.js" "./code-analyzer-results-TIMESTAMP.json"

# Apply fixes (after user confirms)
node "<skill_dir>/scripts/apply-fixes.js" "./code-analyzer-results-TIMESTAMP.json"

# Summarize applied fixes
node "<skill_dir>/scripts/summarize-fixes.js" "./code-analyzer-results-TIMESTAMP.json"

# Filter vendor files (jQuery, Bootstrap, *.min.js) before applying fixes
node "<skill_dir>/scripts/filter-violations.js" "./code-analyzer-results-TIMESTAMP.json" "./code-analyzer-results-TIMESTAMP-filtered.json" --report
```

`<skill_dir>` is the absolute path to the directory containing this SKILL.md. **Never** use `./scripts/` — that resolves against the user's CWD, not the skill dir.

Any aggregation, filter, or rank question ("which file has the most violations?", "how many PMD issues?", "top rules by count", "break down by severity") is answered by `query-results.js` — its output already includes `topRules`, `topFiles`, and `severityCounts`.

---

## Overview

This skill translates natural-language requests ("scan for security issues", "check my changes") into the correct `sf code-analyzer run` command, executes scans across any combination of engines/targets/severities, and presents actionable results. When engine-provided fixes are available, it discovers them, asks for user confirmation, applies them safely, and offers verification. Use it for static analysis, security reviews, AppExchange certification, code-quality checks, and finding duplicates/vulnerabilities in Salesforce projects.

**In scope:** running scans, parsing/filtering/ranking results, applying engine auto-fixes, diff-based scans, all output formats (JSON/HTML/SARIF/CSV/XML), describing/listing rules, scan-failure troubleshooting.

**Out of scope:** installing/configuring `sf` or the plugin (→ `dx-code-analyzer-configure`), writing custom rules/engines, AI-generated fixes beyond engine-provided ones, deep refactoring, CI/CD setup (→ `dx-code-analyzer-configure`).

**Allowed tools:** Bash (`sf code-analyzer`, `node`, `git diff`, `date`), Read, Write, Edit. **Forbidden:** any MCP tool, Agent tool, web tools, other skills, Python, `jq`, inline scripts/heredocs. This skill owns the complete scan-fix-verify-query-explain workflow end-to-end.

---

## Command Syntax Rules (READ FIRST — ABSOLUTE)

1. The command is **`sf code-analyzer run`** — NOT `sf scanner run` (deprecated v3).
2. **No `--format` flag.** Use `--output-file <path>.<ext>`; the extension determines the format.
3. **Always** pass `--output-file` with a timestamped name (e.g., `./code-analyzer-results-20260512-143022.json`) — do not rely on stdout.
4. **Foreground only** (no `run_in_background`); timeout 1200000ms for large scans.
5. **Invalid v3 flags** that cause errors: `--format`, `--engine`, `--category`, `--json`. Use `--rule-selector` + `--output-file` instead.
6. **Tool restriction:** Bash, Read, Write, Edit only. No MCP tools, no Agent tool, no web tools, no other skills.

Why: the v4+ CLI redesigned the flag interface; v3 flags now error.

Full flag/selector docs: `<skill_dir>/references/flag-reference.md`.

---

## Prerequisites

User needs: **Salesforce CLI** (`sf`), **@salesforce/plugin-code-analyzer** (v5.x+), **Java 11+** (PMD/CPD/SFGE), **Node.js 18+** (ESLint/RetireJS), **Python 3** (Flow), **authenticated org** (ApexGuru).

Pre-flight: run `sf code-analyzer --help 2>&1 | head -1`. If that fails, or if a scan reports an engine startup error (e.g., "PMD failed to start", "java: command not found", "SFGE failed"):

1. **Stop** — do not attempt to install/diagnose prerequisites yourself.
2. **Delegate to `dx-code-analyzer-configure`** — it handles all setup.
3. After it finishes, return here and re-run the scan.

If a scan fails for other reasons, see `<skill_dir>/references/error-handling.md`.

---

## Quick Start: Common Patterns

Match the request below; if it matches, jump to Step 3 (Build Command). Otherwise, walk Step 1.

| User Says | Rule Selector | Notes |
|-----------|---------------|-------|
| "scan my code" / "run code analyzer" | `Recommended` | Curated set, all file types |
| "check for security issues" / "security review" | `all:Security:(1,2)` | All engines, Critical+High |
| "scan my changes" / "check the diff" | (see Step 1.5) | Get files via `git diff`, filter to scannable types, pass via `--target` |
| "run PMD" / "check my Apex" | `pmd` | Apex classes and triggers |
| "lint my LWC" / "check my JavaScript" | `eslint` | JavaScript/TypeScript/LWC |
| "find duplicates" / "check for copy-paste" | `cpd` | Code clones |
| "check for vulnerabilities" / "scan libraries" | `retire-js` | JavaScript library CVEs |
| "deep analysis" / "data flow analysis" | `sfge` | Java 11+, 10–20 min, use `--workspace "force-app"` |
| "performance analysis" / "governor limits" | `apexguru` | Authenticated org required |
| "analyze my Flows" | `flow` | `--target **/*.flow-meta.xml`, Python 3 |
| "AppExchange security review" | `all:Security:(1,2)` | See `<skill_dir>/references/special-behaviors.md` → AppExchange |

---

## Step 1: Parse the User's Intent

Analyze the request along these 7 dimensions; any can combine.

### 1.1 ENGINE
PMD/Apex → `pmd` · ESLint/JS/TS/lint → `eslint` · Flows → `flow` · duplicates/CPD → `cpd` · vulnerabilities/CVE/RetireJS → `retire-js` · SFGE/data flow → `sfge` · performance/ApexGuru → `apexguru` · regex → `regex` · everything → `all` · unspecified → `Recommended`.

### 1.2 CATEGORY
security/OWASP → `Security` · performance → `Performance` · best practices → `BestPractices` · style/format → `CodeStyle` · design/complexity → `Design` · bugs → `ErrorProne` · docs → `Documentation`.

### 1.3 SEVERITY
1=Critical · 2=High · 3=Moderate · 4=Low · 5=Info. "critical only" → `1` · "critical+high" → `(1,2)` · "moderate and above" → `(1,2,3)`.

### 1.4 SPECIFIC RULE
If the user names a rule (e.g., "ApexCRUDViolation", "no-unused-vars"): `--rule-selector <engine>:<ruleName>`, or just `<ruleName>` if engine is ambiguous.

⚠️ **Partial names:** `--rule-selector` requires the **exact full** rule name (e.g., `@salesforce-ux/slds/no-hardcoded-values-slds2`, not `no-hardcoded-values`). No wildcards. If you are not 100% certain, look it up first — **do not guess**:
```bash
sf code-analyzer rules --rule-selector all 2>&1 | grep -i "USER_KEYWORD"
```
Multiple matches → ask the user which. Zero matches → tell the user nothing matched.

### 1.5 TARGET
specific path → `--target <path>` · glob ("all Apex") → `--target **/*.cls,**/*.trigger` · "my changes"/"diff" → `git diff --name-only [base]...HEAD`, filter to scannable types, pass as `--target` · "LWC" → `--target **/lwc/**` · "Flows" → `--target **/*.flow-meta.xml` · unspecified → omit (entire workspace).

Diff-filtering details: `<skill_dir>/references/special-behaviors.md`.

### 1.6 OUTPUT
**Default JSON.** Only change if the user explicitly asks. Name: `./code-analyzer-results-<YYYYMMDD-HHmmss>.<ext>` via `TIMESTAMP=$(date +%Y%m%d-%H%M%S)`. Formats: `.json` (default), `.html`, `.sarif`, `.csv`, `.xml`.

### 1.7 COMPARISON / DELTA
"new since main" → `git diff --name-only main...HEAD` → scan those · "since last commit" → `HEAD~1` · "vs develop" → `develop...HEAD`.

---

## Step 2: Build the Rule Selector

Syntax: `:` = AND, `,` = OR, `()` = grouping.

- Engine only: `pmd`
- Engine + category: `pmd:Security`
- Engine + severity: `pmd:2`
- Complex: `(pmd,eslint):Security:(1,2)` = (PMD or ESLint) AND Security AND sev (1 or 2)
- Specific rule: `pmd:ApexCRUDViolation`
- All: `all`

More: `<skill_dir>/references/command-examples.md`.

---

## Step 3: Build the Full Command

```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
sf code-analyzer run \
  --rule-selector <selector> \
  --target <targets> \                                              # optional
  --output-file "./code-analyzer-results-${TIMESTAMP}.json" \       # default JSON
  --include-fixes \                                                 # always
  --workspace <path>                                                # optional
```

- Default to timestamped JSON; only change format on explicit request.
- Always pass `--include-fixes` (enables Step 6 auto-fix).
- Omit `--target` to scan the whole workspace.
- Diff scans: `git diff --name-only` → filter scannable types → pass as `--target`.

Special cases (SFGE/ApexGuru/AppExchange/diff): `<skill_dir>/references/special-behaviors.md`.

---

## Step 4: Execute the Scan

Use the **Bash tool only** — never the `run_code_analyzer` MCP tool.

1. Generate the timestamp via Bash: `date +%Y%m%d-%H%M%S` → e.g. `20260512-143022`.
2. Tell the user:
   ```
   Starting scan...
   Results: ./code-analyzer-results-20260512-143022.json
   Log:     ./code-analyzer-results-20260512-143022.log
   May take several minutes for large codebases.
   ```
3. Run with the **literal** timestamp baked in (not `$TIMESTAMP`), foreground, timeout 1200000ms, `tee` to a `.log`:
   ```bash
   sf code-analyzer run --rule-selector Recommended \
     --output-file "./code-analyzer-results-20260512-143022.json" \
     --include-fixes 2>&1 | tee "./code-analyzer-results-20260512-143022.log"
   ```
4. Exit 0 = success. On error, read both the log file and `<skill_dir>/references/error-handling.md`.
5. **Immediately** parse results (Step 5) — do not ask the user what to do next.

---

## Step 5: Parse and Present Results

Run the parse script straight after the scan — do not pause to ask:

```bash
node "<skill_dir>/scripts/parse-results.js" "./code-analyzer-results-TIMESTAMP.json"
```

⚠️ **DO NOT:**
- ❌ Invent or generate script code yourself
- ❌ Use bare relative paths like `node scripts/parse-results.js` (won't resolve from user's CWD)
- ❌ Use heredocs or inline script content
- ❌ Use `jq` as a substitute for the parse script (shell quoting will break)
- ❌ Read the JSON file directly

### Presentation template

```
## Scan Complete

**Found X violations** across Y files.

| Severity | Count |
|----------|-------|
| Critical (1) | X |
| High (2) | X |
| Moderate (3) | X |
| Low (4) | X |
| Info (5) | X |

### Top Issues
| # | Rule | Engine | Sev | File | Line |
|---|------|--------|-----|------|------|
| 1 | ApexCRUDViolation | pmd | 2 | AccountService.cls | 42 |
| ... up to 10 most critical |

### Top Rules by Frequency
| Rule | Engine | Count |
|------|--------|-------|
| no-var | eslint | 170 |
| ... |

Full results: `./code-analyzer-results-20260512-143022.json`
```

Scale to result size: **0** → "no violations found"; **1–10** → all in one table; **11–50** → severity counts + top 10; **50–5000** → counts + top 10 violations + top 10 rules + top 5 files; **5000+** → same, plus suggest narrowing scope (severity/category/folder). Always end with the output path and offer next actions: filter / explain rule / apply fixes.

Large-result handling: `<skill_dir>/references/special-behaviors.md`.

---

## Step 6: Apply Engine-Provided Fixes (Post-Scan)

Engine-provided fixes are **deterministic** (not AI-generated). Flow: vendor filter (if needed) → discover → present → **wait for user confirmation** → apply → summarize.

### 6.1 Vendor file filter (when needed)

Run if the user said "fix my code" / "project source", or if top-violation files are vendor libs (jQuery, Bootstrap, `*.min.js`):

```bash
node "<skill_dir>/scripts/filter-violations.js" \
  "./code-analyzer-results-TIMESTAMP.json" \
  "./code-analyzer-results-TIMESTAMP-filtered.json" \
  --report
```

Report: "Excluded X vendor files (Y violations) — jQuery, Bootstrap, etc. Applying fixes to Z project files only." Use the filtered file in 6.2+. Detection logic: `<skill_dir>/references/vendor-file-handling.md`.

### 6.2 Discover

```bash
node "<skill_dir>/scripts/discover-fixes.js" "./code-analyzer-results-TIMESTAMP.json"
```

### 6.3 Present + ASK (then STOP)

```
### Engine-Provided Fixes Available
**X of Y violations** have auto-fixes provided by the analysis engine:

| Rule | Engine | Sev | Fixable Count |
|------|--------|-----|---------------|
| no-var | eslint | 3 | 170 |
| ... |

These are safe, deterministic fixes generated by the engines (not AI-generated).

Would you like me to apply these fixes? (yes / no / select specific rules)
```

⚠️ **Stop and wait for the user's reply, even if they originally said "scan and fix everything".** Apply only on a fresh "yes" / "apply" / "go ahead" in the next turn.

### 6.4 Apply

```bash
node "<skill_dir>/scripts/apply-fixes.js" "./code-analyzer-results-TIMESTAMP.json"
```
(Filtered file if 6.1 created one.)

### 6.5 Summarize (MANDATORY immediately after 6.4)

```bash
node "<skill_dir>/scripts/summarize-fixes.js" "./code-analyzer-results-TIMESTAMP.json"
```

Then present:

```
### Engine-Provided Fixes Applied Successfully ✓
**Applied X auto-fixes across Y files.**

| Severity | Fixes Applied |
|----------|---------------|
| Critical (1) | X |
| ... |

| Rule | Fixes Applied |
|------|---------------|
| no-var | 169 |
| ... |

Want me to re-run the scan to verify the fixes resolved the violations?
```

### 6.6 — Handling the user's choice
- **Decline / "no":** skip apply, skip summarize. Do not re-scan.
- **"Select rules":** filter the discovery list to those rules and pass the filtered file to `apply-fixes.js`.
- **"All" / "yes":** run `apply-fixes.js` against the full (or vendor-filtered) results file as-is.

### 6.7 — Optional re-scan for verification
If the user accepts the offer in 6.5, re-run the same scan with a **new timestamp** (do not overwrite the original). Compare violation counts before vs. after and show the delta — fixes that resolved cleanly will drop out; remaining violations either need manual remediation or are unrelated.

---

## Step 7: Query and Filter Existing Results

After Step 5, the user may want to **drill into specific subsets** without re-running the entire scan. This step handles all result-exploration requests.

### When to trigger
Activate when the user asks to slice, filter, rank, or explore existing results:
- "Show me just the security violations"
- "What's in AccountService.cls?"
- "Show only PMD issues" / "Filter to critical and high"
- "What ESLint rules fired?" / "Show violations in the lwc folder"
- "Top 20 most severe" / "Which file has the most violations?"
- "What are the most common rules?" / "How many violations per engine?" / "Break it down by severity"

**Important:** Any question about existing scan results — filtering, ranking, counting, aggregating — MUST use `query-results.js`. NEVER write inline Python, `jq`, or ad-hoc scripts to parse the results JSON. The query script already provides `topRules`, `topFiles`, and `severityCounts` in its output.

### How to execute
Run the query script against the **same results file** from Step 4 (no re-scan needed):

```bash
node "<skill_dir>/scripts/query-results.js" "./code-analyzer-results-TIMESTAMP.json" [options]
```

| User says | Options |
|-----------|---------|
| "security violations" | `--category Security` |
| "PMD issues only" | `--engine pmd` |
| "critical and high" / "sev 1-2" | `--severity 1,2` |
| "in AccountService.cls" | `--file AccountService.cls` |
| "the ApexCRUDViolation rule" | `--rule ApexCRUDViolation` |
| "top 20" | `--top 20` |
| "sort by file" | `--sort file` |
| "just give me counts" | `--summary` |
| "which file has the most violations?" | `--sort file --summary` (read `topFiles`) |
| "which file has most PMD violations?" | `--engine pmd --summary` (read `topFiles`) |
| "most common rules?" | `--summary` (read `topRules`) |
| "how many per engine?" | use Step 5's summary, or run with `--engine X --summary` per engine |
| Combinations | `--engine pmd --severity 1,2 --top 5` |

Output format and presentation templates: `<skill_dir>/references/post-scan-workflows.md`.

---

## Step 8: Describe a Rule

When the user asks "what does this rule mean?" or "how do I fix this?", use this step to look up and explain a specific rule.

### When to trigger
- "What is ApexCRUDViolation?"
- "Explain this rule" / "Why is this flagged?"
- "What does no-var mean?"
- "How do I fix OperationWithLimitsInLoop?"
- "Tell me about this violation"

### How to execute

```bash
node "<skill_dir>/scripts/describe-rule.js" "<rule-name>" [--engine <engine>]
```

Pass `--engine` when known (from scan context); omit for a broader search. Returns one of `success` / `multiple_matches` / `not_found`. Status handling and templates: `<skill_dir>/references/post-scan-workflows.md`.

---

## Step 9: List Available Rules

Triggers: "what security rules are available?", "list all PMD rules", "rules for JavaScript", "Recommended rules", "how many ESLint rules?", "rules for Apex".

```bash
node "<skill_dir>/scripts/list-rules.js" "<selector>" [options]
```

| User says | Selector | Options |
|-----------|----------|---------|
| "security rules" | `Security` | |
| "PMD rules" | `pmd` | |
| "ESLint security rules" | `eslint:Security` | |
| "JavaScript rules" | `JavaScript` | |
| "Apex rules" | `Apex` | |
| "Recommended rules" | `Recommended` | |
| "high severity rules" | `(1,2)` | |
| "just give me counts" | `Recommended` | `--count-only` |
| "top 10 security rules" | `Security` | `--top 10` |

Filters: `--engine`, `--severity`, `--top` (default 100), `--count-only`. The script pre-validates selector tokens (catches typos like `secruity`) before calling the CLI. Presentation: `<skill_dir>/references/post-scan-workflows.md`.

---

## Constraints & Gotchas

| Item | Why / Fix |
|------|-----------|
| Use timestamped JSON + `.log` via `tee` | Prevents overwrite; matches log to results |
| `--format` flag | Removed in v4+; use `--output-file <path>.<ext>` |
| Foreground, 1200000ms timeout | SFGE can take 10–20 min; backgrounding loses output |
| Run scripts with absolute `<skill_dir>` path | `./scripts/` resolves against the user's CWD, not the skill dir |
| Never apply fixes without confirmation | User must approve code modifications |
| Vendor file check before fixes | If 50%+ vendor (jQuery/Bootstrap/`*.min.js`), filter first |
| Fix-script order: filter (if needed) → discover → apply → summarize | Skipping summary leaves the user without an outcome report |
| SFGE needs explicit `--workspace` | Otherwise template files cause compilation errors |
| Look up partial rule names first | Guessing returns 0 results; use `sf code-analyzer rules` |
| `ONLY` Bash tool, never MCP | `run_code_analyzer` and other MCP tools bypass the script workflow |
| Never invoke other skills for fixes | This skill owns the full workflow end-to-end |
| Query existing results, don't re-scan | Step 7 filters existing JSON instantly |
| Scan returns 0 results | Invalid rule selector — verify with `sf code-analyzer rules --rule-selector <selector>` |
| `jq` parsing fails | Shell quoting — use `parse-results.js` / `query-results.js` instead |
| Inline scripts written by LLM | Never write scripts — use existing ones in `<skill_dir>/scripts/` |
| Ranking/aggregation answered by ad-hoc Python | Always use `query-results.js`; output already has `topFiles`/`topRules`/`severityCounts` |

---

## Reference File Index

**Scripts** (always execute via `node` with the absolute `<skill_dir>/` prefix, never Read):

| File | When to use |
|------|-------------|
| `<skill_dir>/scripts/parse-results.js` | Step 5 — extract summary from scan JSON |
| `<skill_dir>/scripts/filter-violations.js` | Step 6.1 — exclude vendor files (jQuery, Bootstrap) from fixes |
| `<skill_dir>/scripts/discover-fixes.js` | Step 6.2 — identify fixable violations |
| `<skill_dir>/scripts/apply-fixes.js` | Step 6.4 — apply engine fixes after user confirms |
| `<skill_dir>/scripts/summarize-fixes.js` | Step 6.5 — summarize applied changes |
| `<skill_dir>/scripts/query-results.js` | Step 7 — filter/drill into existing results without re-scanning |
| `<skill_dir>/scripts/describe-rule.js` | Step 8 — look up rule description and documentation |
| `<skill_dir>/scripts/list-rules.js` | Step 9 — list/browse available rules by selector with validation |

**References** (read on demand):

| File | When to read |
|------|--------------|
| `references/quick-start.md` | Command-syntax templates |
| `references/flag-reference.md` | Full flag docs, rule-selector syntax |
| `references/error-handling.md` | Scan-failure diagnosis |
| `references/engine-reference.md` | Engine capabilities, file types, rule tags |
| `references/command-examples.md` | Less-common command scenarios |
| `references/special-behaviors.md` | SFGE/ApexGuru/AppExchange/diff/large scans |
| `references/vendor-file-handling.md` | Vendor-file detection and filtering |
| `references/post-scan-workflows.md` | Steps 7–9 — querying, rule description, rule listing |

`examples/` contains output-structure validation and command patterns (basic/large/security scans, fix workflows).

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `dx-code-analyzer-configure` (forcedotcom/sf-skills :: dx-code-analyzer-configure)

# Configuring Code Analyzer Skill

## Overview

This skill manages the `code-analyzer.yml` configuration file — the single source of truth for how Code Analyzer behaves in a project. All customization (engines, rules, ignores, suppressions) is done by creating or editing this file. If the file doesn't exist, this skill creates it in the current working directory.

---

## Scope

**In scope:**
- Checking prerequisites (sf CLI, Java, Node.js, Python, org auth)
- Installing/updating the Code Analyzer plugin
- Creating `code-analyzer.yml` if it doesn't exist
- Editing `code-analyzer.yml` for all configuration changes
- Engine settings, rule overrides, ignore patterns, suppressions
- CI/CD pipeline setup (GitHub Actions, Jenkins, etc.)
- Environment validation and troubleshooting

**Out of scope:**
- Running scans (use `dx-code-analyzer-run` skill)
- Fixing violations, explaining rules, creating custom rules, suppression management

---

## Tool Usage Rules

**Allowed:** Bash (sf, java, node, python3, git, npm), Read, Write, Edit
**Forbidden:** MCP tools, Agent tool, Web tools, other skills, `which`, `find`, `locate`, searching for binaries

---

## Core Principle: YAML Only When Customizing

Code Analyzer works out of the box with NO config file — all defaults are built into the tool. The `code-analyzer.yml` file is ONLY created when the user explicitly requests a customization.

**Rules:**
- **Do NOT create `code-analyzer.yml` proactively** — only when user asks to change something
- **Do NOT duplicate built-in defaults** — only write entries that intentionally override behavior
- **Always place at project root** — where `sfdx-project.json` or `sf-project.json` lives
- **The CLI auto-discovers it** — `sf code-analyzer run` from project root automatically picks up `code-analyzer.yml` in that directory. No `--config-file` flag needed.
- User says "configure code analyzer" with no specifics? → **Ask what they want to customize**. Don't create an empty or boilerplate file.

**Workflow:**
1. User requests a customization (e.g., "disable PMD", "ignore test files", "increase SFGE memory")
2. Check if `code-analyzer.yml` exists at project root
3. If NO → create it at project root with ONLY the requested override
4. If YES → read it, then edit in the requested change
5. Validate with `sf code-analyzer config`

---

## Step 1: Understand Intent and Map to Config Sections

The user can request ANY combination of configuration changes in natural language. Your job is to:

1. **Parse what they want** — may be one thing or many things combined
2. **Map each request to the correct section(s) of `code-analyzer.yml`**
3. **Create the file if it doesn't exist, then apply all changes**

### The `code-analyzer.yml` Structure (what you can write/edit)

```yaml
config_root: .                    # Root for relative path resolution
log_folder: <path>                # Where logs are written
log_level: <1-5>                  # 1=Error, 2=Warn, 3=Info, 4=Debug, 5=Fine

ignores:                          # Files/folders excluded from scanning
  files: [<glob patterns>]

engines:                          # Per-engine settings
  <engine_name>:
    disable_engine: <bool>
    <engine_specific_keys>: ...

rules:                            # Per-rule overrides
  <engine_name>:
    <rule_name>:
      severity: <1-5>
      tags: [<strings>]
      disabled: <bool>

suppressions:                     # Bulk suppression configuration
  disable_suppressions: <bool>
  "<file_or_folder_path>":
    - rule_selector: "<selector>"
      max_suppressed_violations: <number|null>
      reason: "<why>"
```

### Mapping Principle

Any user request maps to one or more sections above. Parse the intent and edit the right section(s):

| Intent Category | Maps To | Examples of What User Might Say |
|----------------|---------|-------------------------------|
| Setup / Install | Step 2 (prerequisites + install) | "set up", "install", "get started", "new laptop", "from scratch" |
| **Diagnose / Fix** | **Step 2A (systematic debug)** | **"not working", "broken", "fix my setup", "scan fails", "getting errors"** |
| Engine control | `engines.<name>.disable_engine` | "disable X", "turn off Y", "only use Z", "enable all" |
| Engine tuning | `engines.<name>.<property>` | "increase memory", "change heap", "use my eslint config", "set tokens to 50" |
| File exclusions | `ignores.files` | "exclude", "ignore", "skip", "don't scan X" |
| Rule severity | `rules.<engine>.<rule>.severity` | "make X critical", "promote", "demote", "change severity" |
| Rule disable | `rules.<engine>.<rule>.disabled` | "disable rule X", "turn off Y rule", "remove Z" |
| Rule tags | `rules.<engine>.<rule>.tags` | "tag X as security", "add recommended tag" |
| Suppressions | `suppressions` section | "suppress X in folder Y", "allow N violations" |
| CI/CD | Generate pipeline file (separate from config) | "github actions", "CI", "quality gate" |
| View/inspect | Read file + `sf code-analyzer config` | "show config", "what's configured", "current settings" |

### File Existence Decision

**BEFORE editing anything**, check if `code-analyzer.yml` exists at project root:

```bash
ls code-analyzer.yml code-analyzer.yaml 2>/dev/null
```

- **File does NOT exist** → Create it at project root with ONLY the user's requested override(s)
- **File exists** → Read it, then Edit to add/modify the requested section(s)

The CLI auto-discovers `code-analyzer.yml` in the current directory. Since scans run from project root, the file must live there.

### ⚠️ Rule Name Resolution — ALWAYS Before Writing YAML

When a user references rules by partial, descriptive, or approximate names (e.g., "the doc rule", "CRUD violation", "console rule", "hardcoded values"), you MUST resolve to exact rule names using the lookup in **Step 6.1** BEFORE writing any YAML. The `code-analyzer.yml` file silently ignores rule names that don't exactly match — there is no error, the override just won't apply.

**Examples of fuzzy → exact resolution needed:**
- "Disable the ApexDoc rule" → lookup confirms `ApexDoc` (engine: `pmd`)
- "Demote no-console to low" → lookup confirms `no-console` (engine: `eslint`)
- "Make CRUD violations critical" → lookup confirms `ApexCRUDViolation` (engine: `pmd`)
- "Turn off the hardcoded values check" → lookup finds `@salesforce-ux/slds/no-hardcoded-values-slds2` (engine: `eslint`)
- "Disable the injection rule" → multiple matches possible → ask user which one

**Only skip the lookup** when the user provides an unambiguous, exact, well-known name (e.g., "ApexDoc", "no-console", "no-unused-vars").

### Handling Combined/Complex Requests

Users will often combine multiple changes in one request. Handle ALL of them in a single edit:

- "Disable PMD's ApexDoc rule and make CRUD violations critical" → edit two entries under `rules.pmd`
- "Exclude test files and vendor code, and increase SFGE memory" → edit `ignores.files` + `engines.sfge.java_max_heap_size`
- "Set up code analyzer with only ESLint and PMD, ignore node_modules" → create file with `engines` (disable others) + `ignores`
- "Make all security rules severity 1" → look up rules via `sf code-analyzer rules --rule-selector Security`, then override each
- "Configure code analyzer" (no specifics) → ask user what they want to customize before creating any file

### Quick Reference: Common Requests → Config Output

| User Says | Resulting YAML |
|-----------|---------------|
| "configure code analyzer" | Ask user what to customize — don't create file until there's an actual override |
| "disable the ApexDoc rule" | `rules: pmd: ApexDoc: disabled: true` |
| "only scan Apex, no JavaScript" | `engines: eslint: disable_engine: true` + `engines: retire-js: disable_engine: true` |
| "ignore all test files" | `ignores: files: ["**/test/**", "**/__tests__/**", "**/*.test.js"]` |
| "make security rules critical" | Look up rules, then `rules: <engine>: <rule>: severity: 1` for each |
| "increase SFGE memory to 8g" | `engines: sfge: java_max_heap_size: "8g"` |
| "use my project's ESLint config" | `engines: eslint: auto_discover_eslint_config: true` |
| "suppress CRUD violations in legacy folder" | `suppressions: "force-app/legacy/": [{rule_selector: "pmd:ApexCRUDViolation", reason: "..."}]` |

**The AI must understand the YAML schema and write valid config for ANY request, not just the examples above.**

---

## Step 2: Check Prerequisites and Install

Run `bash "<skill_dir>/scripts/check-prerequisites.sh"` or check manually:

```bash
sf --version 2>&1                                    # sf CLI
sf plugins --core 2>&1 | grep -i "code-analyzer"    # Plugin
java -version 2>&1                                   # Java 11+ (PMD, CPD, SFGE)
node --version 2>&1                                  # Node 18+ (ESLint, RetireJS)
python3 --version 2>&1                               # Python 3 (Flow engine)
```

If anything is missing, install it (**always ask user first**):

```bash
npm install -g @salesforce/cli                       # sf CLI
sf plugins install @salesforce/plugin-code-analyzer  # Code Analyzer plugin
```

For Java/Node/Python installs, read `<skill_dir>/references/engine-prerequisites.md`.
If install fails, read `<skill_dir>/references/troubleshooting.md`.

---

## Step 2A: Diagnose and Fix a Broken Setup

**TRIGGER:** User says "not working", "broken", "getting errors", "scan fails", "help me fix", etc.

**Read `<skill_dir>/references/diagnostic-flow.md`** for the complete layered diagnostic procedure, fix table, and anti-patterns.

**Key principles (always apply):**
- Never search for binaries (`which`, `find`, `ls /opt/homebrew/bin/`)
- Never use `sfdx` as a workaround — only `sf`
- Fix layer by layer: CLI → Plugin → Engine deps → verify scan
- Give user ONE command at a time, wait for confirmation before continuing
- After fix succeeds, proceed to run the full scan automatically

---

## Step 3: Create or Edit `code-analyzer.yml`

**Only triggered when user requests a customization.** Never create proactively.

### Creating (file doesn't exist)

Choose **one** of the two approaches below — do not run both:

**Option A — Auto-generate from project type (recommended for first-time setup):**

Run `bash "<skill_dir>/scripts/generate-config.sh"`. This detects Apex, LWC, and Flow markers and produces a minimal `code-analyzer.yml` suited to the project. Skip to the "After any create/edit, validate" section.

> Note: The script exits with an error if `code-analyzer.yml` already exists. Delete the existing file first if you need to regenerate.

**Option B — Write manually (when the user has specific customizations in mind):**

Read the appropriate example config as a reference for structure:
- For Apex-only projects, read `<skill_dir>/examples/apex-project-config.yml`
- For LWC-only projects, read `<skill_dir>/examples/lwc-project-config.yml`
- For full-stack (Apex + LWC + Flows), read `<skill_dir>/examples/fullstack-project-config.yml`

Write the file at project root using the Write tool. Include ONLY the user's requested changes:

```bash
# Example: user said "ignore test files and increase SFGE memory"
# → Write to project root (where sfdx-project.json lives):
```

```yaml
ignores:
  files:
    - "**/test/**"
    - "**/__tests__/**"

engines:
  sfge:
    java_max_heap_size: "4g"
```

Do NOT add `config_root`, `log_folder`, or any other field the user didn't ask for.

### Editing (file already exists)

Read the file, then use the Edit tool to add/modify only the relevant section. Preserve everything else.

### After any create/edit, validate:

Run `bash "<skill_dir>/scripts/validate-config.sh"` to validate YAML syntax and schema correctness, or use the CLI directly:

```bash
sf code-analyzer config
```

(No `--config-file` needed — the CLI auto-discovers `code-analyzer.yml` in CWD.)

### If user says "configure code analyzer" with no specifics

Ask: "What would you like to customize? For example: ignore certain files, change rule severities, tune engine settings, or disable engines you don't need."

---

## Step 4: Enable/Disable Engines

Edit the `engines` section in `code-analyzer.yml`:

```yaml
engines:
  pmd:
    disable_engine: true       # Disable PMD
  eslint:
    disable_engine: false      # Enable ESLint (default)
```

Valid engine names: `pmd`, `cpd`, `eslint`, `regex`, `retire-js`, `flow`, `sfge`, `apexguru`

**Always validate after editing:**
```bash
sf code-analyzer config --config-file code-analyzer.yml
```

---

## Step 5: Ignore Patterns

Edit the `ignores` section in `code-analyzer.yml`:

```yaml
ignores:
  files:
    - "**/node_modules/**"
    - "**/.sfdx/**"
    - "**/.sf/**"
    - "**/vendor/**"
    - "**/*.min.js"
```

Common patterns:

| Pattern | Excludes |
|---------|----------|
| `**/node_modules/**` | npm dependencies |
| `**/.sfdx/**`, `**/.sf/**` | SF CLI internals |
| `**/test/**`, `**/__tests__/**` | Test directories |
| `**/*.test.js`, `**/*.spec.js` | Test files |
| `**/jest-mocks/**` | Jest mocks |
| `**/vendor/**`, `**/*.min.js` | Third-party/minified |
| `**/staticresources/**` | Static resources |

---

## Step 6: Rule Overrides

Edit the `rules` section in `code-analyzer.yml`. Each rule can have `severity`, `tags`, and `disabled` overrides:

```yaml
rules:
  pmd:
    ApexCRUDViolation:
      severity: 1              # Promote to Critical
    AvoidGlobalModifier:
      disabled: true           # Turn off entirely
    ApexDoc:
      severity: 5              # Demote to Info
      tags: ["Documentation"]
  eslint:
    no-console:
      severity: 4              # Demote to Low
    no-unused-vars:
      severity: 2              # Promote to High
```

**Severity values:** `1`/Critical, `2`/High, `3`/Moderate, `4`/Low, `5`/Info

### 6.1 Rule Name Resolution (Fuzzy Matching)

**⚠️ CRITICAL:** A misspelled or partial rule name in `code-analyzer.yml` is SILENTLY IGNORED — no error, the override just won't apply.

**When users reference rules by approximate names** (e.g., "the doc rule", "CRUD violation", "hardcoded values"), resolve to exact names BEFORE writing YAML:

```bash
sf code-analyzer rules --rule-selector all 2>&1 | grep -i "<USER_KEYWORD>"
```

- **1 match** → use that exact name + its engine for the YAML path
- **Multiple matches** → ask user which one they meant
- **0 matches** → try broader keywords or inform user

**Skip the lookup only** when the name is unambiguous and exact (e.g., "ApexDoc", "no-console", "no-unused-vars").

**For detailed matching strategies, common fuzzy→exact mappings, and engine identification:** Read `<skill_dir>/references/rule-name-resolution.md`.

---

## Step 7: Engine-Specific Settings

Edit the `engines` section. Most common overrides:

```yaml
engines:
  sfge:
    java_max_heap_size: "4g"      # <200 classes→"2g", 200-500→"4g", 500+→"6g"/"8g"
    java_thread_count: 4
    java_thread_timeout: 900000
  eslint:
    auto_discover_eslint_config: true    # Use project's own ESLint config
    eslint_config_file: "./eslint.config.mjs"
  pmd:
    custom_rulesets: ["./config/custom-pmd-rules.xml"]
    java_classpath_entries: ["./lib/custom-rules.jar"]
  cpd:
    minimum_tokens: { apex: 100, javascript: 100 }
  apexguru:
    target_org: "my-org-alias"
  flow:
    python_command: "python3"
  regex:
    custom_rules:
      NoHardcodedIds:
        regex: "/[a-zA-Z0-9]{15,18}/"
        file_extensions: [".cls", ".trigger"]
        description: "Detects hardcoded Salesforce record IDs"
        severity: 2
        tags: ["Security"]
```

For full property list per engine, read `<skill_dir>/references/config-schema.md`.

---

## Step 8: CI/CD Pipeline Setup

Detect CI system from workspace (`.github/workflows/` → GitHub Actions, `Jenkinsfile` → Jenkins, etc.). Read `<skill_dir>/references/ci-cd-templates.md` for templates. Use `<skill_dir>/examples/ci-github-actions.yml` as GitHub Actions base. Key flags: `--severity-threshold 2` (gate), `--output-file results.sarif` (GitHub scanning), `--config-file code-analyzer.yml`.

---

## Step 9: View Current Configuration

```bash
sf code-analyzer config                               # Show effective config
sf code-analyzer config --rule-selector pmd:Security  # Specific rules
sf code-analyzer config --include-unmodified-rules    # All defaults
```

---

## Cross-Skill Integration

This skill works together with `dx-code-analyzer-run`. The AI agent should seamlessly hand off between them:

### When `dx-code-analyzer-run` delegates HERE:

If a user says "scan my code" / "run code analyzer" but it fails (CLI missing, plugin not installed, or scan errors out), `dx-code-analyzer-run` delegates to this skill. In that case:

1. Run the **diagnose and fix** flow (Step 2A) — find what's broken, fix it
2. After everything works, **automatically proceed to run the scan** — do not stop and ask. The user's original intent was to scan.
3. Hand execution back to `dx-code-analyzer-run` behavior (build command, execute, parse results).

### When THIS skill hands off to `dx-code-analyzer-run`:

After any successful configuration action, offer to run a scan (e.g., "Setup complete! Want me to run a scan?", "Config updated — want to scan and verify?"). If user says yes, proceed with `dx-code-analyzer-run` behavior.

### When user intent spans BOTH skills:

Handle end-to-end: "not working" → Diagnose → Fix → Scan. "Set up and scan" → Install → Scan. "Disable ESLint and scan Apex" → Edit config → Run with `--rule-selector pmd`. Always follow through to the user's final intent.

---

## Rules / Constraints

| Constraint | Rationale |
|-----------|-----------|
| Only create YAML when user requests a customization | Defaults work without any file — don't create boilerplate |
| Place YAML at project root only | CLI auto-discovers `code-analyzer.yml` from CWD |
| Write only overrides, never duplicate defaults | Keep file minimal and intentional |
| Use Write tool to create, Edit tool to modify | Preserves existing settings |
| Validate after every change | `sf code-analyzer config` catches YAML errors |
| Ask before installing prerequisites | Never auto-install without consent |
| Never delete existing config without asking | User may have custom settings |
| After setup, offer to scan | Close the loop — config without scan is incomplete |

---

## Gotchas

| Issue | Solution |
|-------|----------|
| Config not picked up | Must be `code-analyzer.yml` in CWD or use `--config-file` |
| YAML validation fails | Spaces only (no tabs), check colon spacing |
| SFGE out of memory | Increase `java_max_heap_size` in engines section |
| ESLint rules missing | Set `auto_discover_eslint_config: true` |

For full troubleshooting, read `<skill_dir>/references/troubleshooting.md`.

---

## Reference File Index

`<skill_dir>` is the absolute path to the directory containing this SKILL.md file.

| File | Purpose |
|------|---------|
| `<skill_dir>/scripts/check-prerequisites.sh` | Environment check |
| `<skill_dir>/scripts/generate-config.sh` | Auto-detect project type and generate config |
| `<skill_dir>/scripts/validate-config.sh` | Validate YAML after changes |
| `<skill_dir>/references/config-schema.md` | Full YAML schema documentation |
| `<skill_dir>/references/diagnostic-flow.md` | Step 2A: layered diagnostic procedure and fix table |
| `<skill_dir>/references/rule-name-resolution.md` | Step 6.1: fuzzy rule name lookup strategies and mappings |
| `<skill_dir>/references/engine-prerequisites.md` | Install instructions per engine |
| `<skill_dir>/references/ci-cd-templates.md` | CI/CD pipeline templates |
| `<skill_dir>/references/troubleshooting.md` | Common setup issues and fixes |
| `<skill_dir>/examples/apex-project-config.yml` | Config for Apex-only project |
| `<skill_dir>/examples/lwc-project-config.yml` | Config for LWC-only project |
| `<skill_dir>/examples/fullstack-project-config.yml` | Config for Apex + LWC + Flows |
| `<skill_dir>/examples/ci-github-actions.yml` | GitHub Actions workflow |
