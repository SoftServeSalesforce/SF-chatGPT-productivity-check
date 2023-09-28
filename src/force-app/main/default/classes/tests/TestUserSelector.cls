@isTest
public class TestUserSelector {
    @testSetup
    static void setupTestData() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User activeUser = createUser('Active', 'User', 'active@example.com', 'testactiveuser@example.com', 'active', sysAdminProfile.Id, true);
        User inactiveUser1 = createUser('Inactive', 'User1', 'inactive1@example.com', 'testinactiveuser1@example.com', 'inac1', sysAdminProfile.Id, false);
        User inactiveUser2 = createUser('Inactive', 'User2', 'inactive2@example.com', 'testinactiveuser2@example.com', 'inac2', sysAdminProfile.Id, false);
    }

    @isTest
    static void testGetInactiveUsers() {
        List<User> activeUsers = [SELECT Id From User WHERE IsActive = true];
        Test.startTest();
        List<User> inactiveUsers = UserSelector.getInactiveUsers();
        for (User user : activeUsers) {
            System.assertEquals(false, inactiveUsers.contains(user), 'Expected no active users in inactiveUsers list');
        }
        Test.stopTest();
    }

    private static User createUser(String firstName, String lastName, String email, String username, String alias, Id profileId, Boolean isActive) {
        User newUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = username,
            Alias = alias,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profileId,
            LanguageLocaleKey = 'en_US',
            IsActive = isActive
        );
        insert newUser;
        return newUser;
    }
}
