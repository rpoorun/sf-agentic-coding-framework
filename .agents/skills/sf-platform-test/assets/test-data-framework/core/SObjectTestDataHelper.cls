/**
 * @description       : Uniform single-object build and insert contract.
 * @instruction       : Implement via AbstractSObjectTestDataHelper; prove equivalent semantics for direct implementations.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataHelperContractTest
 */
public interface SObjectTestDataHelper {
    /**
     * @description Identify the single object owned by this helper.
     * @author Rishikesh Poorun
     * @return Non-null object type.
     */
    Schema.SObjectType getSObjectType();

    /**
     * @description Construct one fresh unsaved record without dependency DML.
     * @author Rishikesh Poorun
     * @param options Optional defaults, variant, and explicit overrides.
     * @return A new record with no Id.
     */
    SObject build(TestRecordOptions options);

    /**
     * @description Construct unsaved records in request order without DML.
     * @author Rishikesh Poorun
     * @param requests Non-null list; null elements use default options.
     * @return Fresh records in request order; empty for empty requests.
     */
    List<SObject> buildMany(List<TestRecordOptions> requests);

    /**
     * @description Insert one fixture; propagate ordinary DML failures.
     * @author Rishikesh Poorun
     * @param options Optional defaults, variant, and explicit overrides.
     * @return Inserted record without an automatic reload.
     */
    SObject create(TestRecordOptions options);

    /**
     * @description Insert a homogeneous set with one all-or-none statement.
     * @author Rishikesh Poorun
     * @param requests Non-null list of per-record requests.
     * @return Inserted records in request order, or an empty list.
     */
    List<SObject> createMany(List<TestRecordOptions> requests);
}
