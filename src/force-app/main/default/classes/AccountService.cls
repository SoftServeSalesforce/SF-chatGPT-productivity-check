public with sharing class AccountService {
    public static void handleNewAccount(Account acc) {
        acc.Active__c = 'Yes';
    }
    
    public static void handleUpdateAccount(Account oldAcc, Account newAcc) {
        if (oldAcc.Active__c == 'No') {
            newAcc.addError(Constants.ERROR_INACTIVE_ACCOUNTS_CANNOT_BE_UPDATED);
        }
    }
}
