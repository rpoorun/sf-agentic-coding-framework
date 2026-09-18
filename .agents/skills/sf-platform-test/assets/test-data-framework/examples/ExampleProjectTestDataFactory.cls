/**
 * @description       : Example registrations, related-record flow, and contract-test user setup.
 * @instruction       : Adapt this project-owned sample; keep business flows out of the generic core.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataHelperContractTest; TestDataFactoryContractTest; TestDataFlowContractTest
 */
@IsTest
public with sharing class ExampleProjectTestDataFactory extends TestDataFactory {
    /**
     * @description Explicit inserted dependencies for the example relationship flow.
     * @instruction Supply saved records or leave null for creation; no eligibility repair occurs.
     * @author Rishikesh Poorun
     * @group Test Data Framework
     * @last modified on 18-09-2026
     * @last modified by Rishikesh Poorun
     * @test TestDataFlowContractTest
     */
    public class AccountContactOptions {
        public Account account;
        public Contact contact;
    }

    /**
     * @description Related records returned by the example flow.
     * @instruction Keep this result local to the arranging method; re-query after TestSetup.
     * @author Rishikesh Poorun
     * @group Test Data Framework
     * @last modified on 18-09-2026
     * @last modified by Rishikesh Poorun
     * @test TestDataFlowContractTest
     */
    public class AccountContactDataSet {
        public Account account;
        public Contact contact;
    }

    /**
     * @description Register the sample object helpers without executing DML.
     * @author Rishikesh Poorun
     * @return New project helper map.
     */
    protected override Map<Schema.SObjectType, SObjectTestDataHelper> registerHelpers() {
        return new Map<Schema.SObjectType, SObjectTestDataHelper>{
            Account.SObjectType => new AccountTestDataHelper(),
            Contact.SObjectType => new ContactTestDataHelper(),
            User.SObjectType => new UserTestDataHelper()
        };
    }

    /**
     * @description Retain static convenience with instance-based coordination.
     * @author Rishikesh Poorun
     * @param options Optional existing Account and Contact dependencies.
     * @return Related Account and Contact, reusing supplied records.
     */
    public static AccountContactDataSet createAccountContactDataSet(AccountContactOptions options) {
        return new ExampleProjectTestDataFactory().provisionAccountContact(options);
    }

    /**
     * @description Resolve inserted dependencies before creating missing records.
     * @author Rishikesh Poorun
     * @param options Optional dependency references; unsaved inputs are rejected.
     * @return Explicit references to the related records.
     */
    private AccountContactDataSet provisionAccountContact(AccountContactOptions options) {
        AccountContactOptions request = options == null ? new AccountContactOptions() : options;
        AccountContactDataSet result = new AccountContactDataSet();
        if (request.account != null) {
            result.account = findAccount(request.account.Id, 'Supplied Account is not accessible.');
        }
        if (request.contact != null) {
            result.contact = findContact(request.contact.Id);
            result.account = resolveParent(result.account, result.contact);
        }
        if (result.account == null) {
            result.account = (Account) resolveHelper(Account.SObjectType).create(null);
        }
        if (result.contact == null) {
            TestRecordOptions contactOptions = new TestRecordOptions();
            contactOptions.fieldValues.put(Contact.AccountId, result.account.Id);
            result.contact = (Contact) resolveHelper(Contact.SObjectType).create(contactOptions);
        }
        return result;
    }


    /**
     * @description Load a supplied Account without creating or repairing it.
     * @author Rishikesh Poorun
     * @param accountId Saved dependency identity.
     * @param missingMessage Context-specific validation message.
     * @return Visible saved Account.
     */
    private Account findAccount(Id accountId, String missingMessage) {
        if (accountId == null) {
            throw new TestDataFrameworkException('Supplied Account must be inserted.');
        }
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accountId];
        if (accounts.isEmpty()) {
            throw new TestDataFrameworkException(missingMessage);
        }
        return accounts[0];
    }

    /**
     * @description Load a Contact with an existing parent reference.
     * @author Rishikesh Poorun
     * @param contactId Saved dependency identity.
     * @return Visible saved Contact with a non-null AccountId.
     */
    private Contact findContact(Id contactId) {
        if (contactId == null) {
            throw new TestDataFrameworkException('Supplied Contact must be inserted.');
        }
        List<Contact> contacts = [SELECT Id, AccountId, LastName FROM Contact WHERE Id = :contactId];
        if (contacts.isEmpty() || contacts[0].AccountId == null) {
            throw new TestDataFrameworkException('Supplied Contact must have an accessible Account.');
        }
        return contacts[0];
    }

    /**
     * @description Resolve the Contact's actual parent or validate supplied relationship.
     * @author Rishikesh Poorun
     * @param account Optional supplied saved Account.
     * @param contact Saved Contact with a parent reference.
     * @return Matching parent without mutation.
     */
    private Account resolveParent(Account account, Contact contact) {
        if (account == null) {
            return findAccount(contact.AccountId, 'Contact Account is not accessible.');
        }
        if (contact.AccountId != account.Id) {
            throw new TestDataFrameworkException('Contact must belong to the supplied Account.');
        }
        return account;
    }
    /**
     * @description Create common non-admin identity and graph for contract tests.
     * @author Rishikesh Poorun
     * @return Inserted user; re-query it in each test using getContractUser.
     */
    public static User createContractSetup() {
        // This sample selects a restricted internal profile by capabilities, never by label.
        List<Profile> profiles = [
            SELECT Id FROM Profile
            WHERE UserType = 'Standard'
                AND PermissionsModifyAllData = false
                AND PermissionsViewAllData = false
            ORDER BY Id LIMIT 1
        ];
        if (profiles.isEmpty()) {
            throw new TestDataFrameworkException('Contract tests require a non-admin internal profile.');
        }
        TestRecordOptions options = new TestRecordOptions();
        options.variant = 'internal';
        options.fieldValues.put(User.ProfileId, profiles[0].Id);
        User testUser = (User) new UserTestDataHelper().create(options);
        System.runAs(testUser) {
            createAccountContactDataSet(null);
        }
        return testUser;
    }

    /**
     * @description Re-query the isolated setup user without a static Id cache.
     * @author Rishikesh Poorun
     * @return Exactly one non-admin fixture user; ambiguous matches fail explicitly.
     */
    public static User getContractUser() {
        List<User> users = [
            SELECT Id, Profile.PermissionsModifyAllData, Profile.PermissionsViewAllData
            FROM User WHERE Alias = 'tdfuser' AND LastName = 'Framework Contract User'
        ];
        Assert.areEqual(1, users.size(), 'Setup must identify exactly one contract-test user.');
        Assert.isFalse(users[0].Profile.PermissionsModifyAllData, 'Fixture must not be an administrator.');
        Assert.isFalse(users[0].Profile.PermissionsViewAllData, 'Fixture must not have broad data visibility.');
        return users[0];
    }
}
