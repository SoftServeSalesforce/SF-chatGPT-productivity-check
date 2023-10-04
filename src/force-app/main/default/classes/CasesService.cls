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
        for (Case newCase : newRecords) {
            if (
                newCase.Status != oldRecords.get(newCase.Id).Status && newCase.OwnerId != uId
                && (!isLoggedInUserAllowedToEdit(uId,getOldRecordsOwnersMap(oldRecords).get(oldRecords.get(newCase.Id).OwnerId))  )     
            ) {
                newCase.addError(Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS);
            }
        }

    }


    //Check if current user is allowed to edit the case
    private Boolean isLoggedInUserAllowedToEdit(Id currentUserId, User oldOwner) {
        boolean isUserAllowed=false;
        if(oldOwner.Id != currentUserId && !oldOwner.isActive){
            isUserAllowed=true;
        }

        return isUserAllowed;
        
     } 

    //Retrieve old owner(Active status) querying in UsersSelector
     private Map<Id, User> getOldRecordsOwnersMap(Map<Id,Case> oldRecordsMap) {
        Set<Id> oldOwnersIdsSet = new Set<Id>();
        Map<Id, User> caseOwnersMap = new Map<Id, User>();
        

        if(!oldRecordsMap.isEmpty()){

            for(Case cases : oldRecordsMap.values()) {
                oldOwnersIdsSet.add(cases.OwnerId);
            }

            if(!oldOwnersIdsSet.isEmpty()) {
                caseOwnersMap = UsersSelector.getInstance().getUsersById(oldOwnersIdsSet);
            }

        }

        return caseOwnersMap;





    }








}