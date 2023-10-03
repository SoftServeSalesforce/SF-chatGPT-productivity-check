@IsTest
private class TestCreateActionsController {
    // Assertation error messages
    private static final String ERROR_UNEXPECTED_EXCEPTION = 'Unexpected exception occured.';
    private static final String EXCEPTION_SHOULD_BE_TRHOWN = 'Exception should be thrown.';
    private static final String ERROR_CASE_ORIGIN_SHOULD_BE_DEFAULTED = 'Case origin should be defaulted.';
    private static final String ERROR_ACCOUNT_ID_SHOULD_BE_NULL = 'Account Id should be null.';
    private static final String ERROR_ACCOUNT_ID_SHOULD_BE_RETURNED = 'Account Id should be returned.';
    private static final String ERROR_CONTACT_ID_SHOULD_BE_NULL = 'Contact Id should be null.';
    private static final String ERROR_CONTACT_ID_SHOULD_BE_RETURNED = 'Contact Id should be returned.';
    

    /**
     * @description testCreateNewCaseDetailsFromRecord_ExceptionOnUnsupportedType: Test method needed 
     * to ensure that 'createNewCaseDetailsFromRecord' method of 'CreateActionsController' class 
     * throws expected error when recordId is of unsupported type.
     */
    @IsTest
    private static void testCreateNewCaseDetailsFromRecord_ExceptionOnUnsupportedType() {
        // Data setup.
        Id recordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Boolean isExceptionThrown = false;
        // Execute scenario.        
        try {
            // Execute scenario.        
            CreateActionsController.createNewCaseDetailsFromRecord(recordId);
        } catch (Exception e) {
            isExceptionThrown = true;
            Assert.isTrue(
                e.getMessage().contains(Constants.ERROR_UNSUPPORTED_OBJECT_TYPE),
                ERROR_UNEXPECTED_EXCEPTION
            );
        }
        // Verify results.
        Assert.isTrue(isExceptionThrown, EXCEPTION_SHOULD_BE_TRHOWN);
    }

    /**
     * @description testGetCreateCaseDetails_CaseDefaultsReturned_Positive: Test method needed 
     * to ensure that 'getCreateCaseDetails' method of 'CreateActionsController' class 
     * returns Case defaults when recordId is of type 'Case'.
     */
    @IsTest
    private static void testGetCreateCaseDetails_CaseDefaultsReturned_Positive() {
        // Data setup.
        Id recordId = fflib_IDGenerator.generate(Case.SObjectType);
        // Execute scenario.        
        CreateActionsController.NewCaseDetailsResponse response = CreateActionsController.getCreateCaseDetails(recordId);
        // Verify results.
        Assert.areEqual(Constants.CASE_CREATE_DEFAULT_ORIGIN, response.caseOrigin, ERROR_CASE_ORIGIN_SHOULD_BE_DEFAULTED);
        Assert.isNull(response.accountId, ERROR_ACCOUNT_ID_SHOULD_BE_NULL);
        Assert.isNull(response.contactId, ERROR_CONTACT_ID_SHOULD_BE_NULL);
    }

    /**
     * @description testGetCreateCaseDetails_CaseDefaultsReturned_Negative: Test method needed 
     * to ensure that 'getCreateCaseDetails' method of 'CreateActionsController' class 
     * returns Case defaults when recordId is null.
     */
    @IsTest
    private static void testGetCreateCaseDetails_CaseDefaultsReturned_Negative() {
        // Data setup.
        Id recordId = null;
        // Execute scenario.        
        CreateActionsController.NewCaseDetailsResponse response = CreateActionsController.getCreateCaseDetails(recordId);
        // Verify results.
        Assert.areEqual(Constants.CASE_CREATE_DEFAULT_ORIGIN, response.caseOrigin, ERROR_CASE_ORIGIN_SHOULD_BE_DEFAULTED);
        Assert.isNull(response.accountId, ERROR_ACCOUNT_ID_SHOULD_BE_NULL);
        Assert.isNull(response.contactId, ERROR_CONTACT_ID_SHOULD_BE_NULL);
    }

