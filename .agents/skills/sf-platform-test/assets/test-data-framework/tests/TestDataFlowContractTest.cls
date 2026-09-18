/**
 * @description       : Contract coverage for the ExampleProjectTestDataFactory Account/Contact flow.
 * @instruction       : Preserve dependency validation and reuse; execute every scenario as the shared non-admin user.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataFlowContractTest
 */
@IsTest
private with sharing class TestDataFlowContractTest {
    /**
     * @description Build shared persona and relationship fixtures.
     * @scenario Re-query fixtures independently in every method.
     * @expectedResults Non-admin user plus one Account/Contact graph.
     * @author Rishikesh Poorun
     */
    @TestSetup
    static void setupData() {
        ExampleProjectTestDataFactory.createContractSetup();
    }

    /**
     * @description Verify the complete example flow.
     * @scenario Create without supplied dependencies.
     * @expectedResults Exactly one new linked Account and Contact.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void createRelatedGraph() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Integer beforeAccounts = [SELECT COUNT() FROM Account];
            Integer beforeContacts = [SELECT COUNT() FROM Contact];
            ExampleProjectTestDataFactory.AccountContactDataSet result = ExampleProjectTestDataFactory.createAccountContactDataSet(null);
            Assert.isNotNull(result.account.Id, 'Account must be inserted.');
            Assert.areEqual(result.account.Id, result.contact.AccountId, 'Contact must reference the created Account.');
            Assert.areEqual(beforeAccounts + 1, [SELECT COUNT() FROM Account], 'Create one Account.');
            Assert.areEqual(beforeContacts + 1, [SELECT COUNT() FROM Contact], 'Create one Contact.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify Account dependency reuse.
     * @scenario Supply a saved Account without a Contact.
     * @expectedResults Only the missing Contact is inserted.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void reuseAccount() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.account = [SELECT Id FROM Account LIMIT 1];
            ExampleProjectTestDataFactory.AccountContactDataSet result = ExampleProjectTestDataFactory.createAccountContactDataSet(options);
            Assert.areEqual(options.account.Id, result.account.Id, 'Reuse the supplied Account.');
            Assert.areEqual(options.account.Id, result.contact.AccountId, 'Link the new Contact to that Account.');
            Assert.areEqual(1, [SELECT COUNT() FROM Account], 'No duplicate Account.');
            Assert.areEqual(2, [SELECT COUNT() FROM Contact], 'Create only the missing Contact.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify Contact-only dependency resolution.
     * @scenario Supply a saved Contact without its Account.
     * @expectedResults Reuse the Contact and its actual parent without DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void reuseContactAndItsParent() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
            ExampleProjectTestDataFactory.AccountContactDataSet result = ExampleProjectTestDataFactory.createAccountContactDataSet(options);
            Assert.areEqual(options.contact.Id, result.contact.Id, 'Reuse supplied Contact.');
            Assert.areEqual(options.contact.AccountId, result.account.Id, 'Resolve its actual parent.');
            Assert.areEqual(0, Limits.getDmlStatements(), 'Reusing the graph must not write.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify complete graph reuse.
     * @scenario Supply matching saved Account and Contact.
     * @expectedResults Return both existing records without DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void reuseBothDependencies() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.account = [SELECT Id FROM Account LIMIT 1];
            options.contact = [SELECT Id FROM Contact LIMIT 1];
            ExampleProjectTestDataFactory.AccountContactDataSet result = ExampleProjectTestDataFactory.createAccountContactDataSet(options);
            Assert.areEqual(options.account.Id, result.account.Id, 'Preserve Account.');
            Assert.areEqual(options.contact.Id, result.contact.Id, 'Preserve Contact.');
            Assert.areEqual(0, Limits.getDmlStatements(), 'Complete reuse must not write.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify relationship consistency.
     * @scenario Supply Contact from a different Account.
     * @expectedResults Reject without changing either relationship.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectMismatchedDependencies() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.account = (Account) new AccountTestDataHelper().create(null);
            options.contact = [SELECT Id, AccountId FROM Contact LIMIT 1];
            Integer beforeDml = Limits.getDmlStatements();
            try {
                ExampleProjectTestDataFactory.createAccountContactDataSet(options);
                Assert.fail('Mismatched dependencies must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Contact must belong to the supplied Account.', failure.getMessage(), 'Explain relationship mismatch.');
            }
            Assert.areEqual(beforeDml, Limits.getDmlStatements(), 'Reject without eligibility repair.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify Account reuse preconditions.
     * @scenario Supply an unsaved Account.
     * @expectedResults Reject before creating any dependencies.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectUnsavedAccount() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.account = (Account) new AccountTestDataHelper().build(null);
            try {
                ExampleProjectTestDataFactory.createAccountContactDataSet(options);
                Assert.fail('Unsaved dependency must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Supplied Account must be inserted.', failure.getMessage(), 'Explain saved-record requirement.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'Invalid dependencies must not write.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify Contact reuse preconditions.
     * @scenario Supply an unsaved Contact.
     * @expectedResults Reject before creating any dependencies.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectUnsavedContact() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.contact = (Contact) new ContactTestDataHelper().build(null);
            try {
                ExampleProjectTestDataFactory.createAccountContactDataSet(options);
                Assert.fail('Unsaved Contact must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Supplied Contact must be inserted.', failure.getMessage(), 'Explain saved-record requirement.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'Do not create unrelated records.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify Account existence preconditions.
     * @scenario Supply a deleted Account.
     * @expectedResults Reject without creating missing dependencies.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectDeletedAccount() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Account dependency = [SELECT Id FROM Account LIMIT 1];
            delete dependency;
            Integer beforeDml = Limits.getDmlStatements();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.account = dependency;
            try {
                ExampleProjectTestDataFactory.createAccountContactDataSet(options);
                Assert.fail('Deleted dependency must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Supplied Account is not accessible.', failure.getMessage(), 'Explain unavailable dependency.');
            }
            Assert.areEqual(beforeDml, Limits.getDmlStatements(), 'Do not replace supplied dependencies.');
            Test.stopTest();
        }
    }


    /**
     * @description Verify Contact existence preconditions.
     * @scenario Supply a deleted Contact.
     * @expectedResults Reject without silently replacing the Contact.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectDeletedContact() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Contact dependency = [SELECT Id FROM Contact LIMIT 1];
            delete dependency;
            Integer beforeDml = Limits.getDmlStatements();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.contact = dependency;
            try {
                ExampleProjectTestDataFactory.createAccountContactDataSet(options);
                Assert.fail('Deleted Contact must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Supplied Contact must have an accessible Account.', failure.getMessage(), 'Explain unavailable dependency.');
            }
            Assert.areEqual(beforeDml, Limits.getDmlStatements(), 'Do not replace deleted Contact.');
            Test.stopTest();
        }
    }


    /**
     * @description Verify relationship preconditions.
     * @scenario Supply an inserted Contact without an Account.
     * @expectedResults Reject without creating a parent or repairing eligibility.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectParentlessContact() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Contact dependency = (Contact) new ContactTestDataHelper().create(null);
            Integer beforeDml = Limits.getDmlStatements();
            ExampleProjectTestDataFactory.AccountContactOptions options = new ExampleProjectTestDataFactory.AccountContactOptions();
            options.contact = dependency;
            try {
                ExampleProjectTestDataFactory.createAccountContactDataSet(options);
                Assert.fail('Parentless Contact must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Supplied Contact must have an accessible Account.', failure.getMessage(), 'Explain missing parent.');
            }
            Assert.areEqual(beforeDml, Limits.getDmlStatements(), 'Do not repair parentless Contact.');
            Test.stopTest();
        }
    }


}
