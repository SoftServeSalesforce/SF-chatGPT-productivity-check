public with sharing class CreateCaseController {
    
    @AuraEnabled
    public static CreateCaseController.CaseDTO getRecordData(Id recordId){
        try {
            return CasesService.handleGetRecordData(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CaseDTO {
        @AuraEnabled
        public Id accountId;

        @AuraEnabled
        public Id contactId;

        @AuraEnabled
        public String origin;       
        
        public CaseDTO(Id AccountId, Id ContactId, String origin) {
            this.accountId = accountId;
            this.contactId = contactId;
            this.origin = origin;
        }

        public CaseDTO(Case caseFrom) {
            this.accountId = caseFrom.AccountId;
            this.contactId = caseFrom.ContactId;
            this.origin = caseFrom.Origin;
        }
    }
}