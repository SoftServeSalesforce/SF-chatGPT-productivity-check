@isTest
private class TestAccountService {
    @isTest
    static void testHandleNewAccount() {
        Account acc = new Account(Name='Test Account');

        Test.startTest();
        AccountService.handleNewAccount(acc);
        System.assertEquals('Yes', acc.Active__c, 'New account should be active');  

        Test.stopTest();
    }

    @isTest
    static void testHandleUpdateAccount() {
        Account oldAcc = new Account(Name='Old Account', Active__c='No');
        Account newAcc = new Account(Id = oldAcc.Id, Name='Updated Account');

        Test.startTest();
        try {
            AccountService.handleUpdateAccount(oldAcc, newAcc);
        } catch (Exception e) {
            System.assertEquals('Inactive accounts cannot be updated.', e.getMessage(), 'Exception message mismatch');
        }
        Test.stopTest();
    }
}
