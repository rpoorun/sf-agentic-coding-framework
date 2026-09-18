# Test Data Framework

## Purpose And Use

Use this reference when creating reusable Apex fixtures, choosing object helpers, designing related-record flows, or planning an authorized factory migration. It owns the build/create contract and project integration guidance. The [test skill](../SKILL.md) owns consuming test headers, user context, assertions, and execution.

The [source templates](../assets/test-data-framework/) implement the reusable core and small examples. They are framework assets, not an installed application or third-party dependency. Adapt and compile them in the target project's approved API version before adoption. Existing factories and tests are not migrated automatically.

## Ownership And Source Map

| Layer | Source | Responsibility |
| --- | --- | --- |
| Framework | [TestDataFactory](../assets/test-data-framework/core/TestDataFactory.cls) | Abstract, lazy helper registration and validated lookup; no business flows. |
| Framework | [SObjectTestDataHelper](../assets/test-data-framework/core/SObjectTestDataHelper.cls) | Instance contract for identity, build, buildMany, create, createMany. |
| Framework | [AbstractSObjectTestDataHelper](../assets/test-data-framework/core/AbstractSObjectTestDataHelper.cls) | Shared request validation, overrides, ordered bulk construction, and all-or-none insertion. |
| Framework | [TestRecordOptions](../assets/test-data-framework/core/TestRecordOptions.cls) | Variant, typed field overrides, deterministic sequence; independent request snapshots. |
| Framework | [TestDataFrameworkException](../assets/test-data-framework/core/TestDataFrameworkException.cls) | Framework request/registration failures; native field-assignment and DML errors propagate. |
| Project examples | [Account](../assets/test-data-framework/examples/AccountTestDataHelper.cls), [Contact](../assets/test-data-framework/examples/ContactTestDataHelper.cls), [User](../assets/test-data-framework/examples/UserTestDataHelper.cls) helpers | Minimal defaults; replace/extend with project variants and requirements. |
| Project example | [ExampleProjectTestDataFactory](../assets/test-data-framework/examples/ExampleProjectTestDataFactory.cls) | Registrations, static convenience facade, typed Account/Contact flow, internal contract-test persona. |
| Contract tests | [Helper tests](../assets/test-data-framework/tests/TestDataHelperContractTest.cls), [factory tests](../assets/test-data-framework/tests/TestDataFactoryContractTest.cls), [flow tests](../assets/test-data-framework/tests/TestDataFlowContractTest.cls) | Verify construction, persistence, registry behavior, dependencies, and setup identity. |

Every class/interface has a matching `.cls-meta.xml`. Template metadata uses API `66.0`; retain an existing project's agreed version unless a change is explicitly required and validated. Check class-name collisions before copying, particularly the existing `TestDataFactory` name.

`ProjectTestDataFactory extends TestDataFactory`. Ordinary object helpers extend `AbstractSObjectTestDataHelper`, which implements `SObjectTestDataHelper`. Direct interface implementations need equivalent contract tests. The interface proves signatures; behavioral tests prove no-DML and persistence semantics.

Keep core behavior free of project prefixes, custom fields, profile names, permission sets, and business record types. Apply project naming conventions on integration. Keep the existing class `@instruction`, method documentation, and test coverage headers; add a real ticket reference to class and method `@description` comments when one applies to that change, without copying an unrelated consumer ticket into generic templates. Never put ticket references into fixture names or use them as lookup keys.

## Helper Contract

| API | Behavior |
| --- | --- |
| `getSObjectType()` | Identify one non-null SObject type. |
| `build(options)` | Return a fresh record without an Id; no DML, including in hooks or dependencies. |
| `buildMany(requests)` | Build in request order with independent per-record overrides. |
| `create(options)` | Delegate to createMany with one request; insert and return it. |
| `createMany(requests)` | Build first, then insert a homogeneous nonempty collection in one all-or-none statement. |

Standard orchestration methods are non-virtual. Extend `getSObjectType` and the protected `buildDefaults` hook. Pass lookup Ids explicitly; project flows create missing parents. Do not update/upsert through create methods or silently reload every inserted record.

