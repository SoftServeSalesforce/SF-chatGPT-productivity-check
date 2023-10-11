@IsTest
private class TestAccountTriggerHandler {

    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        //Verify that instance is null by default.
        AccountTriggerHandler original = AccountTriggerHandler.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        AccountTriggerHandler newInstance = AccountTriggerHandler.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testRun_Disabled: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and prevents logic execution when corresponding property is not set.
     */
    @IsTest
    private static void testRun_Disabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountService mockedService = (AccountService) mocks.mock(AccountService.class);
        AccountService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = false
        );
        //We don't really care what records are for this test as services is mocked.
        List<Account> newRecords = null;
        Map<Id,Account> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            1
        )).getFeaturesEnabler();
    }

    /**
     * @description testRun_Enabled_UnsupportedOperationType
     */
    @IsTest
    private static void testRun_Enabled_UnsupportedOperationType() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        //We don't really care what records are for this test.
        List<Account> newRecords = null;
        Map<Id,Account> oldRecords = null;
        TriggerOperation operation = TriggerOperation.AFTER_INSERT;
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        try {
            AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        //Verify outcomes.
        System.assertEquals(expected, actual);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            1
        )).getFeaturesEnabler();
    }

    /**
     * @description testOnBeforeUpdate_AllEnabled
     */
    @IsTest
    private static void testOnBeforeUpdate_AllEnabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountService mockedService = (AccountService) mocks.mock(AccountService.class);
        AccountService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true,
            Account_PreventFromUpdatingInactive__c = true
        );
        List<Account> newRecords = null;
        Map<Id,Account> oldRecords = null;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeUpdate(newRecords, oldRecords);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            1
        )).getFeaturesEnabler();
        ((AccountService) mocks.verify(
            mockedService,
            1 //Status change validation should be executed, and only once.
        )).preventFromUpdatingInactive((List<Account>)newRecords, (Map<Id,Account>)oldRecords);
    }

    /**
     * @description testOnBeforeInsert_AllEnabled
     */
    @IsTest
    private static void testOnBeforeInsert_AllEnabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountService mockedService = (AccountService) mocks.mock(AccountService.class);
        AccountService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true,
            Account_AlwaysActiveWhenInsert__c = true
        );
        List<Account> newRecords = new List<Account>{};
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeInsert(newRecords);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            1
        )).getFeaturesEnabler();
        ((AccountService) mocks.verify(
            mockedService,
            1 //Status change validation should be executed, and only once.
        )).makeAlwaysActiveOnInsert((List<Account>)newRecords);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////
    //+++++++++++++++++++++++++
    //////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description testOnBeforeUpdate_Disabled
     */
    @IsTest
    private static void testOnBeforeUpdate_Disabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountService mockedService = (AccountService) mocks.mock(AccountService.class);
        AccountService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true,
            Account_PreventFromUpdatingInactive__c = false
        );
        List<Account> newRecords = null;
        Map<Id,Account> oldRecords = null;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeUpdate(newRecords, oldRecords);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            1
        )).getFeaturesEnabler();
        ((AccountService) mocks.verify(
            mockedService,
            0 //Status change validation should be executed, and only once.
        )).preventFromUpdatingInactive((List<Account>)newRecords, (Map<Id,Account>)oldRecords);
    }

    /**
     * @description testOnBeforeInsert_Disabled
     */
    @IsTest
    private static void testOnBeforeInsert_Disabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountService mockedService = (AccountService) mocks.mock(AccountService.class);
        AccountService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true,
            Account_AlwaysActiveWhenInsert__c = false
        );
        List<Account> newRecords = new List<Account>{};
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeInsert(newRecords);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            1
        )).getFeaturesEnabler();
        ((AccountService) mocks.verify(
            mockedService,
            0 //Status change validation should be executed, and only once.
        )).makeAlwaysActiveOnInsert((List<Account>)newRecords);
    }
}