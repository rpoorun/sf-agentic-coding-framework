/**
 * @description       : Example Account defaults and a named variant.
 * @instruction       : Replace sample defaults with project rules; never create parents or repair invalid overrides.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataHelperContractTest
 */
@IsTest
public with sharing class AccountTestDataHelper extends AbstractSObjectTestDataHelper {
    /**
     * @description Declare Account ownership.
     * @author Rishikesh Poorun
     * @return Account SObject type.
     */
    public override Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    /**
     * @description Apply neutral defaults and the optional described variant.
     * @author Rishikesh Poorun
     * @param options Request snapshot including sequence and variant.
     * @return New Account; no DML is performed.
     */
    protected override SObject buildDefaults(TestRecordOptions options) {
        Account record = new Account(Name = 'Test Account ' + options.sequence);
        if (options.variant == 'described') {
            record.Description = 'Sample variant';
        } else if (options.variant != null) {
            throw new TestDataFrameworkException('Unsupported Account variant: ' + options.variant);
        }
        return record;
    }
}
