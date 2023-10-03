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
        Case oldCase;
        Map<Id, User> caseOwners = getOldRecordsOwners(oldRecords);
        for (Case newCase : newRecords) {           
            oldCase = oldRecords.get(newCase.Id);
            if (newCase.Status != oldCase?.Status) {
                if(isStatusUpdateRestricted(uId, caseOwners.get(oldCase.OwnerId))) {  
                    newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
                }
            }
        }
    }

    public static CreateCaseController.CaseDTO handleGetRecordData(Id recordId) {
        SObjectType type = recordId.getSObjectType();
        switch on String.valueOf(type)
        {
            when 'Account' {                
                return new CreateCaseController.CaseDTO(recordId, null, null);
            }
            when 'Contact' {
                Contact con = ContactSelector.getContactById(recordId);
                return new CreateCaseController.CaseDTO(con.AccountId, con.Id, null);
            }
            when 'Case' {
                return new CreateCaseController.CaseDTO(CaseSelector.getCaseById(recordId));
            }
            when else { 
                throw new AuraHandledException(Constants.ERROR_UNSUPPORTED_OBJECT_TYPE);
            }
        }
    }

    private Map<Id, User> getOldRecordsOwners(Map<Id,Case> oldRecords) {
        Map<Id, User> caseOwners = new Map<Id, User>();
        Set<Id> oldOwnersIds = new Set<Id>();
        for(Case rec : oldRecords.values()) {
            oldOwnersIds.add(rec.OwnerId);
        }
        if(!oldOwnersIds.isEmpty()) {
            caseOwners = UserSelector.getUsersById(oldOwnersIds);
        }
        return caseOwners;
    }

    private Boolean isStatusUpdateRestricted(Id userId, User owner) {
       return owner?.Id != userId && owner?.isActive;
    }    
}