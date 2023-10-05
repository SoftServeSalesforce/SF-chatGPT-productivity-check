public with sharing class AccountService {
    
    @TestVisible
    private static AccountService instance;   

    public static AccountService getInstance() {
        if (instance == null) {
            instance = new AccountService();
        }
        return instance;
    }

    public void onBeforeInsert(List<Account> newRecords) {
        onBeforeInsertActivateStatus(newRecords);
    }

    public void onBeforeUpdate(List<Account> newRecords, Map<Id,Account> oldRecords) {
        preventInvalidAccountUpdate(newRecords, oldRecords);
    }


    private void onBeforeInsertActivateStatus(List<Account> newAccounts) {
        for(Account a : newAccounts) {
            a.Active__c = Constants.ACCOUNT_ACTIVE;
        }      
    }

    private void preventInvalidAccountUpdate(List<Account> newRecords, Map<Id,Account> oldRecords) {

        for(Account a : newRecords) {           
            if( String.isBlank(oldRecords.get(a.Id).Active__c) || oldRecords.get(a.Id).Active__c==Constants.ACCOUNT_INACTIVE  ) {
                a.addError(Constants.ERROR_INACTIVE_ACCOUNT);
            }
        }      
    }

    


}