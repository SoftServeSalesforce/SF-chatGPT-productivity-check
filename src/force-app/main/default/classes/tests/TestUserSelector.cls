@IsTest
private class TestUserSelector {
    @IsTest 
    private static void testGetUsersByIds_Positive() {
        User currentUser = new UserSelector().getUsersByIds(new List<Id>{UserInfo.getUserId()})[0];
        Assert.isTrue(currentUser.isActive, 'Current user should be active');
    }

    @IsTest
    private static void testGetUsersByIds_Negative() {
        List<User> users = new UserSelector().getUsersByIds(new List<Id>{fflib_IDGenerator.generate(User.SObjectType)});
        Assert.isTrue(users.isEmpty(), 'Users should be empty. There is no user with such id');
    }

    @IsTest
    private static void testGetUsersByIds_NegativeWithException() {
        try {
            new UserSelector().getUsersByIds(new List<Id>{fflib_IDGenerator.generate(Account.SObjectType)});
            Assert.fail('Exception should be thrown');
        } catch (Exception ex) {
            Assert.isTrue(ex.getMessage().contains('Invalid SObjectType'), 'Exception should be thrown');
        }
    }
}