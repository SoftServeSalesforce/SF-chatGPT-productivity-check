@IsTest
private class TestAccountTriggerHandler {
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_RUN = 1;
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE = 1;
    private static final Integer SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_UPDATE_WHEN_ACTIVE =
        SETTINGS_SELECTOR_EXECUTIONS_AT_RUN + SETTINGS_SELECTOR_EXECUTIONS_AT_ONBEFOREUPDATE;

    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        // Verify that instance is null by default.
        AccountTriggerHandler original = AccountTriggerHandler.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);

        // Verify that public accessor works.
        AccountTriggerHandler newInstance = AccountTriggerHandler.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testRun_Enabled_OnBeforeUpdate: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and executes logic when the corresponding property is set.
     */
    @IsTest
    private static void testRun_Enabled_OnBeforeUpdate() {
        // Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        // Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        // We don't really care what records are for this test.
        List<Account> newRecords = null;
        Map<Id, Account> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;

        // Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();

        // Execute scenario.
        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);

        // Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_ON_BEFORE_UPDATE_WHEN_ACTIVE
        )).getFeaturesEnabler();
    }

    /**
     * @description testRun_Enabled_UnsupportedOperationType: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class throws the expected exception
     * when executed on an unsupported operation.
     */
    @IsTest
    private static void testRun_Enabled_UnsupportedOperationType() {
        // Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        // Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        // We don't really care what records are for this test.
        List<Account> newRecords = null;
        Map<Id, Account> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_INSERT;
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;

        // Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();

        // Execute scenario.
        try {
            AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        } catch (Exception e) {
            actual = e.getMessage();
        }

        // Verify outcomes.
        System.assertEquals(expected, actual);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }

    /**
     * @description testRun_Disabled: Test method needed to ensure that
     * 'run' method of 'AccountTriggerHandler' class respects FeaturesEnabler__c
     * value and prevents logic execution when the corresponding property is not set.
     */
    @IsTest
    private static void testRun_Disabled() {
        // Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        // Prepare data.
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = false
        );
        // We don't really care what records are for this test.
        List<Account> newRecords = null;
        Map<Id, Account> oldRecords = null;
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;

        // Stub data.
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();

        // Execute scenario.
        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);

        // Verify outcomes.
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }
}