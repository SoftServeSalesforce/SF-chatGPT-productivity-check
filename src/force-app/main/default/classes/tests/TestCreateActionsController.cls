@IsTest
private class TestCreateActionsController {

    /**
     * @description testGetAccountContactNameFromAccount_Positive: Test method to test getAccountContactName method
     * to get the accountId and contactId from the account
     */
    @IsTest
    static void testGetAccountContactNameFromAccount_Positive() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        // Call the method to test
        CreateActionsController.CaseDefaultData result = CreateActionsController.getAccountContactName(acc.Id);
        // Verify the result
        System.assertEquals(acc.Id, result.accountId, 'Account Id should be same');
        System.assertEquals(null, result.contactId , 'Contact Id should be null');
    }

    /**
     * @description testGetAccountContactNameFromContactWithAccount_Positive: Test method to test getAccountContactName method
     * to get the accountId and contactId from the contact with account
     */
    @IsTest
    static void testGetAccountContactNameFromContactWithAccount_Positive() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        // Call the method to test
        CreateActionsController.CaseDefaultData result = CreateActionsController.getAccountContactName(con.Id);
        // Verify the result
        System.assertEquals(acc.Id, result.accountId, 'Account Id should be same');
        System.assertEquals(con.Id, result.contactId , 'Contact Id should be same');
    }

    /**
     * @description testGetAccountContactNameFromContactNoAccount_Positive: Test method to test getAccountContactName method
     * to get the accountId and contactId from the contact without account
     */
    @IsTest
    static void testGetAccountContactNameFromContactNoAccount_Positive() {
        // Create test data
        Contact con = new Contact(LastName = 'Test Contact');
        insert con;
        // Call the method to test
        CreateActionsController.CaseDefaultData result = CreateActionsController.getAccountContactName(con.Id);
        // Verify the result
        System.assertEquals(con.Id, result.contactId , 'Contact Id should be same');
        System.assertEquals(null, result.accountId , 'Account Id should be null');
    }

    /**
     * @description testGetAccountContactNameFromCase_Positive: Test method to test getAccountContactName method
     * to get the accountId and contactId from the case
     */
    @IsTest
    static void testGetAccountContactNameFromCase_Positive() {
        // Create test data
        Case con = new Case(Subject = 'Test Case');
        insert con;
        // Call the method to test
        CreateActionsController.CaseDefaultData result = CreateActionsController.getAccountContactName(con.Id);
        // Verify the result
        System.assertEquals(null, result, 'Case should not have account and contact');
    }

    /**
     * @description testGetAccountContactName_Negative: Test method to test getAccountContactName method
     * to get the accountId and contactId in case of recordId is null
     */
    @IsTest
    static void testGetAccountContactName_Negative() {
        // Call the method to test
        CreateActionsController.CaseDefaultData result = CreateActionsController.getAccountContactName(null);
        // Verify the result
        System.assertEquals(null, result, 'Expected result should be null');
    }
}