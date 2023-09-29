public with sharing class AccountTriggerHandler {

    @TestVisible
    private static AccountTriggerHandler instance;

    public static AccountTriggerHandler getInstance() {
        if (instance == null) {
            instance = new AccountTriggerHandler();
        }
        return instance;
    }

    public void run(List<Account> newRecords, Map<Id,Account> oldRecords, TriggerOperation operation) {
        if (!CustomSettingsSelector.getInstance().getFeaturesEnabler().Account_Trigger__c) {
            return;
        }
        switch on operation {
            when BEFORE_UPDATE {
                onBeforeUpdate(newRecords, oldRecords);
            }
            when BEFORE_INSERT {
                onBeforeInsert(newRecords);
            }
            when else {
                throw new IllegalArgumentException(Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE);
            }
        }
    }

    @TestVisible
    private void onBeforeUpdate(List<Account> newRecords, Map<Id,Account> oldRecords) {
        if (CustomSettingsSelector.getInstance().getFeaturesEnabler().Account_PreventUpdateInactiveAccounts__c) {
            AccountService.getInstance().preventUpdateInactiveAccounts(newRecords, oldRecords);
        }
    }

    @TestVisible
    private void onBeforeInsert(List<Account> newRecords) {
        if (CustomSettingsSelector.getInstance().getFeaturesEnabler().Account_SetActiveNewAccounts__c) {
            AccountService.getInstance().setActiveNewAccounts(newRecords);
        }
    }
}