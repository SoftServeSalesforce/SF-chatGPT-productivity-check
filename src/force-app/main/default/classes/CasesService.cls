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
        Set<Id> inactiveUserIds = UserSelector.getInstance().getAllInactiveUserIds();

        for (Case newCase : newRecords) {
            Case oldCase = oldRecords.get(newCase.Id);
            if (newCase.Status != oldCase.Status
                && !inactiveUserIds.contains(oldCase.OwnerId)) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }
    }
}