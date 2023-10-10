public with sharing class UserSelector {
    @TestVisible
    private static UserSelector instance;

    public static UserSelector getInstance() {
        if (instance == null) {
            instance = new UserSelector();
        }
        return instance;
    }

    public List<User> getActiveUsers(Set<Id> userIds) {
        return [SELECT Id, IsActive FROM User WHERE Id IN :userIds AND IsActive = true];
    }
}