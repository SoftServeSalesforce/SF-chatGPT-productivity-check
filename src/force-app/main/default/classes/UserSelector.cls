public with sharing class UserSelector {
    public Set<Id> getAllInactiveUsersForCases(List<Case> cases) {
        Set<Id> ownerIds = new Set<Id>();
        for(Case c : cases) {
            ownerIds.add(c.ownerId);
        }
        Map<Id, User> userToId = new Map<Id, User>([SELECT Id 
                                                        FROM User 
                                                        WHERE isActive = false AND Id IN :ownerIds]);
        return userToId.keySet();
    }
    @TestVisible
        private static UserSelector instance;
        public static UserSelector getInstance() {
            if (instance == null) {
                instance = new UserSelector();
            }
            return instance;
        }
}