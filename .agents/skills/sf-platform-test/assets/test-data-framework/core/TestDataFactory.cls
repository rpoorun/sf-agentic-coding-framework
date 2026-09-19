/**
 * @description       : Abstract registry for project-owned fixture helpers.
 * @instruction       : Override registration after construction; keep all business flows in the project subclass.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataFactoryContractTest
 */
public abstract with sharing class TestDataFactory {
    private Map<Schema.SObjectType, SObjectTestDataHelper> helpers;
    private Boolean initializing = false;

    /**
     * @description Supply project registrations without constructing fixture records.
     * @author Rishikesh Poorun
     * @return Map of object types to stateless helper instances.
     */
    protected abstract Map<Schema.SObjectType, SObjectTestDataHelper> registerHelpers();

    /**
     * @description Lazily validate and resolve one registered helper.
     * @author Rishikesh Poorun
     * @param objectType Requested object type.
     * @return Matching helper or a descriptive framework exception.
     */
    protected SObjectTestDataHelper resolveHelper(Schema.SObjectType objectType) {
        if (!Test.isRunningTest()) {
            throw new TestDataFrameworkException('Fixture factories are restricted to tests.');
        }
        if (objectType == null) {
            throw new TestDataFrameworkException('Requested SObject type must not be null.');
        }
        initializeHelpers();
        if (!helpers.containsKey(objectType)) {
            throw new TestDataFrameworkException('No helper registered for ' + String.valueOf(objectType) + '.');
        }
        return helpers.get(objectType);
    }

    /**
     * @description Validate registrations before publishing the registry.
     * @author Rishikesh Poorun
     */
    private void initializeHelpers() {
        if (helpers != null) {
            return;
        }
        if (initializing) {
            throw new TestDataFrameworkException('Registration must not resolve helpers recursively.');
        }
        initializing = true;
        try {
            helpers = validateRegistrations(registerHelpers());
        } finally {
            initializing = false;
        }
    }

    /**
     * @description Copy only complete, identity-consistent registrations.
     * @author Rishikesh Poorun
     * @param registrations Project-supplied registrations.
     * @return Validated map, independent of the project map.
     */
    private Map<Schema.SObjectType, SObjectTestDataHelper> validateRegistrations(
        Map<Schema.SObjectType, SObjectTestDataHelper> registrations) {
        if (registrations == null) {
            throw new TestDataFrameworkException('Helper registrations must not be null.');
        }
        Map<Schema.SObjectType, SObjectTestDataHelper> validated =
            new Map<Schema.SObjectType, SObjectTestDataHelper>();
        for (Schema.SObjectType objectType : registrations.keySet()) {
            SObjectTestDataHelper helper = registrations.get(objectType);
            if (objectType == null || helper == null || helper.getSObjectType() != objectType) {
                throw new TestDataFrameworkException('Helper registration must match its SObject type.');
            }
            validated.put(objectType, helper);
        }
        return validated;
    }
}
