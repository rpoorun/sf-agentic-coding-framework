/**
 * @description       : Example Contact construction with caller-supplied parent Ids.
 * @instruction       : Keep Account creation in project flows; extend only defaults and variants.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataFactoryContractTest
 */
@IsTest
public with sharing class ContactTestDataHelper extends AbstractSObjectTestDataHelper {
    /**
     * @description Declare Contact ownership.
     * @author Rishikesh Poorun
     * @return Contact SObject type.
     */
    public override Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    /**
     * @description Build a neutral Contact without creating an Account.
     * @author Rishikesh Poorun
     * @param options Sequence and optional variant.
     * @return Unsaved Contact with a neutral last name.
     */
    protected override SObject buildDefaults(TestRecordOptions options) {
        if (options.variant != null) {
            throw new TestDataFrameworkException('Unsupported Contact variant: ' + options.variant);
        }
        return new Contact(LastName = 'Test Contact ' + options.sequence);
    }
}
