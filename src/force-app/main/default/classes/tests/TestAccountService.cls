@IsTest
private class TestAccountService {
    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        // Verify that instance is null by default.
        AccountService original = AccountService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);

        // Verify that public accessor works.
        AccountService newInstance = AccountService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testPreventInactiveUpdate_Positive: Test method needed to ensure
     * that 'preventInactiveUpdate' method of 'AccountService' class does not prevent 
     * updates for active accounts.
     */
    @IsTest
    private static void testPreventInactiveUpdate_Positive() {
        // Setup data.
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(
            Id = accountId,
            Active__c = Constants.YES // Active Account
        );
        Account oldAccount = new Account(
            Id = accountId,
            Active__c = Constants.YES // Active Account
        );
        List<Account> newRecords = new List<Account> { newAccount };
        Map<Id, Account> oldRecords = new Map<Id, Account> { accountId => oldAccount }; 

        // Execute scenario.
        AccountService.getInstance().preventInactiveUpdate(newRecords, oldRecords);

        // Verify outcomes.
        System.assert(!newAccount.hasErrors());
    }

    /**
     * @description testPreventInactiveUpdate_Negative: Test method needed to ensure
     * that 'preventInactiveUpdate' method of 'AccountService' class prevents updates
     * for inactive accounts by adding expected error.
     */

    @IsTest
    private static void testPreventInactiveUpdate_Negative() {
        // Setup data.
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(
            Id = accountId,
            Active__c = Constants.YES // Active Account
        );
        Account oldAccount = new Account(
            Id = accountId,
            Active__c = Constants.NO // Inactive Account
        );
        List<Account> newRecords = new List<Account> { newAccount };
        Map<Id, Account> oldRecords = new Map<Id, Account> { accountId => oldAccount }; 

        // Execute scenario.
        AccountService.getInstance().preventInactiveUpdate(newRecords, oldRecords);

        // Verify outcomes.
        System.assert(newAccount.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newAccount.getErrors();
        for (Database.Error error : errors) {
            System.assertEquals(
                Constants.ERROR_INACTIVE_ACCOUNT_UPDATE,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }
}