| Request | Outcome |
| --- | --- |
| Null options or a null list element | Fresh defaults; default sequence is 1. |
| Null list | Descriptive framework exception. |
| Empty list | Empty result without DML. |
| Unsupported variant, including an unsupported blank value | Explicit error; no fallback persona. |
| Unknown registration or mismatched helper type | Explicit error naming the missing type where applicable. |
| Null field token or another object's field | Reject before DML. |
| Explicit null field value | Preserve null through map membership. |
| Non-null Id override or saved hook result | Reject; reuse belongs to dependency options. |
| Invalid but assignable business value | Preserve it so the real validation can be exercised. |
| Invalid Apex field type | Propagate the native assignment exception; do not coerce it. |
| Insert failure | Propagate DmlException; no partial-success fixture. |

The core's all-or-none fixture insert takes precedence over production batch advice about partial success. Do not introduce DuplicateRuleHeader bypasses or disable validations by default. Use deliberate negative data when testing a duplicate/validation requirement.

## Options, Variants, And Extension

`TestRecordOptions` contains only `variant`, `Map<Schema.SObjectField, Object> fieldValues`, and `sequence`. Apply minimal defaults, then the selected variant, then explicit overrides. Copy options/maps before passing them into hooks. Helpers must remain stateless and return fresh records. Do not cache mutable builders or fixture graphs.

Use named project variants for meaningful record differences and small overrides for field changes. Avoid a subclass for every optional-field combination. Keep common boundaries as `SObject` and `List<SObject>`; Apex does not provide user-defined generic types such as `SObjectTestDataHelper<Account>`. Typed convenience methods may cast and delegate without repeating DML logic.

Initialize registration lazily after construction. The template validates an entire map before caching it and rejects recursive resolution from the registration hook. Registration hooks must not perform DML, construct dependencies, or register the same key twice (a Map would silently replace an earlier value).

The example project factory uses thin static facade methods and private instance flow methods with distinct signatures. Preserve that approach for an existing static API; an instance flow API is also valid for a new project. Do not attempt static polymorphism. A substantial flow may later move to a focused project coordinator while retaining its facade. No universal `Object execute(Object)` flow interface is required.

## Flow Dependencies And Personas

Return typed options and dataset results with explicit Account, Contact, User, owner, and access-assignment references. Tests keep scenario selection, invalid inputs, prices/expected values, and business assertions. Use helpers directly for simple object-only tests; use a named project flow for a complete graph.

The Account/Contact sample demonstrates creation, reuse, saved-record validation, and relationship checks. Its sample methods do not represent a bulk business flow; add collection orchestration where a project needs many related graphs, using createMany per object type.

For a project Distributor flow, expose `createDistributorUser()` as a convenience delegating to `createDistributorDataSet(options)`, which returns the full graph:

1. Resolve the exact intended profile/license and requested permissions.
2. Reuse an eligible internal owner or create one with the required role.
3. Reuse or create the correct Account variant.
4. Reuse or create a Contact linked to that Account.
5. Insert the User with its Contact and selected external profile.
6. Assign only requested access; retain a deliberately restricted variant.
7. Return all references in a typed dataset.

When Contact alone is supplied, resolve and reuse its actual Account. When both are supplied, verify their relationship from persisted data. Reject unsaved dependencies and inaccessible/missing records. Do not silently change existing ownership, partner status, or profiles to make the flow succeed.

A Partner persona needs project verification of partner Account and owner-role prerequisites. Customer Community Plus is not an interchangeable substitute. User creation does not establish a Commerce buyer graph; BuyerAccount, BuyerGroup membership, store, catalog, pricebooks, and entitlements belong in composed Commerce flows when required.

The shipped User helper supports internal fixtures only. It has no default ProfileId and grants no permissions. The sample contract setup selects an internal profile without Modify All Data or View All Data; this is a minimal test identity, not a project's external persona. Replace the selector and neutral user locator when integrating. Fail clearly when no suitable profile exists; never select admin as a fallback.

## Setup, Mixed DML, And Security

Every contract-test class delegates common user and graph creation to `@TestSetup`, re-queries it in each method, and runs the tested operation and assertions under `System.runAs(testUser)`. Consumers retain the same user-context and acceptance-criteria rules from the test skill.

Do not rely on a static dataset or Id cache surviving setup. Re-query by documented relationships and a neutral fixture locator; fail on ambiguous matches. Never encode unrelated Ids in business fields. Unique User usernames use one shared User-specific rule; random uniqueness tokens must not decide scenario correctness.

