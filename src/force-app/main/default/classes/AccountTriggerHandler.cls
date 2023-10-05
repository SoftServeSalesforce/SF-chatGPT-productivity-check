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
            when BEFORE_INSERT {
                AccountService.getInstance().onBeforeInsert(newRecords);
            }
            when BEFORE_UPDATE {
                AccountService.getInstance().onBeforeUpdate(newRecords, oldRecords);
            }
            when else {
                throw new IllegalArgumentException(Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE);
            }
        }
    }    



}