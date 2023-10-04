public with sharing class ContactSelector {
    public static Contact getContactById(Id recordId) {
        return [SELECT Id, AccountId FROM Contact WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
    }
}