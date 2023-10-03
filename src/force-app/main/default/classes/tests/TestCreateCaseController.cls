@IsTest
private class TestCreateCaseController {
    
    @IsTest
    private static void testPreventStatusChangeByNotAnOwner_Positive() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        CreateCaseController.NewCaseParametersDto result = CreateCaseController.getNewCaseParameters(accountId);
        Assert.areEqual(result.accountId, accountId, 'Account Id should be the same');
    }

    @IsTest
    private static void getNewCaseParametersDto_Positive() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Contact contact = new Contact(Id = contactId, AccountId = accountId);

        CreateCaseController.NewCaseParametersDto result = CreateCaseController.getNewCaseParametersDto(contact);
        Assert.areEqual(result.accountId, accountId, 'Account Id should be the same');
        Assert.areEqual(result.contactId, contactId, 'Contact Id should be the same');
    }

    @IsTest
    private static void getNewCaseParametersDto_Negative() {
        Id userId = fflib_IDGenerator.generate(User.SObjectType);

        CreateCaseController.NewCaseParametersDto result = CreateCaseController.getNewCaseParameters(userId);
        Assert.isTrue(String.isBlank(result.accountId), 'Account Id should be null');
        Assert.isTrue(String.isBlank(result.contactId), 'Contact Id should be null');
    }
}
