@IsTest
private class TestAccountService {

    @IsTest
    private static void testGetInstance() {
        AccountService original = AccountService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);

        AccountService newInstance = AccountService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    @IsTest
    private static void testCreateNewAccountActive() {
        Account acc = new Account(Name = 'Test');
        List<Account> newRecords = new List<Account> {acc};
        AccountService.getInstance().createNewAccountActive(newRecords);
        System.assert(!acc.hasErrors());
    }

    @IsTest
    private static void testpreventInactiveAccountUpdate_Positive() {
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Account oldAcc = new Account(Id = accId, Name = 'Test');
        Account newAcc = new Account(Id = accId, Name = 'New Test');
        
        List<Account> newRecords = new List<Account> {newAcc};
        Map<Id, Account> oldRecords = new Map<Id, Account> {
            accId => oldAcc
        };
        AccountService.getInstance().preventInactiveAccountUpdate(newRecords, oldRecords);
        System.assert(!newAcc.hasErrors());
    }

    @IsTest
    private static void testpreventInactiveAccountUpdate_Negative() {
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Account oldAcc = new Account(Id = accId, Name = 'Test', Active__c = 'No');
        Account newAcc = new Account(Id = accId, Name = 'New Test');
        
        List<Account> newRecords = new List<Account> {newAcc};
        Map<Id, Account> oldRecords = new Map<Id, Account> {
            accId => oldAcc
        };
        try {
            AccountService.getInstance().preventInactiveAccountUpdate(newRecords, oldRecords);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), Constants.ERROR_YOU_CANT_UPDATE_INACTIVE_ACCOUNT, 'Unexpected error');
        }
    }
}