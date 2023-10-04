@IsTest
private class TestCreateCaseActionsController {

    private static final String ERROR_CASE_ORIGIN = 'No default case origi set';
    private static final String ERROR_NULL_ACCOUNT = 'Account Id must be null.';
    private static final String ERROR_ACCOUNT_NOT_RETURNED = 'Account Id must be returned';
    private static final String ERROR_NULL_CONTACT = 'Contact Id must be null';
    private static final String ERROR_CONTACT_NOT_RETURNED = 'Contact Id must be returned';
    private static final String ERROR_URL = 'Not ecpected url returned';
    private static final String EXCEPTION_TRHOWN = 'Exception must be thrown';
    private static final String URL = '/lightning/o/Case/new?&defaultFieldValues=Origin=';

    //return only case
    @IsTest
    private static void testobjectTypeCase_Positive() {
       
        Id caseRecord = fflib_IDGenerator.generate(Case.SObjectType);
              
        CreateCaseActionController.CreateCaseActionDTO response = CreateCaseActionController.getData(caseRecord);

        // Verify results.
        System.assertEquals(URL+ response.caseOrigin, response.url,ERROR_URL);
        System.assertEquals(Constants.CASE_ORIGIN_WEB, response.caseOrigin,ERROR_CASE_ORIGIN);
        Assert.isNull(response.accountId, ERROR_NULL_ACCOUNT);
        Assert.isNull(response.contactId, ERROR_NULL_CONTACT);
    }

    //return only case even if passed null
    @IsTest
    private static void testobjectTypeCase_Negative() {
        
        Id caseRecord = null;
             
        CreateCaseActionController.CreateCaseActionDTO response = CreateCaseActionController.getData(caseRecord);
        // Verify results.
        System.assertEquals(URL+ response.caseOrigin, response.url,ERROR_URL);
        System.assertEquals(Constants.CASE_ORIGIN_WEB, response.caseOrigin,ERROR_CASE_ORIGIN);
        Assert.isNull(response.accountId, ERROR_NULL_ACCOUNT);
        Assert.isNull(response.contactId, ERROR_NULL_CONTACT);
    }

    //Return only account
    @IsTest
    private static void testobjectTypeAccount() {
        
        Id accountRecord = fflib_IDGenerator.generate(Account.SObjectType);
            
        CreateCaseActionController.CreateCaseActionDTO response = CreateCaseActionController.getData(accountRecord);
        // Verify results.
        System.assertEquals(URL+ + Constants.CASE_ORIGIN_WEB+
        ',AccountId='+response.accountId, response.url,ERROR_URL);
        System.assertEquals(Constants.CASE_ORIGIN_WEB, response.caseOrigin,ERROR_CASE_ORIGIN);
        System.assertEquals(accountRecord, response.accountId,ERROR_ACCOUNT_NOT_RETURNED);
        Assert.isNull(response.contactId, ERROR_NULL_CONTACT);

    }
    //return contact and account
    @IsTest
    private static void testobjectTypeContact_Positive() {
        
        // Data setup.
        Id contacRecordId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id accounRecordId = fflib_IDGenerator.generate(Account.SObjectType);
        Contact mockedContact = new Contact(Id = contacRecordId, AccountId = accounRecordId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContactSelector mockedSelector = (ContactSelector) mocks.mock(ContactSelector.class);
        ContactSelector.instance = mockedSelector;
        // Stubbing.
        mocks.startStubbing();
        mocks.when(mockedSelector.getContactById(contacRecordId)).thenReturn(mockedContact);
        mocks.stopStubbing();
        // Execute scenario.        
        CreateCaseActionController.CreateCaseActionDTO response = CreateCaseActionController.getData(contacRecordId);
        // Verify results.
        System.assertEquals(URL+ + Constants.CASE_ORIGIN_WEB+
        ',AccountId='+response.accountId+
        ',ContactId='+response.contactId, response.url,ERROR_URL);
        System.assertEquals(Constants.CASE_ORIGIN_WEB, response.caseOrigin,ERROR_CASE_ORIGIN);
        System.assertEquals(accounRecordId, response.accountId,ERROR_ACCOUNT_NOT_RETURNED);
        System.assertEquals(contacRecordId, response.contactId,ERROR_CONTACT_NOT_RETURNED);

        ((ContactSelector) mocks.verify(
            mockedSelector
        )).getContactById(contacRecordId);
    }

    //return only contact without account
    @IsTest
    private static void testobjectTypeContact_Negative() {

        // Data setup.
        Id contacRecordId = fflib_IDGenerator.generate(Contact.SObjectType);
        Contact mockedContact = new Contact(Id = contacRecordId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContactSelector mockedSelector = (ContactSelector) mocks.mock(ContactSelector.class);
        ContactSelector.instance = mockedSelector;
        // Stubbing.
        mocks.startStubbing();
        mocks.when(mockedSelector.getContactById(contacRecordId)).thenReturn(mockedContact);
        mocks.stopStubbing();
        // Execute scenario.        
        CreateCaseActionController.CreateCaseActionDTO response = CreateCaseActionController.getData(contacRecordId);
        // Verify results.
        System.assertEquals(URL+ + Constants.CASE_ORIGIN_WEB+
        ',ContactId='+response.contactId, response.url,ERROR_URL);
        System.assertEquals(Constants.CASE_ORIGIN_WEB, response.caseOrigin,ERROR_CASE_ORIGIN);
        Assert.isNull(response.accountId, ERROR_NULL_ACCOUNT);
        System.assertEquals(contacRecordId, response.contactId,ERROR_CONTACT_NOT_RETURNED);

        
        ((ContactSelector) mocks.verify(
            mockedSelector
        )).getContactById(contacRecordId);


    }

    //Test unsupported type
    @IsTest
    private static void testgetData_UnsupportedType() {
        // Data setup.
        Id leadId = fflib_IDGenerator.generate(Lead.SObjectType);
        String expected = Constants.UNSUPPORTED_OBJECT_TYPE;
        String actual;
             
        try {       
            CreateCaseActionController.CreateCaseActionDTO response = CreateCaseActionController.getData(leadId);
        } catch (Exception e) {
            actual = e.getMessage();
            
        }
        // Verify results.
        Assert.isTrue(
            actual.contains(expected),
                EXCEPTION_TRHOWN
            );
             
        
    }

    
}