@isTest
private class TestAccountHandler {
    @isTest
    static void testHandleNew() {
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='New Test Account'));
        Test.startTest();
        AccountHandler.handleNew(accList);
        Test.stopTest();
        System.assertEquals('Yes', accList[0].Active__c, 'New account should be active');
    }

    @isTest
    static void testHandleUpdate() {
        Account oldAcc = new Account(Name='Old Account', Active__c='No');
        insert oldAcc;
        Account newAcc = new Account(Id=oldAcc.Id, Name='Updated Account');
        Test.startTest();
        try {
            update newAcc;
        } catch (Exception e) {
            System.assertEquals('Inactive accounts cannot be updated.', e.getMessage(), 'Exception message mismatch');
        }
        Test.stopTest();
    }
}
