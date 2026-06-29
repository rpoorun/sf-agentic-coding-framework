---
name: sf-platform-lwc
description: "Lightning Web Components with PICKLES methodology and 165-point scoring. Use this skill when the user creates or edits LWC components, builds wire service patterns, or writes Jest tests for LWC. TRIGGER when: user creates/edits LWC components, touches lwc/**/*.js, .html, .css, .js-meta.xml files, or asks about wire service, SLDS, or Jest LWC tests. DO NOT TRIGGER when: Apex classes (use platform-apex-generate), Aura components, or Visualforce."
metadata:
  version: "1.0"
  cloud: "Platform"
  synthesized: true
  sources:
    - forcedotcom/sf-skills :: experience-lwc-generate
    - Clientell-Ai/salesforce-skills :: sf-lwc
    - DietrichGebert/ponytail (refactored via LEAN_CODE_STANDARDS.md)
    - JuliusBrussee/caveman (refactored via LEAN_CODE_STANDARDS.md)
---

# sf-platform-lwc: Lightning Web Components

| Field | Value |
| --- | --- |
| Skill ID | `sf-platform-lwc` |
| Cloud | Platform |
| Version | 1.0 |
| Synthesized | Yes — deduplicated and merged from the source(s) below |
| Sources | forcedotcom/sf-skills :: experience-lwc-generate; Clientell-Ai/salesforce-skills :: sf-lwc; lean-coding discipline refactored from DietrichGebert/ponytail and JuliusBrussee/caveman |

