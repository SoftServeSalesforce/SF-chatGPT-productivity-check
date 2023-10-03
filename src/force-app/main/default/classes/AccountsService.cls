public with sharing class AccountsService {
    @TestVisible
    private static AccountsService instance;

    public static AccountsService getInstance() {
        if (instance == null) {
            instance = new AccountsService();
        }
        return instance;
    }

    public void activateAccounts(List<Account> newRecords) {
        for (Account account : newRecords) {
            account.Active__c = Constants.YES;
        }
    }

    public void preventUpdateInactiveAccounts(List<Account> newRecords) {
        for (Account account : newRecords) {
            if (account.Active__c.equals(Constants.NO)) {
                account.addError(Constants.ERROR_INACTIVE_ACCOUNT_UPDATE_MESSAGE);
            }
        }
    }
}