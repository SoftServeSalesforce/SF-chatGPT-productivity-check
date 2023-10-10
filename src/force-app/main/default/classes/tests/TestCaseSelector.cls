@isTest
private class TestCaseSelector {
    @testSetup
    static void makeData(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        Contact contact = new Contact(AccountId = account.Id, LastName = 'Test Contact');
        insert contact;
        Case testCase = new Case(AccountId = account.Id, ContactId = contact.Id, Origin = 'Web');
        insert testCase;
    }


    @isTest
    static void testGetCaseById() {
        Case testCase = [SELECT Id, AccountId, ContactId, Origin FROM Case LIMIT 1];
        
        Test.startTest();
        Case selectedCase = CaseSelector.getCaseById(testCase.Id);
        Test.stopTest();

        System.assertEquals(testCase.AccountId, selectedCase.AccountId, 'AccountId should match');
        System.assertEquals(testCase.ContactId, selectedCase.ContactId, 'ContactId should match');
        System.assertEquals(testCase.Origin, selectedCase.Origin, 'Origin should match');
    }
}
