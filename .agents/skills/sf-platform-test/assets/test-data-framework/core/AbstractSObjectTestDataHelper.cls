/**
 * @description       : Common validation, override application, and fixture persistence.
 * @instruction       : Extend only object identity and defaults; build must remain free of DML and dependencies.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataHelperContractTest
 */
public abstract with sharing class AbstractSObjectTestDataHelper implements SObjectTestDataHelper {
    /**
     * @description Identify the one object this implementation builds.
     * @author Rishikesh Poorun
     * @return Non-null object type.
     */
    public abstract Schema.SObjectType getSObjectType();

    /**
     * @description Supply fresh minimal defaults and validate the variant.
     * @author Rishikesh Poorun
     * @param options Private request snapshot; never perform DML here.
     * @return New unsaved record of the declared type.
     */
    protected abstract SObject buildDefaults(TestRecordOptions options);

    /**
     * @description Build defaults then apply the caller's exact field values.
     * @author Rishikesh Poorun
     * @param options Optional per-record request.
     * @return Fresh unsaved record.
     */
    public SObject build(TestRecordOptions options) {
        if (!Test.isRunningTest()) {
            throw new TestDataFrameworkException('Fixture construction is restricted to tests.');
        }
        Schema.SObjectType objectType = getSObjectType();
        if (objectType == null) {
            throw new TestDataFrameworkException('Helper must declare an SObject type.');
        }
        TestRecordOptions request = TestRecordOptions.copyOf(options);
        SObject record = buildDefaults(TestRecordOptions.copyOf(request));
        validateBuiltRecord(record, objectType);
        applyOverrides(record, request.fieldValues, objectType);
        return record;
    }

    /**
     * @description Reject invalid hook output before applying caller values.
     * @author Rishikesh Poorun
     * @param record Result from the construction hook.
     * @param objectType Declared helper identity.
     */
    private void validateBuiltRecord(SObject record, Schema.SObjectType objectType) {
        if (record == null || record.getSObjectType() != objectType) {
            throw new TestDataFrameworkException('Helper must return ' + String.valueOf(objectType) + '.');
        }
        if (record.Id != null) {
            throw new TestDataFrameworkException('Build must return an unsaved record.');
        }
    }

    /**
     * @description Apply typed overrides without repairing invalid business values.
     * @author Rishikesh Poorun
     * @param record Fresh hook result.
     * @param fieldValues Explicit overrides, including null values.
     * @param objectType Declared helper identity.
     */
    private void applyOverrides(SObject record, Map<Schema.SObjectField, Object> fieldValues,
        Schema.SObjectType objectType) {
        Map<String, Schema.SObjectField> fieldsByName = objectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : fieldValues.keySet()) {
            if (field == null || fieldsByName.get(field.getDescribe().getName()) != field) {
                throw new TestDataFrameworkException('Override field must belong to ' + String.valueOf(objectType) + '.');
            }
            if (field == fieldsByName.get('Id') && fieldValues.get(field) != null) {
                throw new TestDataFrameworkException('Build cannot accept an existing record Id.');
            }
            // Map membership preserves explicit nulls and intentionally invalid values.
            record.put(field, fieldValues.get(field));
        }
    }

    /**
     * @description Build one independent record per request without DML.
     * @author Rishikesh Poorun
     * @param requests Non-null list; empty lists are valid.
     * @return Unsaved records in the same order.
     */
    public List<SObject> buildMany(List<TestRecordOptions> requests) {
        if (requests == null) {
            throw new TestDataFrameworkException('Request list must not be null.');
        }
        List<SObject> records = new List<SObject>();
        for (TestRecordOptions request : requests) {
            records.add(build(request));
        }
        return records;
    }

    /**
     * @description Delegate single-record persistence to the bulk operation.
     * @author Rishikesh Poorun
     * @param options Optional per-record request.
     * @return Inserted record with its Id.
     */
    public SObject create(TestRecordOptions options) {
        return createMany(new List<TestRecordOptions>{ options })[0];
    }

    /**
     * @description Insert once with all-or-none semantics and no automatic reload.
     * @author Rishikesh Poorun
     * @param requests Non-null homogeneous record requests.
     * @return Inserted records in request order; empty for no requests.
     */
    // Permanent test-fixture exception: build() rejects non-test callers. Do not filter
    // fields by CRUD/FLS here: restricted-persona tests need exact arranged values.
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public List<SObject> createMany(List<TestRecordOptions> requests) {
        List<SObject> records = buildMany(requests);
        if (!records.isEmpty()) {
            // Fixture arrangement intentionally uses system-mode DML; tests own security assertions.
            insert records;
        }
        return records;
    }
}
