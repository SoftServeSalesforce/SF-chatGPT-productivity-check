@isTest
public class TestContactSelector {
    @testSetup
    static void makeData(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact' ,AccountId = testAccount.Id);
        insert testContact;
    }

    @isTest
    static void testGetContactById() {
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Test.startTest();
        Contact selectedContact = ContactSelector.getContactById(testContact.Id);
        Test.stopTest();

        System.assertEquals(testContact.Id, selectedContact.Id, 'Contact Id should match');
        System.assertEquals(testContact.AccountId, selectedContact.AccountId, 'Contact AccountId should match');
    }
}