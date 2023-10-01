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
        Map<Id, Case> casesWithOwnerStatus = new Map<Id, Case>(CaseSelector.getInstance().getCasesWithOwnerStatusByIds(oldRecords.keySet()));

        for (Case newCase : newRecords) {
            if (
                newCase.Status != oldRecords.get(newCase.Id).Status
                && newCase.OwnerId != uId
                && casesWithOwnerStatus.get(newCase.Id) != null 
                && casesWithOwnerStatus.get(newCase.Id).Owner.IsActive
            ) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }
    }
}