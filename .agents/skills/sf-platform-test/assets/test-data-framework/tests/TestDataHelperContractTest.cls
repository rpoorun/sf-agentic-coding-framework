/**
 * @description       : Contract coverage for options, abstract helper, Account/Contact/User examples.
 * @instruction       : Run in a minimal org; extend acceptance tests for project automation without weakening these contracts.
 * @author            : Rishikesh Poorun
 * @group             : Test Data Framework
 * @last modified on  : 18-09-2026
 * @last modified by  : Rishikesh Poorun
 * @test              : TestDataHelperContractTest
 */
@IsTest
private with sharing class TestDataHelperContractTest {
    /**
     * @description Create the shared user and related Account/Contact fixture.
     * @scenario Each method re-queries the setup user and runs in that context.
     * @expectedResults One non-admin user and one related graph are available.
     * @author Rishikesh Poorun
     */
    @TestSetup
    static void setupData() {
        ExampleProjectTestDataFactory.createContractSetup();
    }

    /**
     * @description Verify the default unsaved contract.
     * @scenario Build an Account with null options.
     * @expectedResults Neutral defaults, no Id, and no DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void buildNullOptions() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Integer beforeDml = Limits.getDmlStatements();
            Account result = (Account) new AccountTestDataHelper().build(null);
            Assert.areEqual('Test Account 1', result.Name, 'Null options must use fresh defaults.');
            Assert.isNull(result.Id, 'Build must not insert.');
            Assert.areEqual(beforeDml, Limits.getDmlStatements(), 'Build must perform no DML.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify independent ordered requests.
     * @scenario Build distinct overrides with a null middle request.
     * @expectedResults One unsaved record per request in the original order.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void buildManyInOrder() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions first = new TestRecordOptions();
            first.fieldValues.put(Account.Name, 'First');
            TestRecordOptions last = new TestRecordOptions();
            last.sequence = 3;
            List<SObject> results = new AccountTestDataHelper().buildMany(new List<TestRecordOptions>{first, null, last});
            Assert.areEqual(3, results.size(), 'Every request must produce a record.');
            Assert.areEqual('First', results[0].get(Account.Name), 'First override must be preserved.');
            Assert.areEqual('Test Account 1', results[1].get(Account.Name), 'Null elements use defaults.');
            Assert.areEqual('Test Account 3', results[2].get(Account.Name), 'Sequence must be preserved.');
            for (SObject result : results) {
                Assert.isNull(result.Id, 'Every built record must be unsaved.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'Bulk build must not perform DML.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify null-list validation.
     * @scenario Pass a null buildMany request list.
     * @expectedResults A framework exception is raised before DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullBuildList() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            try {
                new AccountTestDataHelper().buildMany(null);
                Assert.fail('Null request list must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Request list must not be null.', failure.getMessage(), 'Explain invalid request.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'Invalid requests must not write.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify empty build behavior.
     * @scenario Supply an empty request list.
     * @expectedResults An empty result and zero DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void buildEmptyList() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            List<SObject> results = new AccountTestDataHelper().buildMany(new List<TestRecordOptions>());
            Assert.areEqual(0, results.size(), 'Empty requests must return an empty list.');
            Assert.areEqual(0, Limits.getDmlStatements(), 'Empty builds must not write.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify empty persistence behavior.
     * @scenario Supply an empty createMany request list.
     * @expectedResults An empty result and zero DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void createEmptyList() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            List<SObject> results = new AccountTestDataHelper().createMany(new List<TestRecordOptions>());
            Assert.areEqual(0, results.size(), 'Empty insert must return an empty list.');
            Assert.areEqual(0, Limits.getDmlStatements(), 'Empty insert must skip DML.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify createMany delegates list validation.
     * @scenario Pass a null createMany request list.
     * @expectedResults A framework exception without persistence.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullCreateList() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            try {
                new AccountTestDataHelper().createMany(null);
                Assert.fail('Null create requests must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Request list must not be null.', failure.getMessage(), 'Preserve contract error.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'No write should be attempted.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify defaults, variant, and explicit-null precedence.
     * @scenario Clear Description supplied by the described Account variant.
     * @expectedResults Explicit null remains null while other defaults survive.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void variantAndNullOverride() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.variant = 'described';
            Account variantOnly = (Account) new AccountTestDataHelper().build(options);
            Assert.areEqual('Sample variant', variantOnly.Description, 'Selected variant must apply.');
            options.fieldValues.put(Account.Description, null);
            Account overridden = (Account) new AccountTestDataHelper().build(options);
            Assert.isNull(overridden.Description, 'Explicit null must win over the variant.');
            Assert.areEqual('Test Account 1', overridden.Name, 'Unchanged defaults must survive.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify unsupported variants fail.
     * @scenario Use an unregistered Account variant.
     * @expectedResults A descriptive framework exception without fallback.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectUnsupportedVariant() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.variant = 'unknown';
            try {
                new AccountTestDataHelper().build(options);
                Assert.fail('Unsupported variant must not fall back.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Unsupported Account variant: unknown', failure.getMessage(), 'Identify the bad variant.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify field ownership validation.
     * @scenario Supply Contact.LastName to the Account helper.
     * @expectedResults Reject before DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectCrossObjectField() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.fieldValues.put(Contact.LastName, 'Wrong object');
            try {
                new AccountTestDataHelper().create(options);
                Assert.fail('A field from another object must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Override field must belong to Account.', failure.getMessage(), 'Explain field ownership.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'Invalid field must be rejected before insertion.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify malformed override keys.
     * @scenario Use a null field token.
     * @expectedResults Framework exception before DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectNullField() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.fieldValues.put(null, 'Invalid');
            try {
                new AccountTestDataHelper().build(options);
                Assert.fail('Null override field must fail.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Override field must belong to Account.', failure.getMessage(), 'Explain invalid token.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Protect insert-only semantics.
     * @scenario Override Id with an existing setup Account Id.
     * @expectedResults Reject without updating the existing record.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectExistingId() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Account seed = [SELECT Id, Name FROM Account LIMIT 1];
            TestRecordOptions options = new TestRecordOptions();
            options.fieldValues.put(Account.Id, seed.Id);
            try {
                new AccountTestDataHelper().create(options);
                Assert.fail('An existing Id must not become an update.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Build cannot accept an existing record Id.', failure.getMessage(), 'Explain reuse boundary.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'No update or insert should occur.');
            Test.stopTest();
        }
    }

    /**
     * @description Preserve native invalid-type failures.
     * @scenario Pass text to Account.NumberOfEmployees.
     * @expectedResults SObjectException propagates without a DML attempt.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectWrongValueType() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.fieldValues.put(Account.NumberOfEmployees, 'not-an-integer');
            try {
                new AccountTestDataHelper().build(options);
                Assert.fail('Invalid Apex field type must fail.');
            } catch (SObjectException failure) {
                Assert.isNotNull(failure.getMessage(), 'Native type failure must retain its diagnostic.');
            }
            Assert.areEqual(0, Limits.getDmlStatements(), 'Type rejection occurs before persistence.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify record and request isolation.
     * @scenario Reuse options then mutate one returned record.
     * @expectedResults Later records and the original override map remain unchanged.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void independentRequestsAndRecords() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.fieldValues.put(Account.Name, 'Caller value');
            AccountTestDataHelper helper = new AccountTestDataHelper();
            Account first = (Account) helper.build(options);
            Account second = (Account) helper.build(options);
            Assert.isTrue(first !== second, 'Reused helpers must return distinct references.');
            first.Name = 'Changed';
            Assert.areEqual('Caller value', second.Name, 'Records must not share mutable state.');
            Assert.areEqual('Caller value', options.fieldValues.get(Account.Name), 'Caller options must be unchanged.');
            Assert.areEqual(1, options.fieldValues.size(), 'No defaults may leak into caller overrides.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify helper reuse after persistence.
     * @scenario Create then build on the same helper instance.
     * @expectedResults The later build is unsaved and does not perform additional DML.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void buildAfterCreateIsFresh() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            AccountTestDataHelper helper = new AccountTestDataHelper();
            Account saved = (Account) helper.create(null);
            Integer beforeDml = Limits.getDmlStatements();
            Account unsaved = (Account) helper.build(null);
            Assert.isNotNull(saved.Id, 'First call must persist.');
            Assert.isNull(unsaved.Id, 'Build must not reuse the saved record.');
            Assert.isTrue(saved !== unsaved, 'Do not cache fixture record instances.');
            Assert.areEqual(beforeDml, Limits.getDmlStatements(), 'Build must remain DML-free after create.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify options snapshot defaults.
     * @scenario Copy options whose map and sequence are null.
     * @expectedResults Fresh default members without mutating the source.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void copyNullableMembers() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.fieldValues = null;
            options.sequence = null;
            TestRecordOptions snapshot = TestRecordOptions.copyOf(options);
            snapshot.fieldValues.put(Account.Name, 'Local');
            Assert.areEqual(1, snapshot.sequence, 'Null sequence must use the default.');
            Assert.isNull(options.fieldValues, 'Source map must remain null.');
            Assert.isNull(options.sequence, 'Source sequence must remain null.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify single-record persistence delegation.
     * @scenario Create with null options.
     * @expectedResults One inserted Account is returned.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void createSingleRecord() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Integer beforeCount = [SELECT COUNT() FROM Account];
            Account result = (Account) new AccountTestDataHelper().create(null);
            Assert.isNotNull(result.Id, 'Create must return an inserted record.');
            Assert.areEqual(beforeCount + 1, [SELECT COUNT() FROM Account], 'Create must insert exactly one fixture.');
            Assert.areEqual(1, Limits.getDmlStatements(), 'Minimal-org helper insert uses one DML statement.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify bulk insert and request correspondence.
     * @scenario Insert 251 independently named Accounts.
     * @expectedResults All records inserted in order and setup data unchanged.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void createBulkRecords() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Account seed = [SELECT Id, Name FROM Account LIMIT 1];
            List<TestRecordOptions> requests = new List<TestRecordOptions>();
            for (Integer index = 0; index < 251; index++) {
                TestRecordOptions request = new TestRecordOptions();
                request.fieldValues.put(Account.Name, 'Bulk fixture ' + index);
                requests.add(request);
            }
            List<SObject> results = new AccountTestDataHelper().createMany(requests);
            Assert.areEqual(1, Limits.getDmlStatements(), 'Minimal-org bulk helper uses one insert.');
            Assert.areEqual(251, results.size(), 'All requests must be inserted.');
            Map<Id, Account> persisted = new Map<Id, Account>([SELECT Id, Name FROM Account]);
            for (Integer index = 0; index < results.size(); index++) {
                Assert.isNotNull(results[index].Id, 'Every result must have an Id.');
                Assert.areEqual('Bulk fixture ' + index, results[index].get(Account.Name), 'Return order must match requests.');
                Assert.areEqual('Bulk fixture ' + index, persisted.get(results[index].Id).Name, 'Persisted values must match each request.');
            }
            Assert.areEqual(252, [SELECT COUNT() FROM Account], 'Setup plus bulk fixtures must be present.');
            Assert.areEqual(seed.Name, [SELECT Name FROM Account WHERE Id = :seed.Id].Name, 'Seed record must remain unchanged.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify invalid business data is preserved and rolled back.
     * @scenario Insert one valid request and one with a null required Name.
     * @expectedResults Native DmlException and no partial fixture insertion.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void propagateAllOrNoneFailure() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Integer beforeCount = [SELECT COUNT() FROM Account];
            TestRecordOptions valid = new TestRecordOptions();
            valid.fieldValues.put(Account.Name, 'All-or-none valid fixture');
            TestRecordOptions invalid = new TestRecordOptions();
            invalid.fieldValues.put(Account.Name, null);
            try {
                new AccountTestDataHelper().createMany(new List<TestRecordOptions>{valid, invalid});
                Assert.fail('Missing required Name must not be repaired.');
            } catch (DmlException failure) {
                Assert.areEqual(1, failure.getNumDml(), 'Only the invalid request must fail.');
                Assert.areEqual(1, failure.getDmlIndex(0), 'Failure must identify the second request.');
                Assert.areEqual(StatusCode.REQUIRED_FIELD_MISSING, failure.getDmlStatusCode(0), 'Preserve required-field failure.');
                Assert.isTrue(failure.getDmlFields(0).contains('Name'), 'Failure must identify the null Name.');
            }
            Assert.areEqual(beforeCount, [SELECT COUNT() FROM Account], 'All-or-none failure must leave no partial records.');
            Test.stopTest();
        }
    }

    /**
     * @description Verify User helper has no implicit access selection.
     * @scenario Build two internal Users.
     * @expectedResults Distinct usernames and no automatic profile or permission grants.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void userDefaultsAndUniqueness() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            User first = (User) new UserTestDataHelper().build(null);
            User second = (User) new UserTestDataHelper().build(null);
            Assert.areNotEqual(first.Username, second.Username, 'Usernames must be unique across calls.');
            Assert.isNull(first.ProfileId, 'Flow must choose the profile explicitly.');
            Assert.isNull(first.Id, 'User build must remain unsaved.');
            Assert.areEqual(0, Limits.getDmlStatements(), 'User build must not assign access.');
            Test.stopTest();
        }
    }

    /**
     * @description Prevent substituting a different external persona.
     * @scenario Request a Partner variant from the internal-only sample.
     * @expectedResults Explicit unsupported variant error.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void rejectExternalUserVariant() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            TestRecordOptions options = new TestRecordOptions();
            options.variant = 'partner';
            try {
                new UserTestDataHelper().build(options);
                Assert.fail('Sample helper must not silently substitute an internal user.');
            } catch (TestDataFrameworkException failure) {
                Assert.areEqual('Unsupported User variant: partner', failure.getMessage(), 'Identify unsupported persona.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Verify object helper and flow separation.
     * @scenario Build a Contact without an Account override.
     * @expectedResults No Account is created and no DML occurs.
     * @author Rishikesh Poorun
     */
    @IsTest
    static void contactBuildHasNoDependencies() {
        System.runAs(ExampleProjectTestDataFactory.getContractUser()) {
            Test.startTest();
            Contact result = (Contact) new ContactTestDataHelper().build(null);
            Assert.isNull(result.AccountId, 'Helper must not invent a parent.');
            Assert.isNull(result.Id, 'Contact must remain unsaved.');
            Assert.areEqual(0, Limits.getDmlStatements(), 'Dependency creation belongs to flows.');
            Test.stopTest();
        }
    }

}
