public with sharing class CreateCasesAgentController {

    @AuraEnabled(cacheable=true)
    public static CaseCreateWrapper getAccontCaseIds(Id recordId) {
        if(recordId == null) {
            return null;
        }
        String objectName = recordId.getSObjectType().getDescribe().getName();
        switch on objectName {
            when  'Account'{
                return new CaseCreateWrapper(recordId, null);
            }
            when 'Contact'{
                Contact c = [SELECT Id, Name, AccountId 
                            FROM Contact 
                            WHERE Id = :recordId
                            Limit 1];
                return new CaseCreateWrapper(c.accountId, c.Id);
            }
        }
        return null;
    }

    public class CaseCreateWrapper {
        @AuraEnabled public String accountId;
        @AuraEnabled public String contactId; 
        public CaseCreateWrapper(String accountId, String contactId) {
            this.accountId = accountId;
            this.contactId = contactId;
        }
    }
}