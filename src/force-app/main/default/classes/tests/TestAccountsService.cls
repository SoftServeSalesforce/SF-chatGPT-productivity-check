@IsTest
private class TestAccountsService {
    // Assertation messages
    private static final String ERROR_ACCOUNT_SHOULD_BE_ACTIVE = 'Account field Active__c should be set to Yes';
    // Test data constants
    private static final String ACCOUNT_PHONE_NUMBER_ONE = '1'; 
    private static final String ACCOUNT_PHONE_NUMBER_TWO = '2';
    private static final String CUSTOM_PERMISSION_NAME = 'TestReactivationPermission';
    private static final String CUSTOM_PERMISSION_LABEL = 'Test Reactivation Permission';
    private static final String CUSTOM_PERMISSION_DEVELOPER_NAME = 'Account_AllowReactivate';
    private static final String USER_EMAIL = 'test@example.com.test';
    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        //Verify that instance is null by default.
        AccountsService original = AccountsService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        AccountsService newInstance = AccountsService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }
    
    /**
     * @description testMakeActive_Positive: Test method needed to ensure that
     * 'makeActive' method of 'AccountsService' class sets 'Active__c' field to 'Yes' 
     * when value not provided.
     */
    @IsTest
    private static void testMakeActive_Default() {
        // Setup data.
        Account acct = new Account();
        List<Account> newRecords = new List<Account>{ acct };
        // Execute scenario.
        AccountsService.getInstance().makeActive(newRecords);
        // Verify outcomes.
        Assert.areEqual(Constants.ACCOUNT_ACTIVE_PICKLIST_YES, acct.Active__c, ERROR_ACCOUNT_SHOULD_BE_ACTIVE);
    }

    /**
     * @description testMakeActive_Positive: Test method needed to ensure that
     * 'makeActive' method of 'AccountsService' class sets 'Active__c' field to 'Yes' 
     * when it set to 'No'.
     */
    @IsTest
    private static void testMakeActive_Negative() {
        // Setup data.
        Account acct = new Account(
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );
        List<Account> newRecords = new List<Account>{ acct };
        // Execute scenario.
        AccountsService.getInstance().makeActive(newRecords);
        // Verify outcomes.
        Assert.areEqual(Constants.ACCOUNT_ACTIVE_PICKLIST_YES, acct.Active__c, ERROR_ACCOUNT_SHOULD_BE_ACTIVE);
    }

    /**
     * @description testMakeActive_Positive: Test method needed to ensure that
     * 'makeActive' method of 'AccountsService' class not override 'Active__c' field 
     * to any other value when it set to 'Yes'.
     */
    @IsTest
    private static void testMakeActive_Positive() {
        // Setup data.
        Account acct = new Account(
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );
        List<Account> newRecords = new List<Account>{ acct };
        // Execute scenario.
        AccountsService.getInstance().makeActive(newRecords);
        // Verify outcomes
        Assert.areEqual(Constants.ACCOUNT_ACTIVE_PICKLIST_YES, acct.Active__c, ERROR_ACCOUNT_SHOULD_BE_ACTIVE);
    }

    /**
     * @description testPreventUpdatesOnInactive_Positive: Test method needed to ensure
     * that 'preventUpdatesOnInactive' method of 'AccountsService' class does not prevent 
     * active accounts from changes.
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Positive() {
        // Setup data.
        Id acctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        Account oldAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        List<Account> newRecords = new List<Account>{ newAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ acctId => oldAcct };
        // Execute scenario.
        AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        // Verify outcomes.
        Assert.isFalse(newAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
    }

    /**
     * @description testPreventUpdatesOnInactive_Negative: Test method needed to ensure
     * that 'preventUpdatesOnInactive' method of 'AccountsService' class prevent inactive
     * Accounts from changes
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Negative() {
        // Setup data.
        Id acctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        Account oldAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        List<Account> newRecords = new List<Account>{ newAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ acctId => oldAcct };
        // Execute scenario.
        AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        // Verify outcomes.
        Assert.isTrue(newAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newAcct.getErrors();
        for (Database.Error error : errors) {
            Assert.areEqual(
                Constants.ERROR_CANT_UPDATE_INACTIVE_ACCOUNT,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }
    
    /**
     * @description testPreventUpdatesOnInactive_Mixed: Test method needed to ensure
     * that 'preventUpdatesOnInactive' method of 'AccountsService' class
     * adds expected error only when necessary.
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Mixed() {
        // Setup data.
        Id negativeAcctId = fflib_IDGenerator.generate(Account.SObjectType);
        Id positiveAcctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newNegativeAcct = new Account(
            Id = negativeAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        Account oldNegativeAcct = new Account(
            Id = negativeAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );
        Account newPositiveAcct = new Account(
            Id = positiveAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        Account oldPositiveAcct = new Account(
            Id = positiveAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        List<Account> newRecords = new List<Account>{ newNegativeAcct, newPositiveAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ 
            negativeAcctId => oldNegativeAcct,
            positiveAcctId => oldPositiveAcct 
        };
        // Execute scenario.
        AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        // Verify outcomes.
        Assert.isFalse(newPositiveAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
        Assert.isTrue(newNegativeAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newNegativeAcct.getErrors();
        for (Database.Error error : errors) {
            Assert.areEqual(
                Constants.ERROR_CANT_UPDATE_INACTIVE_ACCOUNT,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }

    /**
     * @description testPreventUpdatesOnInactive_Negative: Test method needed to ensure
     * that 'preventUpdatesOnInactive' method of 'AccountsService' class prevent inactive
     * Accounts from changind Active field back to 'Yes' without permission.
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Negative_ActiveFieldUpdate() {
        // Setup data.
        Id acctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAcct = new Account(
            Id = acctId,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        Account oldAcct = new Account(
            Id = acctId,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        List<Account> newRecords = new List<Account>{ newAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ acctId => oldAcct };
        // Execute scenario.
        AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        // Verify outcomes.
        Assert.isTrue(newAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newAcct.getErrors();
        for (Database.Error error : errors) {
            Assert.areEqual(
                Constants.ERROR_CANT_UPDATE_INACTIVE_ACCOUNT,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }

    /**
     * @description testPreventUpdatesOnInactive_Negative_WhenPermissionAssigned: Test method needed to ensure
     * that 'preventUpdatesOnInactive' method of 'AccountsService' class prevent inactive
     * Accounts from changes even if user has permission to reactivate accounts.
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Negative_WhenPermissionAssigned() {
        // Setup data.
        Id acctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        Account oldAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        List<Account> newRecords = new List<Account>{ newAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ acctId => oldAcct };
        // Execute scenario.
        User testUser = TestDataFactory.getInstance().createUser(USER_EMAIL);
        System.runAs(testUser) {
            activateAccountReactivatePermission(testUser.Id);
        }
        Test.startTest();
        System.runAs(testUser) {
            AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        }
        Test.stopTest();
        // Verify outcomes.
        Assert.isTrue(newAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newAcct.getErrors();
        for (Database.Error error : errors) {
            Assert.areEqual(
                Constants.ERROR_CANT_UPDATE_INACTIVE_ACCOUNT,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }

    /**
     * @description testPreventUpdatesOnInactive_Negative_WhenPermissionAssigned: Test method needed to ensure
     * that 'preventUpdatesOnInactive' method of 'AccountsService' class allows inactive
     * Accounts changes if Active field is going to be set to 'Yes' with other field update
     * and user has permission to reactivate accounts.
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Positive_WhenPermissionAssigned() {
        // Setup data.
        Id acctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        Account oldAcct = new Account(
            Id = acctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        List<Account> newRecords = new List<Account>{ newAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ acctId => oldAcct };
        // Execute scenario.
        User testUser = TestDataFactory.getInstance().createUser(USER_EMAIL);
        System.runAs(testUser) {
            activateAccountReactivatePermission(testUser.Id);
        }
        Test.startTest();
        System.runAs(testUser) {
            AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        }
        Test.stopTest();
        // Verify outcomes.
        Assert.isFalse(newAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
        
    }

    /**
     * @description testPreventUpdatesOnInactive_Negative_WhenPermissionAssigned: Test method needed to ensure
     * that 'preventUpdatesOnInactive' method of 'AccountsService' class allows inactive
     * Accounts changes if Active field is going to be set to 'Yes' with only Active field update
     * and user has permission to reactivate accounts.
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Positive_ActiveFieldUpdate_WhenPermissionAssigned() {
        // Setup data.
        Id acctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAcct = new Account(
            Id = acctId,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        Account oldAcct = new Account(
            Id = acctId,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        List<Account> newRecords = new List<Account>{ newAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ acctId => oldAcct };
        // Execute scenario.
        User testUser = TestDataFactory.getInstance().createUser(USER_EMAIL);
        System.runAs(testUser) {
            activateAccountReactivatePermission(testUser.Id);
        }
        Test.startTest();
        System.runAs(testUser) {
            AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        }
        Test.stopTest();
        // Verify outcomes.
        Assert.isFalse(newAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
        
    }
    /**
     * @description testPreventUpdatesOnInactive_Negative_WhenPermissionAssigned: 
     * Test method needed to ensure that 'preventUpdatesOnInactive' 
     * method of 'AccountsService' class adds error only when necessary even if
     * user has permission to reactivate accounts.
     */
    @IsTest
    private static void testPreventUpdatesOnInactive_Mixed_WhenPermissionAssigned() {
        // Setup data.
        Id negativeAcctId = fflib_IDGenerator.generate(Account.SObjectType);
        Id positiveAcctId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newNegativeAcct = new Account(
            Id = negativeAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );

        Account oldNegativeAcct = new Account(
            Id = negativeAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO
        );
        Account newPositiveAcct = new Account(
            Id = positiveAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_TWO,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        Account oldPositiveAcct = new Account(
            Id = positiveAcctId,
            Phone = ACCOUNT_PHONE_NUMBER_ONE,
            Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES
        );

        List<Account> newRecords = new List<Account>{ newNegativeAcct, newPositiveAcct };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ 
            negativeAcctId => oldNegativeAcct,
            positiveAcctId => oldPositiveAcct 
        };
        // Execute scenario.
        User testUser = TestDataFactory.getInstance().createUser(USER_EMAIL);
        System.runAs(testUser) {
            activateAccountReactivatePermission(testUser.Id);
        }
        Test.startTest();
        System.runAs(testUser) {
            AccountsService.getInstance().preventUpdatesOnInactive(newRecords, oldRecords);
        }
        Test.stopTest();
        // Verify outcomes.
        Assert.isFalse(newPositiveAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
        Assert.isTrue(newNegativeAcct.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newNegativeAcct.getErrors();
        for (Database.Error error : errors) {
            Assert.areEqual(
                Constants.ERROR_CANT_UPDATE_INACTIVE_ACCOUNT,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }

    private static void activateAccountReactivatePermission(Id userId) {
        PermissionSet ps = new PermissionSet(
            Name = CUSTOM_PERMISSION_NAME,
            Label = CUSTOM_PERMISSION_LABEL
        );
        insert ps;
        Id entityId = [SELECT Id FROM CustomPermission WHERE DeveloperName =: CUSTOM_PERMISSION_DEVELOPER_NAME LIMIT 1].Id;
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = entityId
        );

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = ps.Id
        );

        insert new List<SObject>{ sea, psa };
    }
}