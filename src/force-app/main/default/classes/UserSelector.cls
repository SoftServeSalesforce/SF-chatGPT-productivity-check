public with sharing class UserSelector {
    public static List<User> getInactiveUsers() {
        return [SELECT Id FROM User WHERE IsActive = false];
    }
}
