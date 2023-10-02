@IsTest
public with sharing class TestUserSelector {
    private static final String TEST_EMAIL = 'kmacz@softserveinc.com';
    @TestSetup
    static void makeData(){
        User ownerUser = TestUtility.insertUser();
        Map<Id,Case> testCases = new Map<Id, Case> (TestUtility.insertCases(ownerUser.Id,2));
    }
    @IsTest
    private static void testAllInactiveUsersForCases() {
        User ownerUser = [SELECT Id, isActive FROM User WHERE Email = :TEST_EMAIL LIMIT 1];
        ownerUser.isActive = false;
        update ownerUser;
        Map<Id, Case> testCases = new Map<Id, Case>([SELECT Id, OwnerId FROM Case]);
        
        Set<Id> firstUsers = UserSelector.getInstance().getAllInactiveUsersForCases(testCases.values());
        Assert.areEqual(1, firstUsers.size());
    }
}