@IsTest
public with sharing class TestContactSelector {

    public static final String TEST_ACCOUNT = 'Test Account';
    public static final String TEST_CONTACT= 'Test Contact';
    public static final String INCORRECT_ACCOUNT_VALUE= 'Account must be null';
    public static final String INCORRECT_ACCOUNT_NULL= 'Account do not have to be null';


    @IsTest
    private static void testGetInstance() {
        ContactSelector original = ContactSelector.instance;
        Assert.isNull(original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        ContactSelector newInstance = ContactSelector.getInstance();
        Assert.isNotNull(newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }


 @IsTest
    private static void testgetContactById_noAccountToReturn() {
 
        Contact c = new Contact(LastName =TEST_CONTACT);
      
        database.insert (c);
      
        Contact contact = ContactSelector.getInstance().getContactById(c.Id);
        // Verify results.
        Assert.isNull(contact.AccountId, INCORRECT_ACCOUNT_VALUE);
        

    }

    @IsTest
    private static void testgetContactById_AccountToReturn() {

        Account account = new Account(Name=TEST_ACCOUNT);
        
        database.insert (account);

        Contact c = new Contact(LastName =TEST_CONTACT,AccountId=account.Id);
      
        database.insert (c);

        Contact contact = ContactSelector.getInstance().getContactById(c.Id);

        // Verify results.
        Assert.isNotNull(contact.AccountId, INCORRECT_ACCOUNT_NULL);


    }


}