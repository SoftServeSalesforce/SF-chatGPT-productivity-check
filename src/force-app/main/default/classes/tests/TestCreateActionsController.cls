@isTest
public class TestCreateActionsController {
    @testSetup
    static void makeData(){
        Account acc = new Account(Name = 'Test Account', Active__c = 'Yes');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        Case c = new Case(Subject = 'Test Case', AccountId = acc.Id, ContactId = con.Id, Origin = 'Web');
        insert c;
    }

    @isTest
    static void testGetCaseAccountDetailsSuccess() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        CreateActionsController.CaseDTO caseDTO;

        Test.startTest();
        caseDTO = CreateActionsController.getCaseDetails(acc.Id);
        Test.stopTest();
        Assert.isNotNull(caseDTO, 'Expected case dto value');
    }

    @isTest
    static void testGetCaseContactDetailsSuccess() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE FirstName = 'Test' AND LastName = 'Contact' LIMIT 1];
        CreateActionsController.CaseDTO caseDTO;

        Test.startTest();
        caseDTO = CreateActionsController.getCaseDetails(con.Id);
        Test.stopTest();

        Assert.isNotNull(caseDTO, 'Expected case dto value');
        Assert.areEqual(caseDTO.contactId, con.Id, 'Expected contact id to match');
        Assert.areEqual(caseDTO.accountId, con.AccountId, 'Expected account id to match');
    }

    @isTest
    static void testGetCaseCaseDetailsSuccess() {
        Case c = [SELECT Id, AccountId, ContactId, Origin FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        CreateActionsController.CaseDTO caseDTO;

        Test.startTest();
        caseDTO = CreateActionsController.getCaseDetails(c.Id);
        Test.stopTest();

        Assert.isNotNull(caseDTO, 'Expected case dto value');
        Assert.areEqual(caseDTO.Origin, c.Origin, 'Expected case Origin to match');
        Assert.areEqual(caseDTO.contactId, c.ContactId, 'Expected contact id to match');
        Assert.areEqual(caseDTO.accountId, c.AccountId, 'Expected account id to match');
    }

    @isTest
    static void testGetCaseDetailsFailure() {
        Id unsuportedObjectTypeId = fflib_IDGenerator.generate(Lead.SObjectType);
        CreateActionsController.CaseDTO caseDTO;
        Exception ex;

        Test.startTest();
        try {
            caseDTO = CreateActionsController.getCaseDetails(unsuportedObjectTypeId);
            System.assert(false, 'Expected exception to be thrown');
        } catch (Exception e) {
            ex = e;
            Assert.isNotNull(e, 'Expected exception to be thrown');
        }
        Test.stopTest();
    }
}