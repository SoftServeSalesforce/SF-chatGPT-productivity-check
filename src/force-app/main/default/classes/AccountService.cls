public with sharing class AccountService {
    @TestVisible
    private static AccountService instance;

    public static AccountService getInstance() {
        if (instance == null) {
            instance = new AccountService();
        }
        return instance;
    }

    public void preventUpdateInactiveAccounts(List<Account> newRecords, Map<Id,Account> oldRecords) {
        for (Account newAccount : newRecords) {
            Account oldAccount = oldRecords.get(newAccount.Id);
            if (oldAccount.Active__c == Constants.ACCOUNT_STATUS_INACTIVE) {
                newAccount.Active__c.addError(Constants.ERROR_UPDATE_INACTIVE_ACCOUNT);
            }
        }
    }

    public void setActiveNewAccounts(List<Account> newRecords) {
        for (Account newAccount : newRecords) {
            newAccount.Active__c = Constants.ACCOUNT_STATUS_ACTIVE;
        }
    }

    public void setActiveAllUndefinedAccounts() {
        List<Account> undefinedAccounts = [SELECT Id, Active__c FROM Account WHERE Active__c = NULL LIMIT 50000];
        for (Account undefinedAccount : undefinedAccounts) {
            undefinedAccount.Active__c = Constants.ACCOUNT_STATUS_ACTIVE;
        }
        update undefinedAccounts;
    }
}