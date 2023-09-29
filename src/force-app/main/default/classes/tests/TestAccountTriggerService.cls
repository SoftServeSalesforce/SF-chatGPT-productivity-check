@IsTest
private class TestAccountTriggerService {    

    @IsTest
    static void testSetAccountsAsActiveSuccess() { 
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        List<Account> accounts = new List<Account>();       
        Account account = (Account) TestDataFactory.createSObject(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'false'
                ),
                'TestDataFactory.AccountDefaults',
                false
        );
        accounts.add(account);
        Account accountWithActiveNull = (Account) TestDataFactory.createSObject(
                new Account(
                        Name = 'Test Account2'
                ),
                'TestDataFactory.AccountDefaults',
                false
        );
        accounts.add(accountWithActiveNull);        
        Assert.areEqual('false', account.Active__c, 'Active property set to false');
        Assert.areEqual(null, accountWithActiveNull.Active__c, 'Active property should be null');
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        Test.startTest();
            insert accounts;
        Test.stopTest();
        List<Account> insertedAccounts = [SELECT Id, Active__c FROM Account WHERE Name IN ('Test Account', 'Test Account2')];
        Assert.areEqual(2, insertedAccounts.size(), 'Expected 2 accounts to be inserted');        
        for(Account acc : insertedAccounts) {            
            Assert.areEqual('true', acc.Active__c, 'Active property updated to true');
        }        
    }

    @IsTest
    static void testSetAccountsAsActiveFailure() { 
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = false
        );
        
        Account account = (Account) TestDataFactory.createSObject(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'false'
                ),
                'TestDataFactory.AccountDefaults',
                false
        );        
        Assert.areEqual('false', account.Active__c, 'Active property set to false');        
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        Test.startTest();
            insert account;
        Test.stopTest();
        Account insertedAccount = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Assert.areEqual('false', insertedAccount.Active__c, 'Active property should not be updated');      
    }

    @IsTest
    static void testValidateActiveAccountsSuccess() { 
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );    
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);
        mocks.stopStubbing();
        Account account = (Account) TestDataFactory.createSObject(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'true'
                ),
                'TestDataFactory.AccountDefaults',
                false
        );
        insert account;        
        Exception e;
        Test.startTest();
            try{
                account.AccountNumber = '223';
                update account;
            } catch(Exception ex) {
                e = ex;
            }            
        Test.stopTest();
        Assert.isNull(e, 'Exception is not expected');
        Account updatedAccount = [SELECT Id, AccountNumber FROM Account WHERE Name = 'Test Account'];                
        Assert.areEqual('223', updatedAccount.AccountNumber, 'Account property updated successfully');     
    }

    @IsTest
    static void testValidateActiveAccountsFailure() { 
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector mockedSelector = (CustomSettingsSelector) mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = mockedSelector;
        FeaturesEnabler__c enabler = new FeaturesEnabler__c(
            Account_Trigger__c = true
        );
        mocks.startStubbing();
            mocks.when(mockedSelector.getFeaturesEnabler()).thenReturn(enabler);    
        mocks.stopStubbing();    
        Account account = (Account) TestDataFactory.createSObject(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'true'
                ),
                'TestDataFactory.AccountDefaults',
                false
        );
        insert account;
        account.Active__c = 'false';
        update account;        
        Exception e;
        Test.startTest();
            try{
                account.AccountNumber = '223';
                update account;     
            } catch(Exception ex) {
                e = ex;
            }            
        Test.stopTest();
        Assert.isNotNull(e, 'Exception is expected');
        Assert.isTrue(e.getMessage().contains(Constants.ERROR_NON_ACTIVE_ACCOUNT_UPDATE), 'Exception is expected');   
    }
}