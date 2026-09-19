/**
 * @description       : Contract coverage for TestDataFactory and AbstractSObjectTestDataHelper validation.
 * @instruction       : Preserve registry errors and helper contracts; execute every scenario as the shared non-admin user.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataFactoryContractTest
 */
@IsTest
private with sharing class TestDataFactoryContractTest {
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
     * @description Verify lazy initialization and helper reuse.
     * @scenario Resolve a registered helper twice.
     * @expectedResults Registration runs once after construction.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void registryLoadsOnce() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ProbeFactory factory = new ProbeFactory();
            Assert.areEqual(0, factory.calls, 'Base construction must not call overridable hooks.');
            SObjectTestDataHelper first = factory.lookup(Account.SObjectType);
            SObjectTestDataHelper second = factory.lookup(Account.SObjectType);
            Assert.areEqual(Account.SObjectType, first.getSObjectType(), 'Resolve the registered object.');
            Assert.isTrue(first === second, 'Stateless helper instance may be reused.');
            Assert.areEqual(1, factory.calls, 'Registration should initialize once.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify missing helper errors.
     * @scenario Resolve an unregistered Contact helper.
     * @expectedResults Exception names the requested object.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectUnknownType() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            try {
                new ProbeFactory().lookup(Contact.SObjectType);
                Assert.fail('Unknown helper must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('No helper registered for Contact.', failure.getMessage(), 'Identify missing registration.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify null resolution errors.
     * @scenario Resolve a null object type.
     * @expectedResults A descriptive framework exception.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullType() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            try {
                new ProbeFactory().lookup(null);
                Assert.fail('Null type must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Requested SObject type must not be null.', failure.getMessage(), 'Identify invalid lookup.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify registration identity consistency.
     * @scenario Register the Account helper under Contact.
     * @expectedResults Reject the registry before any fixture is built.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectMismatchedRegistration() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ProbeFactory factory = new ProbeFactory();
            factory.registrations = new Map<Schema.SObjectType, SObjectTestDataHelper>{Contact.SObjectType => new AccountTestDataHelper()};
            try {
                factory.lookup(Contact.SObjectType);
                Assert.fail('Mismatched registration must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Helper registration must match its SObject type.', failure.getMessage(), 'Validate identity.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify null registry handling.
     * @scenario A project hook returns null.
     * @expectedResults Framework error without publishing a registry.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullRegistrationMap() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ProbeFactory factory = new ProbeFactory();
            factory.registrations = null;
            try {
                factory.lookup(Account.SObjectType);
                Assert.fail('Null registry must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Helper registrations must not be null.', failure.getMessage(), 'Explain missing map.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify registration values.
     * @scenario Register a null helper instance.
     * @expectedResults Explicit identity validation failure.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullHelper() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ProbeFactory factory = new ProbeFactory();
            factory.registrations.put(Account.SObjectType, null);
            try {
                factory.lookup(Account.SObjectType);
                Assert.fail('Null helper must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Helper registration must match its SObject type.', failure.getMessage(), 'Reject null helper.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify registration keys.
     * @scenario Register a helper with a null object key.
     * @expectedResults Explicit identity validation failure.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullRegistrationKey() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ProbeFactory factory = new ProbeFactory();
            factory.registrations.put(null, new AccountTestDataHelper());
            try {
                factory.lookup(Account.SObjectType);
                Assert.fail('Null key must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Helper registration must match its SObject type.', failure.getMessage(), 'Reject null key.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify recursion protection and recovery.
     * @scenario A hook resolves recursively then is corrected.
     * @expectedResults First lookup fails; retry publishes valid registrations.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void retryFailedInitialization() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            ProbeFactory factory = new ProbeFactory();
            factory.recursive = true;
            try {
                factory.lookup(Account.SObjectType);
                Assert.fail('Recursive registration must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Registration must not resolve helpers recursively.', failure.getMessage(), 'Explain recursion.');
            }
            factory.recursive = false;
            Assert.areEqual(Account.SObjectType, factory.lookup(Account.SObjectType).getSObjectType(), 'Retry must recover.');
            Assert.areEqual(2, factory.calls, 'Failed initialization must not cache partial state.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify hook result type.
     * @scenario An Account helper returns a Contact.
     * @expectedResults Reject before applying fields or inserting.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectWrongBuiltType() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            BrokenHelper helper = new BrokenHelper();
            helper.record = new Contact();
            try {
                helper.build(null);
                Assert.fail('Wrong built type must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Helper must return Account.', failure.getMessage(), 'Validate returned object type.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify null hook result.
     * @scenario A helper returns null.
     * @expectedResults Reject with a contract error.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullBuiltRecord() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            try {
                new BrokenHelper().build(null);
                Assert.fail('Null built record must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Helper must return Account.', failure.getMessage(), 'Validate null hook result.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify helper identity.
     * @scenario A helper reports no object type.
     * @expectedResults Reject before running its construction hook.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullHelperIdentity() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            BrokenHelper helper = new BrokenHelper();
            helper.objectType = null;
            try {
                helper.build(null);
                Assert.fail('Null helper type must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Helper must declare an SObject type.', failure.getMessage(), 'Validate helper identity.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify hooks cannot turn create into update.
     * @scenario A helper returns a saved Account.
     * @expectedResults Reject without DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectSavedHookRecord() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            BrokenHelper helper = new BrokenHelper();
            helper.record = [SELECT Id FROM Account LIMIT 1];
            try {
                helper.create(null);
                Assert.fail('Saved hook records must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Build must return an unsaved record.', failure.getMessage(), 'Preserve insert-only semantics.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'Existing records must not be mutated.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify hook request isolation.
     * @scenario A hook changes its copy of field overrides.
     * @expectedResults Original explicit overrides still win.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void hookCannotChangeOverrides() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            BrokenHelper helper = new BrokenHelper();
            helper.record = new Account(Name = 'Hook default');
            helper.changeOptions = true;
            TestRecordOptions options = new TestRecordOptions();
            options.fieldValues.put(Account.Name, 'Caller');
            Account result = (Account) helper.build(options);
            Assert.areEqual('Caller', result.Name, 'Hook must not replace explicit overrides.');
            Assert.areEqual('Caller', options.fieldValues.get(Account.Name), 'Caller request must remain untouched.');
            Test.stopTest();
        }
    }

    /**
     * @description Controllable registry for contract failures.
     * @instruction Use only inside this contract suite.
     * @author Rishikesh Poorun
     * @group Test Data Framework
     * @last modified on 18-09-2026
     * @last modified by Rishikesh Poorun
     * @test TestDataFactoryContractTest
     */
    private class ProbeFactory extends TestDataFactory {
        public Integer calls = 0;
        public Boolean recursive = false;
        public Map<Schema.SObjectType, SObjectTestDataHelper> registrations =
            new Map<Schema.SObjectType, SObjectTestDataHelper>{Account.SObjectType => new AccountTestDataHelper()};

        /**
         * @description Return configured registrations or provoke recursion.
         * @author Rishikesh Poorun
         * @return Test-controlled helper map.
         */
        protected override Map<Schema.SObjectType, SObjectTestDataHelper> registerHelpers() {
            calls++;
            if (recursive) {
                resolveHelper(Account.SObjectType);
            }
            return registrations;
        }

        /**
         * @description Expose protected resolution for contract tests.
         * @author Rishikesh Poorun
         * @param objectType Requested registration key.
         * @return Resolved helper.
         */
        public SObjectTestDataHelper lookup(Schema.SObjectType objectType) {
            return resolveHelper(objectType);
        }
    }

    /**
     * @description Controllable construction hook for contract validation.
     * @instruction Intentionally malformed outputs belong only to these negative tests.
     * @author Rishikesh Poorun
     * @group Test Data Framework
     * @last modified on 18-09-2026
     * @last modified by Rishikesh Poorun
     * @test TestDataFactoryContractTest
     */
    private class BrokenHelper extends AbstractSObjectTestDataHelper {
        public Schema.SObjectType objectType = Account.SObjectType;
        public SObject record;
        public Boolean changeOptions = false;

        /**
         * @description Return the configured object identity.
         * @author Rishikesh Poorun
         * @return Test-controlled type, possibly null.
         */
        public override Schema.SObjectType getSObjectType() {
            return objectType;
        }

        /**
         * @description Return the configured record and optionally mutate the hook snapshot.
         * @author Rishikesh Poorun
         * @param options Private hook request.
         * @return Test-controlled record.
         */
        protected override SObject buildDefaults(TestRecordOptions options) {
            if (changeOptions) {
                options.fieldValues.put(Account.Name, 'Hook rewrite');
            }
            return record;
        }
    }
}
