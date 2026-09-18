/**
 * @description       : Variant, explicit field overrides, and sequence for one fixture.
 * @instruction       : Keep this request project-neutral; copy it before invoking helper hooks.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataHelperContractTest
 */
public with sharing class TestRecordOptions {
    public String variant;
    public Map<Schema.SObjectField, Object> fieldValues;
    public Integer sequence;

    /**
     * @description Initialize independent defaults for one record request.
     * @author Rishikesh Poorun
     */
    public TestRecordOptions() {
        fieldValues = new Map<Schema.SObjectField, Object>();
        sequence = 1;
    }

    /**
     * @description Snapshot options without changing the caller's map.
     * @author Rishikesh Poorun
     * @param source Optional request; null means default options.
     * @return A new options instance with an independent override map.
     */
    public static TestRecordOptions copyOf(TestRecordOptions source) {
        TestRecordOptions result = new TestRecordOptions();
        if (source != null) {
            result.variant = source.variant;
            result.sequence = source.sequence == null ? 1 : source.sequence;
            if (source.fieldValues != null) {
                result.fieldValues.putAll(source.fieldValues);
            }
        }
        return result;
    }
}
