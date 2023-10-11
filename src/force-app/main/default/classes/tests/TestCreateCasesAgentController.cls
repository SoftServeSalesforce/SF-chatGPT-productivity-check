@IsTest
private class TestCreateCasesAgentController {

    @IsTest
    private static void testGetAccontCaseIds_NullRecordId() {
        CreateCasesAgentController.CaseCreateWrapper caseCreateWrapper = CreateCasesAgentController.getAccontCaseIds(null);
        Assert.areEqual(null, caseCreateWrapper, 'Result should be empty');
    }

    @IsTest
    private static void testGetAccontCaseIds_AccountId() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        CreateCasesAgentController.CaseCreateWrapper caseCreateWrapper = CreateCasesAgentController.getAccontCaseIds(accountId);
        Assert.areEqual(accountId, caseCreateWrapper.accountId, 'Results account ids should be the same');
    }


    @IsTest
    private static void testGetAccontCaseIds_ContactId() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Contact contact = new Contact(AccountId = accountId, LastName = 'test');
        insert contact;

        CreateCasesAgentController.CaseCreateWrapper caseCreateWrapper = CreateCasesAgentController.getAccontCaseIds(contact.Id);
        Assert.areEqual(accountId, caseCreateWrapper.accountId, 'Account Id should be the same');
        Assert.areEqual(contact.Id, caseCreateWrapper.contactId, 'Contact Id should be the same');
    }

    private static void testGetAccontCaseIds_DifferentId() {
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        CreateCasesAgentController.CaseCreateWrapper caseCreateWrapper = CreateCasesAgentController.getAccontCaseIds(userId);
        Assert.areEqual(null, caseCreateWrapper, 'Result should be empty because that is not a supported kind of id');
    }
}