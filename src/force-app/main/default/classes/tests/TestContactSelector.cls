@IsTest
private class TestContactSelector {

    //Test data
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String CONTACT_LAST_NAME = 'TestContact';
    // Test assertation error messages
    private static final String ERROR_ACCOUNT_SHOULD_NOT_BE_NULL = 'Account should not be null.';
    private static final String ERROR_ACCOUNT_SHOULD_BE_NULL = 'Account should be null.';
    @TestSetup
    static void makeData(){
        TestDataFactory.getInstance().createAccount(ACCOUNT_NAME);
        TestDataFactory.getInstance().createContact(CONTACT_LAST_NAME);
    }
    
    @IsTest
    private static void testGetInstance() {
        CaseSelector original = CaseSelector.instance;
        Assert.isNull(original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        CaseSelector newInstance = CaseSelector.getInstance();
        Assert.isNotNull(newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testGetContactWithAccountId_Positive: Test method needed to ensure that
     * 'getContactWithAccountId' method of 'ContactSelector' class 
     * returns Contact with AccountId if its provided
     */
    @IsTest
    private static void testGetContactWithAccountId_Positive() {
        // Data setup.
        Contact testContact = fetchContactByLastName();
        Id testAccountId = fetchAccountIdByName();
        testContact.AccountId = testAccountId;
        update testContact;
        // Test scenario.
        Contact record = ContactSelector.getInstance().getContactWithAccountId(testContact.Id);
        // Verify results.
        Assert.isNotNull(record.AccountId, ERROR_ACCOUNT_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testGetContactWithAccountId_Negative: Test method needed to ensure that
     * 'getContactWithAccountId' method of 'ContactSelector' class 
     * returns Contact with AccountId if its not set
     */
    @IsTest
    private static void testGetContactWithAccountId_Negative() {
        // Data setup.
        Contact testContact = fetchContactByLastName();
        // Test scenario.
        Contact record = ContactSelector.getInstance().getContactWithAccountId(testContact.Id);
        // Verify results.
        Assert.isNull(record.AccountId, ERROR_ACCOUNT_SHOULD_BE_NULL);
    }

    private static Id fetchAccountIdByName() {
        return [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME].Id;
    }

    private static Contact fetchContactByLastName() {
        return [SELECT Id, LastName FROM Contact WHERE LastName = :CONTACT_LAST_NAME];
    }
}