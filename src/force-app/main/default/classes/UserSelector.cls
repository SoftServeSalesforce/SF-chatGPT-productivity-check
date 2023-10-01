public inherited sharing class UserSelector {
    public UserSelector() {

    }
    public List<User> getUsersByIds(List<Id> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            return new List<User>();
        }
        if (userIds[0].getSobjectType() != User.getSObjectType()) {
            throw new UserSelectorException('Invalid SObjectType');
        }
        return [SELECT Id, Name, Email, isActive FROM User WHERE Id IN :userIds];
    }

    public class UserSelectorException extends Exception {}
}