public with sharing class UserSelector {
    @TestVisible
    private static UserSelector instance;

    public static UserSelector getInstance() {
        if (instance == null) {
            instance = new UserSelector();
        }
        return instance;
    }
    
    public Set<Id> getAllInactiveUserIds() {
        return new Map<Id, User>([SELECT Id FROM User WHERE isActive = false]).keySet();
    }
}
