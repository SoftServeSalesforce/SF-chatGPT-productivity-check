public with sharing class ContactSelector {
    @TestVisible
    private static ContactSelector instance;

    public static ContactSelector getInstance() {
        if (instance == null) {
            instance = new ContactSelector();
        }
        return instance;
    }

    public Contact getContactWithAccountId(Id contactId) {
        return [SELECT Id, AccountId FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED LIMIT 1];
    }
}