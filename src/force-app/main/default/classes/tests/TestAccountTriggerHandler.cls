@isTest
public with sharing class TestAccountTriggerHandler {
    
    @IsTest
    private static void testGetInstance() {
        AccountTriggerHandler original = AccountTriggerHandler.instance;
        Assert.areEqual(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        AccountTriggerHandler newInstance = AccountTriggerHandler.getInstance();
        Assert.areNotEqual(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    @IsTest
    private static void testRun_BeforeInsert() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountService mockedService = (AccountService) mocks.mock(AccountService.class);
        AccountService.instance = mockedService;

        mocks.startStubbing();
        mocks.when( mockedSelector
                    .getFeaturesEnabler() )
                    .thenReturn(new FeaturesEnabler__c( Account_Trigger__c = true, 
                                                        Account_NewRecordIsAlwaysActive__c = true ));
        mocks.stopStubbing();

        Test.startTest();
        AccountTriggerHandler.getInstance().run(new List<Account>(), new Map<Id, Account>(), TriggerOperation.BEFORE_INSERT);
        Test.stopTest();

        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            2
        )).getFeaturesEnabler();
        ((AccountService) mocks.verify(
            mockedService,
            1
        )).setNewAccountsAsActive(new List<Account>());
    }

    @IsTest
    private static void testRun_BeforeUpdate() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountService mockedService = (AccountService) mocks.mock(AccountService.class);
        AccountService.instance = mockedService;

        mocks.startStubbing();
        mocks.when( mockedSelector
                    .getFeaturesEnabler() )
                    .thenReturn(new FeaturesEnabler__c( Account_Trigger__c = true, 
                                                        Account_PreventUpdateIfInactive__c = true ));
        mocks.stopStubbing();

        Test.startTest();
        AccountTriggerHandler.getInstance().run(new List<Account>(), new Map<Id, Account>(), TriggerOperation.BEFORE_UPDATE);
        Test.stopTest();

        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            2
        )).getFeaturesEnabler();
        ((AccountService) mocks.verify(
            mockedService,
            1
        )).preventInactiveAccountsUpdate(new List<Account>(), new Map<Id, Account>());
    }

    @IsTest
    private static void testRun_Negative() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(new FeaturesEnabler__c(Account_Trigger__c = true));
        mocks.stopStubbing();
        Exception expectedException;

        Test.startTest();
        try {
            AccountTriggerHandler.getInstance().run(new List<Account>(), new Map<Id, Account>(), TriggerOperation.AFTER_INSERT);
            Assert.isTrue(false, 'Exception should be thrown');
        } catch (Exception ex) {
            expectedException = ex;
        }
        Test.stopTest();

        Assert.isTrue(  expectedException.getMessage().contains(Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE), 
                        'Custom error msg should be thrown!' );
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            1
        )).getFeaturesEnabler();


    }

}