public with sharing class CasesService {
    @TestVisible
    private static CasesService instance;
    @TestVisible
    private UserSelector userSelector = new UserSelector();

    public static CasesService getInstance() {
        if (instance == null) {
            instance = new CasesService();
        }
        return instance;
    }

    public void preventStatusChangeByNotAnOwner(List<Case> newRecords, Map<Id,Case> oldRecords) {
        Id uId = UserInfo.getUserId();
        Map<Id,Boolean> caseIdToIsActiveOwnerMap = generateCaseIdToIsActiveOwnerMap(oldRecords.values());
        
        for (Case newCase : newRecords) {
            if (
                newCase.Status != oldRecords.get(newCase.Id).Status
                && newCase.OwnerId != uId
                && caseIdToIsActiveOwnerMap.get(newCase.Id)
            ) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }
    }

    // extract caseIdToIsActiveOwnerMap generation to separate method
    private Map<Id,Boolean> generateCaseIdToIsActiveOwnerMap(List<Case> cases) {
        List<Id> ownersIds = new List<Id>();
        for (Case oldCase : cases) {
            ownersIds.add(oldCase.OwnerId);
        }
        Map<Id,User> users = new Map<Id,User>(userSelector.getUsersByIds(ownersIds));
        
        Map<Id,Boolean> caseIdToIsActiveOwnerMap = new Map<Id,Boolean>();
        for (Case oldCase : cases) {
            caseIdToIsActiveOwnerMap.put(oldCase.Id, users.get(oldCase.OwnerId).IsActive);
        }
        return caseIdToIsActiveOwnerMap;
    }

}