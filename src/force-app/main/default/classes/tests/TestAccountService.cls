@IsTest
private class TestAccountService {
    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        //Verify that instance is null by default.
        AccountService original = AccountService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        AccountService newInstance = AccountService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testSetActiveNewAccounts_Positive: Test method needed to ensure
     * that 'setActiveNewAccounts' method of 'AccountService' class activate an New Accounts
     * in case Active not populated.
     */
    @IsTest
    private static void testSetActiveNewAccounts_Positive() {
        //Setup data.
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(
            Id = accountId,
            Name = 'Test Account New'
        );
        Account newAccountInactive = new Account(
            Id = accountId,
            Name = 'Test Account New',
            Active__c = Constants.ACCOUNT_STATUS_INACTIVE
        );
        List<Account> newRecords = new List<Account> { newAccount, newAccountInactive };
        //Execute scenario.
        AccountService.getInstance().setActiveNewAccounts(newRecords);
        //Verify outcomes.
        System.assert(!newAccount.hasErrors());
        System.assert(!newAccountInactive.hasErrors());
        System.assertEquals(Constants.ACCOUNT_STATUS_ACTIVE, newAccount.Active__c);
        System.assertEquals(Constants.ACCOUNT_STATUS_ACTIVE, newAccountInactive.Active__c);
    }

    /**
     * @description testPreventUpdateInactiveAccounts_Positive: Test method needed to ensure
     * that 'preventUpdateInactiveAccounts' method of 'AccountService' class does not prevent 
     * changing Active Accounts.
     */
    @IsTest
    private static void testPreventUpdateInactiveAccounts_Positive() {
        //Setup data.
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(
            Id = accountId,
            Name = 'Test Account New',
            Active__c = Constants.ACCOUNT_STATUS_ACTIVE
        );
        Account oldAccount = new Account(
            Id = accountId,
            Name = 'Test Account Old',
            Active__c = Constants.ACCOUNT_STATUS_ACTIVE
        );
        List<Account> newRecords = new List<Account> { newAccount };
        Map<Id,Account> oldRecords = new Map<Id,Account> { accountId => oldAccount }; 
        //Execute scenario.
        AccountService.getInstance().preventUpdateInactiveAccounts(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(!newAccount.hasErrors());
    }

    /**
     * @description testPreventUpdateInactiveAccounts_Negative: Test method needed to ensure
     * that 'preventUpdateInactiveAccounts' method of 'AccountService' class prevent update Inactive Account
     * by adding expected error.
     */
    @IsTest
    private static void testPreventUpdateInactiveAccounts_Negative() {
        //Setup data.
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(
            Id = accountId,
            Name = 'Test Account New',
            Active__c = Constants.ACCOUNT_STATUS_ACTIVE
        );
        Account oldAccount = new Account(
            Id = accountId,
            Name = 'Test Account Old',
            Active__c = Constants.ACCOUNT_STATUS_INACTIVE
        );
        List<Account> newRecords = new List<Account> { newAccount };
        Map<Id,Account> oldRecords = new Map<Id,Account> { accountId => oldAccount }; 
        //Execute scenario.
        AccountService.getInstance().preventUpdateInactiveAccounts(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(newAccount.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newAccount.getErrors();
        for (Database.Error error : errors) {
            System.assertEquals(
                Constants.ERROR_UPDATE_INACTIVE_ACCOUNT,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }

    /**
     * @description testPreventUpdateInactiveAccounts_Mixed: Test method needed to
     * ensure that 'preventUpdateInactiveAccounts' method of 'AccountService' class
     * adds expected error only when necessary.
     */
    @IsTest
    private static void testPreventUpdateInactiveAccounts_Mixed() {
        //Setup data.
        Id accountIdPositive = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountIdNegative = fflib_IDGenerator.generate(Account.SObjectType);

        Account newAccountPositive = new Account(
            Id = accountIdPositive,
            Name = 'Test Account New',
            Active__c = Constants.ACCOUNT_STATUS_ACTIVE
        );
        Account oldAccountPositive = new Account(
            Id = accountIdPositive,
            Name = 'Test Account Old',
            Active__c = Constants.ACCOUNT_STATUS_ACTIVE
        );

        Account newAccountNegative = new Account(
            Id = accountIdNegative,
            Name = 'Test Account New',
            Active__c = Constants.ACCOUNT_STATUS_ACTIVE
        );
        Account oldAccountNegative = new Account(
            Id = accountIdNegative,
            Name = 'Test Account Old',
            Active__c = Constants.ACCOUNT_STATUS_INACTIVE
        );

        List<Account> newRecords = new List<Account> { 
            newAccountPositive,
            newAccountNegative
        };
        Map<Id,Account> oldRecords = new Map<Id,Account> {
            accountIdPositive => oldAccountPositive,
            accountIdNegative => oldAccountNegative
        }; 
        //Execute scenario.
        AccountService.getInstance().preventUpdateInactiveAccounts(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(!newAccountPositive.hasErrors(), Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR);
        System.assert(newAccountNegative.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newAccountNegative.getErrors();
        for (Database.Error error : errors) {
            System.assertEquals(
                Constants.ERROR_UPDATE_INACTIVE_ACCOUNT,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }

    /**
     * @description setActiveAllUndefinedAccounts test method needed to ensure that
     * 'setActiveAllUndefinedAccounts' method of 'AccountService' class activate an Undefined Accounts
     */
    @IsTest
    private static void testSetActiveAllUndefinedAccounts_Positive() {
        //Setup data.
        Account newAccountUndefined = new Account(
            Name = 'Test Account Undefined'
        );
        insert newAccountUndefined;
        //Execute scenario.
        AccountService.getInstance().setActiveAllUndefinedAccounts();
        //Verify outcomes.
        System.assert(!newAccountUndefined.hasErrors());
        Account account = [SELECT Id, Name, Active__c FROM Account WHERE Id = :newAccountUndefined.Id];
        System.assertEquals(Constants.ACCOUNT_STATUS_ACTIVE, account.Active__c);
    }
}