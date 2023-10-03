public with sharing class CaseSelector {

    public static Case getCaseById(Id recordId) {
        return [SELECT AccountId, ContactId, Origin FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
    }
}