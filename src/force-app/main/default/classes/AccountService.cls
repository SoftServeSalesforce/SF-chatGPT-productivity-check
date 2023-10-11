public with sharing class AccountService {
    @TestVisible
    private static AccountService instance;

    public static AccountService getInstance() {
        if (instance == null) {
            instance = new AccountService();
        }
        return instance;
    }

    public void preventFromUpdatingInactive(List<Account> newRecords, Map<Id,Account> oldRecords) {
        for(Account acc : newRecords) {
            if(!Boolean.valueOf(oldRecords.get(acc.Id).Active__c)) {
                acc.addError(Constants.ERROR_CANT_UPDATE_NON_ACTIVE_ACCOUNT);
            }
        }  
    }

    public void makeAlwaysActiveOnInsert(List<Account> newRecords) {
        for(Account acc : newRecords) {
            acc.Active__c = 'true';
        }
    }
}