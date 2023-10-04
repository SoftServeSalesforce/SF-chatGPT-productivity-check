public with sharing class CreateActionsController {
    @AuraEnabled
    public static CaseDTO getCaseDetails(Id recordId) {
        try {
            return CasesService.handleGetRecordDetails(recordId);
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

        public CaseDTO(Id accountId, Id contactId, String origin) {
            this.accountId = accountId;
            this.contactId = contactId;
            this.origin = origin;
        }
    }
}