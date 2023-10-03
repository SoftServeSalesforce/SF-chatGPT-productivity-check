public with sharing class CreateActionsController {

    public class CaseDefaultData {
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String contactId {get;set;}
        public CaseDefaultData(String accountId, String contactId) {
            this.accountId = accountId;
            this.contactId = contactId;
        }
    }

    @AuraEnabled
    public static CaseDefaultData getAccountContactName(final Id recordId) {
        String objectType = recordId.getSObjectType().getDescribe().getName();
        if (objectType == 'Account') {
            return new CaseDefaultData(recordId, null);
        }
        if (objectType == 'Contact') {
            Contact contactRecord = [SELECT Id, AccountId FROM Contact WHERE Id = :recordId];  
            return new CaseDefaultData(contactRecord.AccountId, contactRecord.Id);  
        }
        return null;
    }
}