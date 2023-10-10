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
    
    public static CreateActionsController.CaseDTO handleGetRecordDetails(Id recordId) {
        SObjectType objectType = recordId.getSObjectType();

        switch on String.valueOf(objectType) {
            when 'Account' {
                return new CreateActionsController.CaseDTO(recordId, null, null);
            }
            when 'Contact' {
                Contact con = ContactSelector.getContactById(recordId);
                return new CreateActionsController.CaseDTO(con.AccountId, con.Id, null);
            }
            when 'Case' {
                Case selectedCase = CaseSelector.getCaseById(recordId);
                return new CreateActionsController.CaseDTO(selectedCase.AccountId, selectedCase.ContactId, selectedCase.Origin);
            }
            when else {
                throw new AuraHandledException('Unsupported object type: ' + objectType);
            }
        }
    }
}
