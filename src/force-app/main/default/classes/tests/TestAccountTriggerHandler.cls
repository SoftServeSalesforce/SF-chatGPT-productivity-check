@IsTest
private class TestAccountTriggerHandler {

    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_RUN = 1;
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREINSERT = 1;
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE = 1;
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_INSERT_WHEN_ACTIVE =
        SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        + SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREINSERT; 
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_UPDATE_WHEN_ACTIVE = 
        SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        + SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE;

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
     * @description testRun_Enabled_OnBeforeInsert: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and executes logic when corresponding property is set.
     */
    @IsTest
    private static void testRun_Enabled_OnBeforeInsert() {
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
        TriggerOperation operation = TriggerOperation.BEFORE_INSERT;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        //Verify outcomes.
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_INSERT_WHEN_ACTIVE);
    }

    /**
     * @description testRun_Enabled_OnBeforeUpdate: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and executes logic when corresponding property is set.
     */
    @IsTest
    private static void testRun_Enabled_OnBeforeUpdate() {
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
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        //Verify outcomes.
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_UPDATE_WHEN_ACTIVE);
    }

    /**
     * @description testRun_Disabled: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class throws expected exception
     * when executed on unexpected operation.
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
        System.assertEquals(expected, actual, Constants.ERROR_UNEXPECTED_TRIGGER_HANDLER_OPERATION_MESSAGE);
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_AT_RUN);
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
        AccountsService mockedService = (AccountsService) mocks.mock(AccountsService.class);
        AccountsService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = false
        );
        //We don't really care what records are for this test as services is mocked.
        List<Account> newRecords = null;
        Map<Id, Account> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        //Verify outcomes.
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_AT_RUN);
    }

    /**
     * @description testOnBeforeInsert_AllEnabled: Test method needed to ensure that
     * 'onBeforeInsert' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * values and executes AccountsService only when corresponding properties are set.
     */
    @IsTest
    private static void testOnBeforeInsert_AllEnabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountsService mockedService = (AccountsService) mocks.mock(AccountsService.class);
        AccountsService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_MakeActiveOnInsert__c = true
        );
        List<Account> newRecords = new List<Account>{};
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeInsert(newRecords);
        //Verify outcomes.
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREINSERT);

        ((AccountsService) mocks.verify(
            mockedService
        )).makeActive((List<Account>)newRecords);
    }
    
    /**
     * @description testOnBeforeInsert_AllDisabled: Test method needed to ensure that
     * 'onBeforeInsert' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * values and does not executes AccountsService when corresponding properties are not set.
     */
    @IsTest
    private static void testOnBeforeInsert_AllDisabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountsService mockedService = (AccountsService) mocks.mock(AccountsService.class);
        AccountsService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_MakeActiveOnInsert__c = false
        );
        List<Account> newRecords = new List<Account>{};
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeInsert(newRecords);
        //Verify outcomes.
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREINSERT);

        ((AccountsService) mocks.verify(
            mockedService,
            fflib_ApexMocks.NEVER
        )).makeActive(
            (List<Account>)fflib_Match.anyList()
        );
    }

    /**
     * @description testOnBeforeUpdate_AllEnabled: Test method needed to ensure that
     * 'onBeforeUpdate' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * values and executes AccountsService only when corresponding properties are set.
     */
    @IsTest
    private static void testOnBeforeUpdate_AllEnabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountsService mockedService = (AccountsService) mocks.mock(AccountsService.class);
        AccountsService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_PreventUpdatesOnInactive__c = true
        );
        List<Account> newRecords = new List<Account>{};
        Map<Id,Account> oldRecords = new Map<Id,Account> {};
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeUpdate(newRecords, oldRecords);
        //Verify outcomes.
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE);

        ((AccountsService) mocks.verify(
            mockedService
        )).preventUpdatesOnInactive((List<Account>)newRecords, (Map<Id,Account>)oldRecords);
    }
    
    /**
     * @description testOnBeforeUpdate_AllDisabled: Test method needed to ensure that
     * 'onBeforeUpdate' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * values and does not executes AccountsService when corresponding properties are not set.
     */
    @IsTest
    private static void testOnBeforeUpdate_AllDisabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        AccountsService mockedService = (AccountsService) mocks.mock(AccountsService.class);
        AccountsService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_PreventUpdatesOnInactive__c = false
        );
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        // Prepare dummy data.
        List<Account> newRecords = new List<Account>{};
        Map<Id,Account> oldRecords = new Map<Id,Account> {};
        //Execute scenario.
        AccountTriggerHandler.getInstance().onBeforeUpdate(newRecords, oldRecords);
        //Verify outcomes.
        verifySelectorExecutions(mocks, mockedSelector, SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE);
        ((AccountsService) mocks.verify(
            mockedService,
            fflib_ApexMocks.NEVER
        )).preventUpdatesOnInactive(
            (List<Account>)fflib_Match.anyList(),
            (Map<Id,Account>)fflib_Match.anyObject()
        );
    }

    private static void verifySelectorExecutions(
        fflib_ApexMocks mocks,
        CustomSettingsSelector mockedSelector,
        Integer expectedExecutions
    ) {
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            expectedExecutions
        )).getFeaturesEnabler();
    }
}