    /**
     * @description testGetCreateCaseDetails_AccountDefaultsReturned: Test method needed 
     * to ensure that 'getCreateCaseDetails' method of 'CreateActionsController' class 
     * returns Account defaults when recordId is of type 'Account'.
     */
    @IsTest
    private static void testGetCreateCaseDetails_AccountDefaultsReturned() {
        // Data setup.
        Id recordId = fflib_IDGenerator.generate(Account.SObjectType);
        // Execute scenario.        
        CreateActionsController.NewCaseDetailsResponse response = CreateActionsController.getCreateCaseDetails(recordId);
        // Verify results.
        Assert.areEqual(Constants.CASE_CREATE_DEFAULT_ORIGIN, response.caseOrigin, ERROR_CASE_ORIGIN_SHOULD_BE_DEFAULTED);
        Assert.areEqual(recordId, response.accountId, ERROR_ACCOUNT_ID_SHOULD_BE_RETURNED);
        Assert.isNull(response.contactId, ERROR_CONTACT_ID_SHOULD_BE_NULL);
    }

    /**
     * @description testGetCreateCaseDetails_ContactDefaultsReturned_Positive: Test method needed 
     * to ensure that 'getCreateCaseDetails' method of 'CreateActionsController' class 
     * returns Contact defaults when recordId is of type 'Contact' with AccountId.
     */
    @IsTest
    private static void testGetCreateCaseDetails_ContactDefaultsReturned_Positive() {
        // Data setup.
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Contact mockedContact = new Contact(Id = contactId, AccountId = accountId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContactSelector mockedSelector = (ContactSelector) mocks.mock(ContactSelector.class);
        ContactSelector.instance = mockedSelector;
        // Stubbing.
        mocks.startStubbing();
        mocks.when(mockedSelector.getContactWithAccountId(contactId)).thenReturn(mockedContact);
        mocks.stopStubbing();
        // Execute scenario.        
        CreateActionsController.NewCaseDetailsResponse response = CreateActionsController.getCreateCaseDetails(contactId);
        // Verify results.
        Assert.areEqual(Constants.CASE_CREATE_DEFAULT_ORIGIN, response.caseOrigin, ERROR_CASE_ORIGIN_SHOULD_BE_DEFAULTED);
        Assert.areEqual(contactId, response.contactId, ERROR_CONTACT_ID_SHOULD_BE_RETURNED);
        Assert.areEqual(accountId, response.accountId, ERROR_ACCOUNT_ID_SHOULD_BE_RETURNED);
        ((ContactSelector) mocks.verify(
            mockedSelector
        )).getContactWithAccountId(contactId);
    }

    /**
     * @description testGetCreateCaseDetails_ContactDefaultsReturned_Negative: Test method needed 
     * to ensure that 'getCreateCaseDetails' method of 'CreateActionsController' class 
     * returns Contact defaults when recordId is of type 'Contact' without AccountId.
     */
    @IsTest
    private static void testGetCreateCaseDetails_ContactDefaultsReturned_Negative() {
        // Data setup.
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Contact mockedContact = new Contact(Id = contactId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContactSelector mockedSelector = (ContactSelector) mocks.mock(ContactSelector.class);
        ContactSelector.instance = mockedSelector;
        // Stubbing.
        mocks.startStubbing();
        mocks.when(mockedSelector.getContactWithAccountId(contactId)).thenReturn(mockedContact);
        mocks.stopStubbing();
        // Execute scenario.        
        CreateActionsController.NewCaseDetailsResponse response = CreateActionsController.getCreateCaseDetails(contactId);
        // Verify results.
        Assert.areEqual(Constants.CASE_CREATE_DEFAULT_ORIGIN, response.caseOrigin, ERROR_CASE_ORIGIN_SHOULD_BE_DEFAULTED);
        Assert.areEqual(contactId, response.contactId, ERROR_CONTACT_ID_SHOULD_BE_RETURNED);
        Assert.isNull(response.accountId, ERROR_ACCOUNT_ID_SHOULD_BE_NULL);
        ((ContactSelector) mocks.verify(
            mockedSelector
        )).getContactWithAccountId(contactId);
    }

}