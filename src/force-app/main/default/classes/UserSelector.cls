public inherited sharing class UserSelector {

    public static User getUserById(Id userId) {
        return [SELECT Id, isActive FROM User WHERE Id=:userId];
    }

    public static Map<Id,User> getUsersById(Set<Id> userIds) {
        Map<Id,User> usersMap = new Map<Id,User>([SELECT Id, isActive FROM User WHERE Id IN:userIds WITH SECURITY_ENFORCED]);    
        return usersMap;
    }
}