public with sharing class AccountService {
    @TestVisible
    private static AccountService instance;

    public static AccountService getInstance() {
        if (instance == null) {
            instance = new AccountService();
        }
        return instance;
    }

    public void createNewAccountActive(List<Account> newRecords) {
        for (Account acc : newRecords) {
            acc.Active__c = 'Yes';
        }
    }

    public void preventInactiveAccountUpdate(List<Account> newRecords, Map<Id,Account> oldRecords) {
        
        for (Account updatedAcc : newRecords) {
            Account oldAcc = oldRecords.get(updatedAcc.Id);
            if (oldAcc.Active__c == 'No') {
                updatedAcc.addError(Constants.ERROR_YOU_CANT_UPDATE_INACTIVE_ACCOUNT);
            }
        }
    }
}