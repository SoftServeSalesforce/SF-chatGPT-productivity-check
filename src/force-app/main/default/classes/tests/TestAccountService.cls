@IsTest
private class TestAccountService {    
    @IsTest
    static void testAccountMadeActive_Negative() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        Test.startTest();
        TestUtility.insertAccounts(false, 1);
        Test.stopTest();
        Account account = [SELECT Id, Active__c FROM Account LIMIT 1];
        Assert.areEqual('false', account.Active__c, 'Feature not enabled so account shouldnt be active');
    }
    @IsTest
    static void testAccountMadeActive_Positive() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true, 
            Account_AlwaysActiveWhenInsert__c = true
        );
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        Test.startTest();
        TestUtility.insertAccounts(false, 1);
        Test.stopTest();
        Account account = [SELECT Id, Active__c FROM Account LIMIT 1]; 
        Assert.areEqual('true', account.Active__c, 'Feature enabled so account should be active');
    }
    @IsTest
    static void testAccountUpdate_Negative() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        Test.startTest();
        Account accountNegative = TestUtility.insertAccounts(false, 1).get(0);
        accountNegative.Name = 'Updated Name';
        update accountNegative;
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Active__c FROM Account WHERE Name = 'Updated Name'];
        Assert.areEqual(1, accounts.size(), 'Feature not enabled so account should be updated succesfuly even though its not active');
    }
    @IsTest
    static void testAccountUpdate_Positive() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true,
            Account_PreventFromUpdatingInactive__c = true
        );
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        Test.startTest();
        Account accountPositive = TestUtility.insertAccounts(false, 1).get(0);
        accountPositive.Name = 'Updated Name';
        try{
        	update accountPositive;
        } catch(Exception e) {
            //
        }
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Active__c FROM Account WHERE Name = 'Updated Name'];
        Assert.areEqual(0, accounts.size(), 'Feature not enabled so account shouldnt be updated succesfuly because its not active');
    }
}