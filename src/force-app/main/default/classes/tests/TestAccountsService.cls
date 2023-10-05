@IsTest
private class TestAccountsService {
    @IsTest
    private static void testGetInstance() {
        //Verify that instance is null by default.
        AccountsService original = AccountsService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        AccountsService newInstance = AccountsService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    @IsTest
    private static void testActivateAccount_Positive() {
        Account newAccount = new Account(
            Active__c = Constants.NO
        );

        List<Account> newRecords = new List<Account> { newAccount };
        //Execute scenario.
        AccountsService.getInstance().activateAccounts(newRecords);
        //Verify outcomes.
        Assert.isTrue(!newAccount.hasErrors());
        Assert.areEqual(newRecords[0].Active__c, Constants.YES);
    }

    @IsTest
    private static void testPreventUpdateInactiveAccounts_Mixed() {
        Account inactiveAccount = new Account(
            Active__c = Constants.NO,
            Name = 'Inactive Account'
        );
        Account activeAccount = new Account(
            Active__c = Constants.Yes,
            Name = 'Active Account'
        );

        List<Account> newRecords = new List<Account> { inactiveAccount,  activeAccount};
        //Execute scenario.
        AccountsService.getInstance().preventUpdateInactiveAccounts(newRecords);
        //Verify outcomes.
        Assert.isTrue(inactiveAccount.hasErrors());
        Assert.isFalse(activeAccount.hasErrors());
    }
}
