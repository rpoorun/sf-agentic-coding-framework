/**
 * @description       : Example internal-user defaults with an explicit caller-selected profile.
 * @instruction       : Use one username uniqueness rule; resolve real personas in the project flow.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataHelperContractTest; TestDataFactoryContractTest
 */
@IsTest
public with sharing class UserTestDataHelper extends AbstractSObjectTestDataHelper {
    /**
     * @description Declare User ownership.
     * @author Rishikesh Poorun
     * @return User SObject type.
     */
    public override Schema.SObjectType getSObjectType() {
        return User.SObjectType;
    }

    /**
     * @description Build internal-user fields without selecting or granting access.
     * @author Rishikesh Poorun
     * @param options Must include a ProfileId override for insertion.
     * @return Unsaved User with a unique username.
     */
    protected override SObject buildDefaults(TestRecordOptions options) {
        if (options.variant != null && options.variant != 'internal') {
            throw new TestDataFrameworkException('Unsupported User variant: ' + options.variant);
        }
        String uniquePart = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        return new User(
            FirstName = 'Test',
            LastName = 'Framework Contract User',
            Alias = 'tdfuser',
            Email = 'test.user@example.invalid',
            Username = 'tdf.' + UserInfo.getOrganizationId() + '.' + uniquePart + '@example.invalid',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
    }
}
