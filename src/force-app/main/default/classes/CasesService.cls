public with sharing class CasesService {
    @TestVisible
    private static CasesService instance;

    public static CasesService getInstance() {
        if (instance == null) {
            instance = new CasesService();
        }
        return instance;
    }

    public void preventStatusChangeByNotAnOwner(List<Case> newRecords, Map<Id, Case> oldRecords) {
        Id uId = UserInfo.getUserId();
        Map<Id, Id> caseOwners = new Map<Id, Id>();
        for (Case newCase : newRecords) {
            caseOwners.put(newCase.Id, newCase.OwnerId);
        }
        List<User> activeUsers = UserSelector.getInstance().getActiveUsers(new Set<Id>(caseOwners.values()));
        Map<Id, User> activeOwners = new Map<Id, User>();
        for (User user : activeUsers) {
            activeOwners.put(user.Id, user);
        }
        for (Case newCase : newRecords) {
            Id ownerId = caseOwners.get(newCase.Id);
            System.debug('xxx ownerId: ' + ownerId + ' uId: ' + uId + ' activeOwners.containsKey(ownerId): ' + activeOwners.containsKey(ownerId));
            if (newCase.Status != oldRecords.get(newCase.Id).Status &&
                ownerId != uId &&
                activeOwners.containsKey(ownerId)) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }
    }
}