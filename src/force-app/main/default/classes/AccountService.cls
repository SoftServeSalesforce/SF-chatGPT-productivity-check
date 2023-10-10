public with sharing class AccountService {
    @TestVisible
    private static AccountService instance;

    public static AccountService getInstance() {
        if (instance == null) {
            instance = new AccountService();
        }
        return instance;
    }

    public void preventInactiveUpdate(List<Account> newRecords, Map<Id, Account> oldRecords) {
        for (Account newAccount : newRecords) {
            // Check if old record is inactive
            Account oldAccount = oldRecords.get(newAccount.Id);
            if (oldAccount != null && oldAccount.Active__c == Constants.NO) {
                // Prevent update if old record is inactive
                newAccount.addError(Constants.ERROR_INACTIVE_ACCOUNT_UPDATE);
            }
        }
    }
}