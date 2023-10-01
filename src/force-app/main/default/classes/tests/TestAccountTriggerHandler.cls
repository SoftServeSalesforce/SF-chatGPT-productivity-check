@IsTest
private class TestAccountTriggerHandler {
    @IsTest
    private static void testGetInstance() {
        AccountTriggerHandler original = AccountTriggerHandler.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);

        AccountTriggerHandler newInstance = AccountTriggerHandler.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    @IsTest
    private static void testRunEnabledOnBeforeInsert() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true,
            Account_CreateNewAccountActive__c = true
        );

        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAcc = new Account(Id = accId, Name = 'New Test');
        List<Account> newRecords = new List<Account>{newAcc};
        Map<Id,Account> oldRecords = new Map<Id,Account>();
        TriggerOperation operation = TriggerOperation.BEFORE_INSERT;
        
        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();

        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        ((CustomSettingsSelector) mocks.verify(mockedSelector,2)).getFeaturesEnabler();
    }

    @IsTest
    private static void testRunEnabledOnBeforeUpdate() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;

        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true,
            Account_PreventInactiveAccountUpdate__c = true
        );

        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Account oldAcc = new Account(Id = accId, Name = 'Test');
        Account newAcc = new Account(Id = accId, Name = 'New Test');
        List<Account> newRecords = new List<Account>{newAcc};
        Map<Id,Account> oldRecords = new Map<Id,Account>{accId => oldAcc};
        TriggerOperation operation = TriggerOperation.BEFORE_UPDATE;

        mocks.startStubbing();
        mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();

        AccountTriggerHandler.getInstance().run(newRecords, oldRecords, operation);
        ((CustomSettingsSelector) mocks.verify(mockedSelector,2)).getFeaturesEnabler();
    }
}