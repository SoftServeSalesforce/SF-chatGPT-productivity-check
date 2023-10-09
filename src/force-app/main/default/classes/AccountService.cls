public with sharing class AccountService {
    @TestVisible
    private static AccountService instance;

    public static AccountService getInstance() {
        if (instance == null) {
            instance = new AccountService();
        }
        return instance;
    }

    public void setNewAccountsAsActive(List<Account> newRecords) {
        for (Account acc : newRecords) {
            acc.Active__c = 'Yes';
        }
    }

    public void preventInactiveAccountsUpdate(List<Account> newRecords, Map<Id,Account> oldRecords) {
        for (Account acc : newRecords) {
            if (String.valueOf(oldRecords.get(acc.Id).Active__c) != 'Yes') {
                acc.addError(Constants.ERROR_RECORD_CANNOT_BE_UPDATED);
            }
        }
    }
}