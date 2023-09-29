@isTest
private class TestAccountTrigger {
    @isTest
    static void testTriggerOnInsert() {
        Account acc = new Account(Name='Test Account');
        Test.startTest();
        insert acc;
        Test.stopTest();
        Account retrievedAccount = [SELECT Id, Active__c FROM Account WHERE Id =: acc.Id LIMIT 1];
        System.assertEquals('Yes', retrievedAccount.Active__c, 'New account should be active');
    }

    @isTest
    static void testTriggerOnUpdate() {
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
