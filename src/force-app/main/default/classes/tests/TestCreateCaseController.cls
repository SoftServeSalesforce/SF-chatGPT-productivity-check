@IsTest
private class TestCreateCaseController {

    private static String ACCOUNT_NAME = 'Test Account';
    private static String CONTACT_NAME = 'Test Contact';
    private static String CASE_ORIGIN = 'Email';
    private static String EXPECTED_ACCOUTNTID_MESSAGE = 'AccountId value expected to be populated';
    private static String EXPECTED_CONTACT_ID_MESSAGE = 'ContactId value expected to be populated';
    private static String EXPECTED_CASE_DTO_MESSAGE = 'Expected caseDTO return value';
    
    @TestSetup
    static void makeData(){
        Account account = (Account) TestDataFactory.createSObject(
            new Account(
                    Name = ACCOUNT_NAME,
                    IsActive__c = true
            ),
            'TestDataFactory.AccountDefaults',
            true
        );

        Contact con = new Contact(AccountId = account.Id, LastName = CONTACT_NAME);
        insert con;

        Case cs = new Case(
                Origin = CASE_ORIGIN,
                AccountId = account.Id,
                ContactId = con.Id
            );
        insert cs;
    }

    @IsTest
    static void testGetRecordDataAccountSuccess(){
        Account acc = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME];
        CreateCaseController.CaseDTO caseDto;
        Test.startTest();
            caseDto = CreateCaseController.getRecordData(acc.Id);
        Test.stopTest();  
        Assert.isNotNull(caseDto, EXPECTED_CASE_DTO_MESSAGE);
        Assert.areEqual(caseDto.accountId, acc.Id, EXPECTED_ACCOUTNTID_MESSAGE);        
    }

    @IsTest
    static void testGetRecordDataContactSuccess(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE LastName =: CONTACT_NAME];
        CreateCaseController.CaseDTO caseDto;
        Test.startTest();
            caseDto = CreateCaseController.getRecordData(con.Id);
        Test.stopTest();  
        Assert.isNotNull(caseDto, EXPECTED_CASE_DTO_MESSAGE);
        Assert.areEqual(caseDto.accountId, con.AccountId, EXPECTED_ACCOUTNTID_MESSAGE);        
        Assert.areEqual(caseDto.contactId, con.Id, EXPECTED_CONTACT_ID_MESSAGE);        
    }

    @IsTest
    static void testGetRecordDataCaseSuccess(){
        Case case2 = [SELECT Id, AccountId, ContactId, Origin FROM Case WHERE ContactId IN ( SELECT Id FROM Contact WHERE LastName =: CONTACT_NAME) LIMIT 1];
        CreateCaseController.CaseDTO caseDto;
        Test.startTest();
            caseDto = CreateCaseController.getRecordData(case2.Id);
        Test.stopTest();  
        Assert.isNotNull(caseDto, EXPECTED_CASE_DTO_MESSAGE);
        Assert.areEqual(caseDto.accountId, case2.AccountId, EXPECTED_ACCOUTNTID_MESSAGE);        
        Assert.areEqual(caseDto.contactId, case2.ContactId, EXPECTED_CONTACT_ID_MESSAGE);        
        Assert.areEqual(caseDto.origin, case2.Origin, 'Case origin value expected to be populated from caseDto');        
    }

    @IsTest
    static void testGetRecordDataFailure(){
        Id unknownTypeId = Test.getStandardPricebookId();
        CreateCaseController.CaseDTO caseDto;
        Exception e;
        Test.startTest();
            try{
                caseDto = CreateCaseController.getRecordData(unknownTypeId);
            } catch(Exception ex) {
                e = ex;
                System.debug('cought ' + e.getMessage());
            }            
        Test.stopTest();  
        Assert.isNotNull(e, 'Exception expected');
        Assert.isNull(caseDto, 'Case DTO won\'t be initialized as exception should be thrown');        
    }
}