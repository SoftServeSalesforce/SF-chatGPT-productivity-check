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
        Map<Id, User> users = new Map<Id, User>([SELECT Id, IsActive FROM User]);
        for (Case newCase : newRecords) {
            if (
                newCase.Status != oldRecords.get(newCase.Id).Status
                && newCase.OwnerId != uId
                && users.get(oldRecords.get(newCase.Id).OwnerId).IsActive
            ) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }
    }
}