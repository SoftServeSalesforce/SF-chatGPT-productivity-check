/**
 * @description UsersSelector: Selector to access "User" SObject records.
 */
public with sharing class UsersSelector {
    
    @TestVisible
    private static UsersSelector instance;

    public static UsersSelector getInstance() {
        if (instance == null) {
            instance = new UsersSelector();
        }
        return instance;
    }
   
    public Map<Id,User> getUsersById(Set<Id> usersId) {

        Map<Id,User> queriedUsersMap = new Map<Id,User>(
            [
                SELECT Id, isActive
                FROM User
                WHERE Id IN:usersId
                WITH SECURITY_ENFORCED           
            ]
        );

        return queriedUsersMap;

     
    }

}