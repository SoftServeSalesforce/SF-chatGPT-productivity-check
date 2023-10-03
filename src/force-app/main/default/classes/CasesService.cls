public with sharing class CasesService {
    @TestVisible
    private static CasesService instance;

    public static CasesService getInstance() {
        if (instance == null) {
            instance = new CasesService();
        }
        return instance;
    }

    public void preventStatusChangeByNotAnOwner(List<Case> newRecords, Map<Id,Case> oldRecords) {
        Id uId = UserInfo.getUserId();
        Set<Id> oldOwnerIds = new Set<Id>();
        for (Case oldCase : oldRecords.values()) {
            oldOwnerIds.add(oldCase.OwnerId);
        }

        Map<Id, User> users = new Map<Id, User>([SELECT Id, IsActive FROM User WHERE Id IN :oldOwnerIds]);
        for (Case newCase : newRecords) {
            Case oldCase = oldRecords.get(newCase.Id);
            if (
                newCase.Status != oldCase.Status
                && newCase.OwnerId != uId
                && users.get(oldCase.OwnerId).IsActive
            ) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }
    }
}