The project flow owns setup/non-setup DML ordering and test `System.runAs` boundaries. Splitting DML across classes does not resolve Mixed DML, and an async wrapper is not the default solution. Prove the intended persona arrangement in standalone tests as well as deployment validation.

Fixture arrangement deliberately uses system-mode DML, within a test-only construction path, to set up both permitted and restricted scenarios. That does not establish production authorization. `System.runAs` changes user context but does not itself prove CRUD/FLS enforcement: consuming tests must exercise production user-mode/permission checks and assert the required success or denial. Do not strip invalid fixture values or auto-grant access to make tests pass.

The base helper's `createMany` has one method-level `PMD.ApexCRUDViolation` suppression for this fixture-arrangement contract. Non-empty insertion passes through the test-execution guard in `build`; this is not a suppression pattern for production services or controllers.

The interface, options, exception, and abstract bases are ordinary public Apex declarations; the bases guard fixture execution with `Test.isRunningTest()`. Concrete examples and test suites are `@IsTest`. This avoids assuming that test annotations support every extension shape. The ordinary core declarations count toward normal code/coverage rules; compilation and measured coverage in the target org remain adoption evidence. Do not add end-user Apex Class Access, `global` contracts, or managed-package dependencies by default.

## Adoption And Migration

1. Inventory existing helpers, callers, classes with colliding names, persona dependencies, and approved API version.
2. Add the core and a minimal concrete Account helper with contract tests; prove compilation and runtime behavior.
3. Prove Account/Contact relationships and supplied/missing-parent cases.
4. Implement the actual project User persona and Distributor flow after its requirements are resolved.
5. Migrate one authorized consumer via compatibility wrappers, preserving assertions and negative paths.
6. Migrate remaining callers only within approved scope; remove wrappers only after reference checks.
7. Build a transitive compile/runtime dependency matrix, then follow the normal deployment workflow and coverage gate.

Existing `doInsert` APIs may remain as compatibility wrappers: `false` delegates to build/buildMany; `true` delegates to create/createMany. Keep old names and persistence semantics until callers are migrated. The older flat factory assets are legacy examples, not an instruction to generate a second colliding factory.

Do not refactor, delete, rename, or weaken existing test methods as part of unapproved migration. Apply the existing test-preservation directive. Do not change service mappings, pricing, sharing, persona, or API version just to make structural migration pass. Keep project-specific source inventories in the project ticket, not in this reusable reference.

## Verification And Limits

- Build: verify zero DML delta, no Id, independent outputs, request immutability, and no dependency creation.
- Create: verify one inserted record, empty-list no-op, request order, native error propagation, and all-or-none rollback.
- Bulk: use at least 251 simple records where supported. Do not provision 251 external users to satisfy a numeric convention.
- Flow: verify reused records produce no duplicates; reject unsaved, missing, parentless, or mismatched dependencies.
- Persona: verify actual profile/license/role and requested/restricted permissions; test standalone Mixed DML behavior.
- Regression: preserve business assertions and invalid-input scenarios; distinguish factory contract assertions from service acceptance assertions.

The supplied exact DML/count expectations target a minimal org with standard objects. Project automation can add DML or records: document and measure those effects when adapting the suite, without bypassing validations. Run all three contract suites and representative consuming tests. A local parser/analyzer result does not prove Salesforce compilation or runtime success.

## Sources

The architecture is the user-supplied design, implemented as local templates with no library installation or copied upstream implementation. The following are reference material:

- [Salesforce test utility classes](https://trailhead.salesforce.com/content/learn/modules/apex_testing/apex_testing_data): test-scoped data factories.
- [Salesforce Apex for Java developers](https://developer.salesforce.com/blogs/2022/09/an-introduction-to-apex-for-java-developers): Apex inheritance/static behavior and type-system differences.
- [Salesforce Mixed DML testing contexts](https://help.salesforce.com/s/articleView?id=000394229&language=en_US&type=1): verify standalone test execution as well as deployment validation.
- [Beyond the Cloud factory design](https://blog.beyondthecloud.dev/blog/apex-test-data-factory) and [test-lib](https://github.com/beyond-the-cloud-dev/test-lib): related patterns, not dependencies.
