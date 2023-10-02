public with sharing class AccountsService {

    @TestVisible
    private static AccountsService instance;

    public static AccountsService getInstance() {
        if (instance == null) {
            instance = new AccountsService();
        }
        return instance;
    }

    public void makeActive(List<Account> records) {
        for (Account acct : records) {
            acct.Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_YES;
        }
    }

    public void preventUpdatesOnInactive(List<Account> newRecords, Map<Id, Account> oldRecords) {
        for (Account acct : newRecords) {
            Boolean isTryingeToReactivate = oldRecords.get(acct.Id).Active__c == Constants.ACCOUNT_ACTIVE_PICKLIST_NO 
                && acct.Active__c == Constants.ACCOUNT_ACTIVE_PICKLIST_YES;
            Boolean canReactivate = isTryingeToReactivate && FeatureManagement.checkPermission(Constants.ACCOUNT_ALLOW_REACTIVATE_PERMISSION);
            Boolean canUpdate = oldRecords.get(acct.Id).Active__c != Constants.ACCOUNT_ACTIVE_PICKLIST_NO;
            if (!canUpdate && !canReactivate) {
                acct.Active__c.addError(Constants.ERROR_CANT_UPDATE_INACTIVE_ACCOUNT);
            }
        }
    }
}
