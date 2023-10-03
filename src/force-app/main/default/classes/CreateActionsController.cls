public with sharing class CreateActionsController {
    @TestVisible
    private static final String CREATE_CASE_SUPPORTED_SOBJECT_TYPE_CASE = 'Case';
    @TestVisible
    private static final String CREATE_CASE_SUPPORTED_SOBJECT_TYPE_CONTACT = 'Contact';
    @TestVisible
    private static final String CREATE_CASE_SUPPORTED_SOBJECT_TYPE_ACCOUNT = 'Account';
    
    // Probably could do it with custom builder for better flexibility
    @TestVisible
    private class NewCaseDetailsResponse{
        @AuraEnabled
        public Id accountId;
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public String caseOrigin;

        private NewCaseDetailsResponse(){
            this.caseOrigin = Constants.CASE_CREATE_DEFAULT_ORIGIN;
        }

        public NewCaseDetailsResponse(Id accountId){
            this();
            this.accountId = accountId;
        }

        public NewCaseDetailsResponse(Id accountId, Id contactId){
            this();
            this.accountId = accountId;
            this.contactId = contactId;
        }
    }

    @AuraEnabled
    public static NewCaseDetailsResponse getCreateCaseDetails(Id recordId){
        try {
            return createNewCaseDetailsFromRecord(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static NewCaseDetailsResponse createNewCaseDetailsFromRecord(Id recordId){
        String recordSObjectType = recordId?.getSobjectType().getDescribe().getName();
        if(recordSObjectType == null || recordSObjectType.equals(CREATE_CASE_SUPPORTED_SOBJECT_TYPE_CASE)) {
            return new NewCaseDetailsResponse();
        }
        if(recordSObjectType.equals(CREATE_CASE_SUPPORTED_SOBJECT_TYPE_ACCOUNT)) {
            return new NewCaseDetailsResponse(recordId);
        }
        if(recordSObjectType.equals(CREATE_CASE_SUPPORTED_SOBJECT_TYPE_CONTACT)) {
            Contact cn = ContactSelector.getInstance().getContactWithAccountId(recordId);
            return new NewCaseDetailsResponse(cn.AccountId, recordId);
        }
        throw new CreateActionsUnsupportedException(
            Constants.ERROR_UNSUPPORTED_OBJECT_TYPE + recordSObjectType
        );
    }
}