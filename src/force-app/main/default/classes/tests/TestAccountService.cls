@isTest
public with sharing class TestAccountService {

    @IsTest
    private static void testGetInstance() {
        AccountService original = AccountService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        AccountService newInstance = AccountService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    @IsTest
    private static void testSetNewAccountsAsActive_Positive() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        mocks.startStubbing();
        mocks.when( mockedSelector
                    .getFeaturesEnabler() )
                    .thenReturn(new FeaturesEnabler__c( Account_Trigger__c = true, 
                                                        Account_NewRecordIsAlwaysActive__c = true ));
        mocks.stopStubbing();
        Account testAcc = new Account(Name = 'TestAcc CheckIsActive');
        Test.startTest();
        insert testAcc;
        Test.stopTest();
        Account accToCheck = [SELECT Id, Active__c FROM Account WHERE Name = :testAcc.Name LIMIT 1]; 
        Assert.areEqual('Yes', accToCheck.Active__c, 'New Account should be active!');
    }

    @IsTest
    private static void testSetNewAccountsAsActive_Negative() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        mocks.startStubbing();
        mocks.when( mockedSelector
                    .getFeaturesEnabler() )
                    .thenReturn(new FeaturesEnabler__c( Account_Trigger__c = true, 
                                                        Account_NewRecordIsAlwaysActive__c = false ));
        mocks.stopStubbing();
        Account testAcc = new Account(Name = 'TestAcc CheckNotIsActive');
        Test.startTest();
        insert testAcc;
        Test.stopTest();
        Account accToCheck = [SELECT Id, Active__c FROM Account WHERE Name = :testAcc.Name LIMIT 1]; 
        Assert.areNotEqual('Yes', accToCheck.Active__c, 'New Account should not be active!');
    }

    @IsTest
    private static void testPreventInactiveAccountsUpdate_Positive() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        mocks.startStubbing();
        mocks.when( mockedSelector
                    .getFeaturesEnabler() )
                    .thenReturn(new FeaturesEnabler__c( Account_Trigger__c = true,
                                                        Account_PreventUpdateIfInactive__c = true ));
        mocks.stopStubbing();
        Account testAcc = new Account(Name = 'TestAcc CheckUpdate', Active__c = 'No');
        insert testAcc;
        testAcc.Name = 'Updated Name';
        Exception expectedException;

        Test.startTest();
        try {
            update testAcc;
            Assert.isTrue(false, 'Exception should be thrown');
        } catch(Exception ex) {
            expectedException = ex;
        }
        Test.stopTest();

        Assert.isTrue(  expectedException.getMessage().contains(Constants.ERROR_RECORD_CANNOT_BE_UPDATED), 
                        'Custom error msg should be thrown!' );
    }

    @IsTest
    private static void testPreventInactiveAccountsUpdate_Negative() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        mocks.startStubbing();
        mocks.when( mockedSelector
                    .getFeaturesEnabler() )
                    .thenReturn(new FeaturesEnabler__c( Account_Trigger__c = true));
        mocks.stopStubbing();
        Account testAcc = new Account(Name = 'TestAcc CheckUpdate', Active__c = 'No');
        insert testAcc;
        testAcc.Name = 'Updated Name';

        Test.startTest();
        update testAcc;
        Test.stopTest();

        Account accToCheck = [SELECT Name FROM Account WHERE Id = :testAcc.Id];
        Assert.areEqual('Updated Name', testAcc.Name, 'Account name should be updated!');
    }
}