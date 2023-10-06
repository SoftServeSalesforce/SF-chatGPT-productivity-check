@isTest
public with sharing class TestUserSelector {
    @TestSetup
    static void makeData(){
        Id standardProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1][0].Id;

        User inactivUser = new User(Email = 'test.user@mail.com',
                                    EmailEncodingKey = 'UTF-8',
                                    Alias = 'testAl',
                                    LastName = 'TestLast',
                                    Username = 'test.user@mail.com_new',
                                    IsActive = false,
                                    ProfileId = standardProfileId,
                                    LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US',
                                    TimeZoneSidKey = 'America/New_York');
        insert inactivUser;



    }

    @isTest
    static void testgetAllInactiveUserIds() {
        Id inactiveUserId = [SELECT Id FROM User WHERE Email = 'test.user@mail.com' LIMIT 1].Id;
        Set<Id> inactiveUsers;

        Test.startTest();
        inactiveUsers = UserSelector.getInstance().getAllInactiveUserIds();
        Test.stopTest();

        Assert.isNotNull(inactiveUsers, 'At least one inactive User should be found!');
        Assert.isTrue(inactiveUsers.contains(inactiveUserId), 'Inactive User was not found');
    }
}