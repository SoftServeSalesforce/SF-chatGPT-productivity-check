@IsTest
public with sharing class TestUsersSelector {

    @IsTest
    private static void testGetInstance() {
        UsersSelector original = UsersSelector.instance;
        Assert.isNull(original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        UsersSelector newInstance = UsersSelector.getInstance();
        Assert.isNotNull(newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }


    @IsTest
    private static void getUsersByIdTest() {
        Set<Id> usersIds = new Set<Id> { fflib_IDGenerator.generate(User.SObjectType) };
        Map<Id,User> expected = new Map<Id,User>([
            SELECT Id, isActive
                FROM User
                WHERE Id IN:usersIds
                WITH SECURITY_ENFORCED 
        ]);
        Map<Id,User> actual = UsersSelector.getInstance().getUsersById(usersIds);
        System.assertEquals(expected, actual);
    }


    
}