Before authoring, apply the [Lean Decision Ladder](../../standards/LEAN_CODE_STANDARDS.md#the-lean-decision-ladder-apexlwc-refactor-of-ponytail): prefer an existing Lightning Base Component, shared LWC utility, or `@wire` adapter over a new component or hand-rolled plumbing, and build the smallest correct bundle once the requirement is understood. Lean does not relax accessibility, loading/empty/error states, or CRUD/FLS-safe Apex calls — see "Not Lazy About" in that file.

The first time in a session you touch a given component, retrieve it from the dev org first per [Pre-Development Retrieve](../../workflows/DEPLOYMENT.md#pre-development-retrieve-mandatory) — do not generate or edit on top of a local copy that may be stale relative to the org.

Use this skill when the user needs **Lightning Web Components**: LWC bundles, wire patterns, Apex/GraphQL integration, SLDS 2 styling, accessibility, performance work, or Jest unit tests.

## When This Skill Owns the Task

Use `experience-lwc-generate` when the work involves:
- `lwc/**/*.js`, `.html`, `.css`, `.js-meta.xml`
- component scaffolding and bundle design
- wire service, Apex integration, GraphQL integration
- SLDS 2, dark mode, and accessibility work
- Jest unit tests for LWC

Delegate elsewhere when the user is:
- writing Apex controllers or business logic first → [platform-apex-generate](../platform-apex-generate/SKILL.md)
- building Flow XML rather than an LWC screen component → [automation-flow-generate](../automation-flow-generate/SKILL.md)
- deploying metadata → [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md)

---

## Required Context to Gather First

Ask for or infer:
- component purpose and target surface
- data source: LDS, Apex, GraphQL, LMS, or external system via Apex
- whether the user needs tests
- whether the component must run in Flow, App Builder, Experience Cloud, or dashboard contexts
- accessibility and styling expectations

---

## Recommended Workflow

### 1. Choose the right architecture
Use the **PICKLES** mindset:
- prototype
- integrate the right data source
- compose component boundaries
- define interaction model
- use platform libraries
- optimize execution
- enforce security

### 2. Choose the right data access pattern
| Need | Default pattern |
|---|---|
| single-record UI | LDS / `getRecord` |
| simple CRUD form | base record form components |
| complex server query | Apex `@AuraEnabled(cacheable=true)` |
| related graph data | GraphQL wire adapter |
| cross-DOM communication | Lightning Message Service |

### 3. Start from an asset when useful
Use provided assets for:
- basic component bundles
- datatables
- modal patterns
- Flow screen components
- GraphQL components
- LMS message channels
- Jest tests
- TypeScript-enabled components

### 4. Validate for frontend quality
Check:
- accessibility
- SLDS 2 / dark mode compliance
- event contracts
- performance / rerender safety
- Jest coverage when required

### 5. Hand off supporting backend or deploy work
Use:
- [platform-apex-generate](../platform-apex-generate/SKILL.md) for controllers / services
- [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md) for deployment
- [platform-apex-test-run](../platform-apex-test-run/SKILL.md) only for Apex-side test loops, not Jest

---

## JSDoc Comment Block (Mandatory)

Every exported class/component and every non-trivial method/function in generated or modified JS must carry a JSDoc header using the same author-identity rule as Apex (see [SALESFORCE_APEX_STANDARDS.md](../../standards/SALESFORCE_APEX_STANDARDS.md#apexdoc-comment-block-mandatory)):

```js
/**
 * @description       : {What this component/class does and why.}
 * @author            : {author_name} <{author_email}>
 * @group             : {Logical grouping, e.g. UI Components}
 * @last modified on  : {DD-MM-YYYY}
 * @last modified by  : {author_name} <{author_email}>
 */
export default class ExampleComponent extends LightningElement { ... }

/**
 * @description {What this method does and why, if non-obvious.}
 * @author      {author_name}
 * @param       {recordId} The record Id to load.
 * @return      {Promise<Object>} Resolves with the loaded record data.
 */
```

If `.agents/project/ENVIRONMENT.md` does not yet have an author name/email recorded, ask the user before generating the first header in the session — same rule as Apex, never write an AI/tool name as the author.

## High-Signal Rules

- prefer platform base components over reinventing controls
- use `@wire` for reactive read-only use cases; imperative calls for explicit actions and DML paths
- do not introduce inaccessible custom UI
- avoid hardcoded colors; use SLDS 2-compatible styling hooks / variables
- avoid rerender loops in `renderedCallback()`
- keep component communication patterns explicit and minimal

---

## Output Format

When finishing, report in this order:
1. **Component(s) created or updated**
2. **Data access pattern chosen**
3. **Files changed**
4. **Accessibility / styling / testing notes**
5. **Next implementation or deploy step**

Suggested shape:

```text
LWC work: <summary>
Pattern: <wire / apex / graphql / lms / flow-screen>
Files: <paths>
Quality: <a11y, SLDS2, dark mode, Jest>
Next step: <deploy, add controller, or run tests>
```

---

## Local Development Server

Preview LWC components locally with hot reload — no deployment needed. Run the commands in `scripts/local-dev-preview.sh` to start a local dev session for a component, app, or Experience Cloud site.

Local Dev commands install just-in-time on first run. They are long-running processes that open a browser with live preview. Changes to `.js`, `.html`, and `.css` files auto-reload instantly. Requires an active org connection for data and Apex callouts.

---

## Cross-Skill Integration

| Need | Delegate to | Reason |
|---|---|---|
| Apex controller or service | [platform-apex-generate](../platform-apex-generate/SKILL.md) | backend logic |
| embed in Flow screens | [automation-flow-generate](../automation-flow-generate/SKILL.md) | declarative orchestration |
| deploy component bundle | [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md) | org rollout |
| create supporting metadata (message channels, objects) | [platform-metadata-deploy](../platform-metadata-deploy/SKILL.md) | metadata deployment |

---

## Reference File Index

### Start here
- [references/component-patterns.md](references/component-patterns.md) — component architecture patterns and bundle design
- [references/slds-design-guide.md](references/slds-design-guide.md) — SLDS 2 styling, dark mode, CSS hooks
- [references/lwc-best-practices.md](references/lwc-best-practices.md) — high-signal rules and anti-patterns
- [references/scoring-and-testing.md](references/scoring-and-testing.md) — 165-point scoring rubric across 8 categories
- [references/jest-testing.md](references/jest-testing.md) — Jest unit test patterns and async rendering helpers
- [references/slds-blueprints.json](references/slds-blueprints.json) — machine-readable SLDS component blueprints
- [references/cli-commands.md](references/cli-commands.md) — SF CLI commands for LWC development

### Accessibility / performance / state
- [references/accessibility-guide.md](references/accessibility-guide.md) — WCAG, ARIA, keyboard navigation patterns
- [references/performance-guide.md](references/performance-guide.md) — lazy loading, debouncing, rerender safety
- [references/state-management.md](references/state-management.md) — reactive state patterns and LMS
- [references/template-anti-patterns.md](references/template-anti-patterns.md) — common HTML template mistakes to avoid

### Integration / advanced features
- [references/lms-guide.md](references/lms-guide.md) — Lightning Message Service patterns
- [references/flow-integration-guide.md](references/flow-integration-guide.md) — Flow screen component design
- [references/advanced-features.md](references/advanced-features.md) — Spring '26 features: TypeScript, lwc:on, GraphQL mutations
- [references/async-notification-patterns.md](references/async-notification-patterns.md) — toast, notifications, async flows
- [references/triangle-pattern.md](references/triangle-pattern.md) — parent-child-sibling communication triangle

### Asset templates
- [assets/basic-component/basicComponent.js](assets/basic-component/basicComponent.js) — wire service, error/loading states, event dispatching
- [assets/datatable-component/datatableComponent.js](assets/datatable-component/datatableComponent.js) — datatable with inline editing
- [assets/flow-screen-component/flowScreenComponent.js](assets/flow-screen-component/flowScreenComponent.js) — Flow screen with input/output properties
- [assets/form-component/formComponent.js](assets/form-component/formComponent.js) — form validation and DML patterns
- [assets/graphql-component/graphqlComponent.js](assets/graphql-component/graphqlComponent.js) — GraphQL wire adapter with cursor-based pagination
- [assets/jest-test/componentName.test.js.example](assets/jest-test/componentName.test.js.example) — Jest test template (copy and rename, remove `.example` suffix)
- [assets/message-channel/lmsPublisher.js](assets/message-channel/lmsPublisher.js) — LMS publisher pattern
- [assets/message-channel/lmsSubscriber.js](assets/message-channel/lmsSubscriber.js) — LMS subscriber pattern
- [assets/modal-component/modalComponent.js](assets/modal-component/modalComponent.js) — modal with focus trap and ESC handling
- [assets/record-picker/recordPicker.js](assets/record-picker/recordPicker.js) — record picker with search
- [assets/state-store/store.js](assets/state-store/store.js) — reactive state store for cross-component state
- [assets/typescript-component/typescriptComponent.ts](assets/typescript-component/typescriptComponent.ts) — TypeScript-enabled component (Spring '26)
- [assets/workspace-api/workspaceComponent.js](assets/workspace-api/workspaceComponent.js) — workspace API for tab and focus management
- [assets/apex-controller/LwcController.cls](assets/apex-controller/LwcController.cls) — Apex controller with `@AuraEnabled(cacheable=true)` patterns

### Scripts
- [scripts/local-dev-preview.sh](scripts/local-dev-preview.sh) — local dev server commands for component, app, and site preview

---

## Score Guide

| Score | Meaning |
|---|---|
| 150+ | production-ready LWC bundle |
| 125–149 | strong component with minor polish left |
| 100–124 | functional but review recommended |
| < 100 | needs significant improvement |

---

## Merged Source Material

The sections below are retained from the secondary source(s) for completeness. Treat the primary guidance above as authoritative; use this section only for details not already covered above, and reconcile any conflicts in favor of the primary source.

### Supplemental Guidance from `sf-lwc` (Clientell-Ai/salesforce-skills :: sf-lwc)

# LWC Scaffolder

You are a Salesforce Lightning Web Component specialist. Generate complete, production-ready LWC bundles.

## LWC Bundle Structure
Every LWC consists of these files in `force-app/main/default/lwc/componentName/`:

```
myComponent/
├── myComponent.html          # Template
├── myComponent.js            # Controller
├── myComponent.css           # Styles (SLDS-compliant)
├── myComponent.js-meta.xml   # Configuration
└── __tests__/
    └── myComponent.test.js   # Jest tests
```

## Naming Conventions
- Bundle folder: `camelCase` (e.g., `accountList`)
- HTML markup: `kebab-case` with `c-` namespace (e.g., `<c-account-list>`)
- JS class: `PascalCase` (e.g., `AccountList`)
- CSS: follows component name

## JavaScript Controller Pattern
```javascript
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getRecords from '@salesforce/apex/MyController.getRecords';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';

export default class MyComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @track records = [];
    error;
    isLoading = false;

    @wire(getRecords, { recordId: '$recordId' })
    wiredRecords({ error, data }) {
        if (data) {
            this.records = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = [];
        }
    }

    handleAction() {
        this.isLoading = true;
        imperativeMethod({ param: this.recordId })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Operation completed',
                    variant: 'success'
                }));
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'An error occurred',
                    variant: 'error'
                }));
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}
```

## Meta XML Configuration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
        <target>lightning__AppPage</target>
        <target>lightning__HomePage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Account</object>
            </objects>
            <property name="title" type="String" default="My Component"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

## Jest Test Pattern
```javascript
import { createElement } from 'lwc';
import MyComponent from 'c/myComponent';
import getRecords from '@salesforce/apex/MyController.getRecords';

// Mock Apex method
jest.mock('@salesforce/apex/MyController.getRecords', () => ({
    default: jest.fn()
}), { virtual: true });

const MOCK_DATA = [
    { Id: '001xx000003ABCDEF', Name: 'Test Account' }
];

describe('c-my-component', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders records when data is returned', async () => {
        getRecords.mockResolvedValue(MOCK_DATA);

        const element = createElement('c-my-component', { is: MyComponent });
        element.recordId = '001xx000003ABCDEF';
        document.body.appendChild(element);

        await Promise.resolve();

        const items = element.shadowRoot.querySelectorAll('.record-item');
        expect(items.length).toBe(1);
    });

    it('shows error when apex call fails', async () => {
        getRecords.mockRejectedValue(new Error('Test error'));

        const element = createElement('c-my-component', { is: MyComponent });
        document.body.appendChild(element);

        await Promise.resolve();

        const errorEl = element.shadowRoot.querySelector('.error-message');
        expect(errorEl).toBeTruthy();
    });
});
```

### Lightning Data Service (LDS)
Use `lightning/uiRecordApi` for CRUD without Apex:
- `getRecord` wire adapter — read records with field-level security
- `createRecord`, `updateRecord`, `deleteRecord` — imperative CRUD
- `getObjectInfo`, `getPicklistValues` — metadata access
- `refreshApex()` — invalidate wire cache after mutations
- **When to use**: Simple CRUD. Use Apex wire for complex queries or business logic.

### Lifecycle Hooks
| Hook | When | Common Use |
|------|------|------------|
| `constructor()` | Component created | Initialize state |
| `connectedCallback()` | Inserted into DOM | Fetch data, add listeners |
| `renderedCallback()` | After each render | DOM manipulation (guard with flag!) |
| `disconnectedCallback()` | Removed from DOM | Cleanup listeners, unsubscribe LMS |
| `errorCallback(error, stack)` | Child error | Error boundary, logging |

### Navigation
Use `NavigationMixin` with page reference types:
- `standard__recordPage` — view/edit/clone records (requires `recordId`, `actionName`)
- `standard__objectPage` — object home/list/new (requires `objectApiName`, `actionName`)
- `standard__namedPage` — standard pages (home, chatter, filePreview)
- `standard__webPage` — external URLs (requires `url`)

### Lightning Message Service (LMS)
Cross-DOM communication between LWC, Aura, and Visualforce:
- Define message channel in `.messageChannel-meta.xml`
- `publish(messageContext, channel, payload)` to send
- `subscribe(messageContext, channel, handler, {scope: APPLICATION_SCOPE})` to receive
- Always `unsubscribe()` in `disconnectedCallback()` to prevent memory leaks

### Shadow DOM vs Light DOM
- **Shadow DOM** (default): CSS isolation, encapsulated DOM — use for most components
- **Light DOM** (`lwc:dom="light"`): No encapsulation — use when you need cross-component ARIA references, global CSS, or third-party library DOM access
- Shadow DOM blocks `document.querySelector()` from outside — use `this.template.querySelector()` inside

## Rules
- Always use SLDS classes for styling — avoid custom CSS when SLDS has a utility
- Use `@api` for public properties, reactive by default
- Use `@wire` for declarative data fetching
- Use imperative Apex calls for user-initiated actions
- Handle loading states and errors in every component
- Use `lightning-record-form` / `lightning-record-edit-form` for simple CRUD
- Dispatch custom events for child-to-parent communication
- Use `MessageChannel` for cross-DOM communication

## Gotchas
- `@track` is deprecated — all properties are reactive by default since API v40+
- `renderedCallback()` fires after EVERY render — always guard with a boolean flag to prevent infinite loops
- LDS cache is NOT automatically refreshed — call `refreshApex(wiredProperty)` after imperative mutations
- LMS subscriptions MUST unsubscribe in `disconnectedCallback()` to prevent memory leaks
- Shadow DOM blocks ID-based ARIA references (`aria-labelledby`) across components — use Light DOM for accessibility
- CSP blocks `eval()`, `new Function()`, and inline `<script>` — load third-party libraries via `loadScript()` from Static Resources
- `@api` properties are read-only in the component — parent sets them, child cannot mutate
- Wire adapters re-fire when reactive parameters change — avoid unnecessary parameter changes

## Workflow
1. Understand the component requirements
2. Check for existing components that can be extended
3. Generate all bundle files (HTML, JS, CSS, meta.xml)
4. Generate Jest test file with mock data
5. Deploy: `sf project deploy start -d force-app/main/default/lwc/componentName/`

## References
- [LWC Patterns](references/lwc-patterns.md) — LDS, navigation, LMS, datatable, custom events, slots, accessibility, SLDS, third-party libs, dynamic components, Experience Cloud
