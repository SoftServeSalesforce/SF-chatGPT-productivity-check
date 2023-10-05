@IsTest
private class TestAccountTriggerHandler {


    
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_RUN = 1;
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREINSERT = 1;
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE = 1;
   
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_UPDATE_WHEN_ACTIVE = 
        SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        + SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE;

    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        AccountTriggerHandler original = AccountTriggerHandler.instance;
        Assert.areEqual(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        AccountTriggerHandler newInstance = AccountTriggerHandler.getInstance();
        Assert.areNotEqual(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }


    /**
     * @description testRun_DisabledFeatureEnabler: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and prevents logic execution when corresponding property is not set.
     */
    @IsTest
    private static void testRun_DisabledFeatureEnabler() {
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
        
        TriggerOperation operation = TriggerOperation.BEFORE_INSERT;
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        
        AccountTriggerHandler.getInstance().run(null, null, operation);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }

    

    /**
     * @description testRun_EnabledFE_UnsupportedOperationType: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class throws expected exception
     * when executed on unexpected operation.
     */
    @IsTest
    private static void testRun_EnabledFE_UnsupportedOperationType() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        List<Account> newRecords = null;
        Map<Id,Account> oldRecords = null;
        TriggerOperation operation = TriggerOperation.AFTER_INSERT;
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        try {
            AccountTriggerHandler.getInstance().run(newRecords , oldRecords, operation);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual,Constants.ERROR_TRIGGER_HANDLER);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }

    /**
     * @description testRun_EnabledFEBeforeInsertOperation: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and executes logic when corresponding property is set.
     */
    @IsTest
    private static void testRun_EnabledFEBeforeInsertOperation() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );

        TriggerOperation operation = TriggerOperation.BEFORE_INSERT;

        List<Account> newRecords = new List<Account>{};
        Map<Id,Account> oldRecords = new Map<Id,Account> {};

        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREINSERT
        )).getFeaturesEnabler();
    }

     /**
     * @description testRun_EnabledFEBeforeUpdateOperation: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and executes logic when corresponding property is set.
     */

    @IsTest
    private static void testRun_EnabledFEBeforeUpdateOperation() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        //We don't really care what records are for this test.
        List<Account> newRecords = new List<Account>{};
        Map<Id,Account> oldRecords = new Map<Id,Account> {};
        
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
            SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE
        )).getFeaturesEnabler();
    }



}