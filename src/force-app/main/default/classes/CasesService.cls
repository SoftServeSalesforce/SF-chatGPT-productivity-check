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
        Set<Id> inactiveUserIds = new Set<Id>();
    
        List<User> inactiveUsers = UserSelector.getInactiveUsers();
        for (User user : inactiveUsers) {
            inactiveUserIds.add(user.Id);
        }
    
        Id uId = UserInfo.getUserId();
        for (Case newCase : newRecords) {
            Case oldCase = oldRecords.get(newCase.Id);
    
            if (oldCase.OwnerId != null && inactiveUserIds.contains(oldCase.OwnerId)) {
                continue;
            }
    
            if (newCase.Status != oldCase.Status && newCase.OwnerId != uId) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }
    }
    
}
