@IsTest
private class TestCaseTriggerHandler {

    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_RUN = 1;
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
        //Verify that instance is null by default.
        CaseTriggerHandler original = CaseTriggerHandler.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        CaseTriggerHandler newInstance = CaseTriggerHandler.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testRun_Enabled_OnBeforeUpdate: Test method needed to ensure that
     * 'run' method of 'CaseTriggerHandler' class respects FeaturesEnabler__c
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
            Case_Trigger__c = true
        );
        //We don't really care what records are for this test.
        List<Case> newRecords = null;
        Map<Id,Case> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        CaseTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_UPDATE_WHEN_ACTIVE
        )).getFeaturesEnabler();
    }

    /**
     * @description testRun_Disabled: Test method needed to ensure that
     * 'run' method of 'CaseTriggerHandler' class throws expected exception
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
            Case_Trigger__c = true
        );
        //We don't really care what records are for this test.
        List<Case> newRecords = null;
        Map<Id,Case> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_INSERT;
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        try {
            CaseTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        //Verify outcomes.
        System.assertEquals(expected, actual);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }

    /**
     * @description testRun_Disabled: Test method needed to ensure that
     * 'run' method of 'CaseTriggerHandler' class respects FeaturesEnabler__c
     * value and prevents logic execution when corresponding property is not set.
     */
    @IsTest
    private static void testRun_Disabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        CasesService mockedService = (CasesService) mocks.mock(CasesService.class);
        CasesService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Case_Trigger__c = false
        );
        //We don't really care what records are for this test as services is mocked.
        List<Case> newRecords = null;
        Map<Id,Case> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        CaseTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }

    /**
     * @description testOnBeforeUpdate_AllEnabled: Test method needed to ensure that
     * 'onBeforeUpdate' method of 'CaseTriggerHandler' class respects FeaturesEnabler__c
     * values and executes Case Service only when corresponding properties are set.
     */
    @IsTest
    private static void testOnBeforeUpdate_AllEnabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        CasesService mockedService = (CasesService) mocks.mock(CasesService.class);
        CasesService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Case_PreventStatusChangeByNotAnOwner__c = true
        );
        List<Case> newRecords = new List<Case>{};
        Map<Id,Case> oldRecords = new Map<Id,Case> {};
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        CaseTriggerHandler.getInstance().onBeforeUpdate(newRecords, oldRecords);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE
        )).getFeaturesEnabler();
        ((CasesService) mocks.verify(
            mockedService,
            1 //Status change validation should be executed, and only once.
        )).preventStatusChangeByNotAnOwner((List<Case>)newRecords, (Map<Id,Case>)oldRecords);
    }
    
    /**
     * @description testOnBeforeUpdate_AllDisabled: Test method needed to ensure that
     * 'onBeforeUpdate' method of 'CaseTriggerHandler' class respects FeaturesEnabler__c
     * values and does not executes Case Service when corresponding properties are not set.
     */
    @IsTest
    private static void testOnBeforeUpdate_AllDisabled() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        CasesService mockedService = (CasesService) mocks.mock(CasesService.class);
        CasesService.instance = mockedService;
        //Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Case_PreventStatusChangeByNotAnOwner__c = false
        );
        List<Case> newRecords = new List<Case>{};
        Map<Id,Case> oldRecords = new Map<Id,Case> {};
        //Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        //Execute scenario.
        CaseTriggerHandler.getInstance().onBeforeUpdate(newRecords, oldRecords);
        //Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE
        )).getFeaturesEnabler();
        ((CasesService) mocks.verify(
            mockedService,
            0 //Status change validation should not be executed.
        )).preventStatusChangeByNotAnOwner(
            (List<Case>)fflib_Match.anyList(),
            (Map<Id,Case>)fflib_Match.anyObject()
        );
    }
}