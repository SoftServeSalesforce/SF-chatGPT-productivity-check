public with sharing class UserSelector {
    public static Set<Id> getInactiveUserIds() {
        Map<Id, User> inactiveUsers = new Map<Id, User>([SELECT Id FROM User WHERE isActive = false]);
        return inactiveUsers.keySet();
    }
}