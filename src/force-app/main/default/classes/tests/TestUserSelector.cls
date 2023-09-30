@isTest
private class TestUserSelector {
    
    @TestSetup
    static void setupTestData() {
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            User u = new User(
                FirstName = 'Test',
                LastName = 'User' + i,
                Username = 'testuser' + i + '@example.com',
                ProfileId = UserInfo.getProfileId(),
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                Email = 'testuser' + i + '@example.com',
                Alias = 'TU' + i,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = false
            );
            testUsers.add(u);
        }
        insert testUsers;
    }

    @IsTest
    static void testGetInactiveUserIds() {
        Set<Id> inactiveUserIds = UserSelector.getInactiveUserIds();

        System.assertNotEquals(0, inactiveUserIds.size(), 'Expected inactive user IDs');

    }
}