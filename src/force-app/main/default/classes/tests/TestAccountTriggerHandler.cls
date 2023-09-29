@IsTest
private class TestAccountTriggerHandler {
  
    @IsTest
    private static void testGetInstance() {
        AccountTriggerHandler original = AccountTriggerHandler.instance;
        Assert.areEqual(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        AccountTriggerHandler newInstance = AccountTriggerHandler.getInstance();
        Assert.areNotEqual(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }
   
    @IsTest
    private static void testRunWithEnabledSettingsUpdateOperationSuccess() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;

        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        AccountTriggerHandler.getInstance().run(new List<Account>(), new Map<Id, Account>(), operation);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            TestDataFactory.SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }

    @IsTest
    private static void testRunWithEnabledSettingsInsertOpertaionSuccess() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        TriggerOperation operation = TriggerOperation.BEFORE_INSERT;
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        AccountTriggerHandler.getInstance().run(new List<Account>(), new Map<Id, Account>(), operation);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            TestDataFactory.SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }
   
    @IsTest
    private static void testRunUnsupportedOperationTypeFailure() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        TriggerOperation operation = TriggerOperation.AFTER_DELETE;
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        try {
            AccountTriggerHandler.getInstance().run(null , null, operation);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        Assert.areEqual(expected, actual);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            TestDataFactory.SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }
    
    @IsTest
    private static void testRunWithDisabledSettings() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = false
        );
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        
        AccountTriggerHandler.getInstance().run(null, null, operation);
        ((CustomSettingsSelector) mocks.verify(
            mockedSelector,
            TestDataFactory.SETTINGS_SELECTOR_EXECUTIONS_AT_RUN
        )).getFeaturesEnabler();
    }    
}