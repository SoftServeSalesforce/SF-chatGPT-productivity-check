@IsTest
private class TestAccountService {


    public static final String INCORRECT_ACCOUNT_NAME = 'Account Name is Incorrect';
    public static final String INCORRECT_ACCOUNT_SITE = 'Account Site is Incorrect';
    public static final String INCORRECT_ACCOUNT_STATUS = 'Account Status is Incorrect';
    public static final String TEST_ACCOUNT = 'Test Account';
    public static final String SITE_NEW_VALUE = 'SiteNewValue';
    public static final String SITE_OLD_VALUE = 'SiteOldValue';

     /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */    
    @IsTest
    private static void testGetInstance() {
        //Verify that instance is null by default.
        AccountService original = AccountService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        AccountService newInstance = AccountService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    //Account created as ACTIVE status and inserted as ACTIVE
    @IsTest
    private static void testInsertAccountWithActiveSet_Positive() { 
        
        Account testAccount= new Account( Name = TEST_ACCOUNT ,Active__c = Constants.ACCOUNT_ACTIVE);

        List<Account> accountToInsert = new List<Account>();       
       
        accountToInsert.add(testAccount);
                     
        System.assertEquals(Constants.ACCOUNT_ACTIVE, testAccount.Active__c,INCORRECT_ACCOUNT_STATUS);
        
        AccountService.getInstance().onBeforeInsert(accountToInsert);

        System.assertEquals(Constants.ACCOUNT_ACTIVE, testAccount.Active__c,INCORRECT_ACCOUNT_STATUS);
        System.assertEquals(TEST_ACCOUNT, testAccount.Name,INCORRECT_ACCOUNT_NAME);

              
    }

    //Account created with blank active status and inserted as ACTIVE
    @IsTest
    private static void testInsertAccountWithActiveIsNotSet_Positive() { 
        
        Account testAccount= new Account( Name = TEST_ACCOUNT);

        List<Account> accountToInsert = new List<Account>();       
       
        accountToInsert.add(testAccount);
              
        
        System.assertEquals(null, testAccount.Active__c,INCORRECT_ACCOUNT_STATUS);
       
        AccountService.getInstance().onBeforeInsert(accountToInsert);

       
        System.assertEquals(Constants.ACCOUNT_ACTIVE, testAccount.Active__c,INCORRECT_ACCOUNT_STATUS);
        System.assertEquals(TEST_ACCOUNT, testAccount.Name,INCORRECT_ACCOUNT_NAME);

              
    }

    //Account created as Inactive and inserted as ACTIVE
    @IsTest
    private static void testInsertAccountWithActiveSet_Negative() { 
        

        Account testAccount= new Account( Name = TEST_ACCOUNT,Active__c = Constants.ACCOUNT_INACTIVE);

        List<Account> accountToInsert = new List<Account>();       
        
        accountToInsert.add(testAccount);
              
       
        System.assertEquals(Constants.ACCOUNT_INACTIVE, testAccount.Active__c,INCORRECT_ACCOUNT_STATUS);
        
       
        AccountService.getInstance().onBeforeInsert(accountToInsert);
       
        System.assertEquals(Constants.ACCOUNT_ACTIVE, testAccount.Active__c,INCORRECT_ACCOUNT_STATUS);
        System.assertEquals(TEST_ACCOUNT, testAccount.Name,INCORRECT_ACCOUNT_NAME);  
    }


    //Account site must be updated with no error because Account is active
    @IsTest
    private static void testOnBeforeUpdate_Positive() {

        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(
            Id = accId,
            Site = SITE_NEW_VALUE
        );

        Account oldAccount = new Account(
            Id = accId,
            Site = SITE_OLD_VALUE,
            Active__c = Constants.ACCOUNT_ACTIVE
        );

        List<Account> newRecords = new List<Account>{ newAccount };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ accId => oldAccount };

        AccountService.getInstance().onBeforeUpdate(newRecords, oldRecords);
        
        Assert.isFalse(newAccount.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
        
        System.assertEquals(SITE_NEW_VALUE, newAccount.Site,INCORRECT_ACCOUNT_SITE);

        
           

    }

    //Account must not be updated because inactive and has to throw an error
    @IsTest
    private static void testOnBeforeUpdate_Negative() { 
        
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Account newAccount = new Account(
            Id = accId,
            Site = SITE_NEW_VALUE
        );

        Account oldAccount = new Account(
            Id = accId,
            Site = SITE_OLD_VALUE,
            Active__c = Constants.ACCOUNT_INACTIVE
        );

        List<Account> newRecords = new List<Account>{ newAccount };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ accId => oldAccount };

        AccountService.getInstance().onBeforeUpdate(newRecords, oldRecords);

        Assert.isTrue(newAccount.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        Assert.areEqual(Constants.ERROR_INACTIVE_ACCOUNT,newAccount.getErrors()[0].getMessage(),Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR);           
  
    }

    //Ensure error is thrown only when necessary
    @IsTest
    private static void testOnBeforeUpdate_Mixed() {
        // Setup data.
        Id negativeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id positiveAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        
        Account newNegativeAccount = new Account(
            Id = negativeAccountId,
            Site = SITE_NEW_VALUE
        );

        Account oldNegativeAccount = new Account(
            Id = negativeAccountId,
            Site = SITE_OLD_VALUE,
            Active__c = Constants.ACCOUNT_INACTIVE
        );
        Account newPositiveAccount = new Account(
            Id = positiveAccountId,
            Site = SITE_NEW_VALUE
        );

        Account oldPositiveAccount = new Account(
            Id = positiveAccountId,
            Site = SITE_OLD_VALUE,
            Active__c = Constants.ACCOUNT_ACTIVE
        );

        List<Account> newRecords = new List<Account>{ newNegativeAccount, newPositiveAccount };
        Map<Id, Account> oldRecords = new Map<Id, Account>{ 
            negativeAccountId => oldNegativeAccount,
            positiveAccountId => oldPositiveAccount 
        };
        // Execute scenario.
        AccountService.getInstance().onBeforeUpdate(newRecords, oldRecords);
        // Verify outcomes.
        Assert.isFalse(newPositiveAccount.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
        Assert.isTrue(newNegativeAccount.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        Assert.areEqual(Constants.ERROR_INACTIVE_ACCOUNT,newNegativeAccount.getErrors()[0].getMessage(),Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR);     
        
    }



}




    
