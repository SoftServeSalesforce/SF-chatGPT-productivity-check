public with sharing class AccountTriggerService {

    private AccountTriggerService() {}

    @TestVisible
    private static AccountTriggerService instance;   

    public static AccountTriggerService getInstance() {
        if (instance == null) {
            instance = new AccountTriggerService();
        }
        return instance;
    }
    
    public void onBeforeInsert(List<Account> newRecords) {
        setAccountsAsActive(newRecords);
    }

    public void onBeforeUpdate(List<Account> newRecords, Map<Id,Account> oldRecords) {
        validateActiveAccounts(newRecords, oldRecords);
    }

    private void setAccountsAsActive(List<Account> newRecords) {
        for(Account acc : newRecords) {
            acc.IsActive__c = true;
        }      
    }

    private void validateActiveAccounts(List<Account> newRecords, Map<Id,Account> oldRecords) {
        for(Account acc : newRecords) {
            if(!oldRecords.get(acc.Id).IsActive__c) {
                acc.addError(Constants.ERROR_NON_ACTIVE_ACCOUNT_UPDATE);
            }
        }      
    }
}

