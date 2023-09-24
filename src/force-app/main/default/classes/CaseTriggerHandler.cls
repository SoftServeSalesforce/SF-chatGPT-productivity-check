public with sharing class CaseTriggerHandler {

    @TestVisible
    private static CaseTriggerHandler instance;

    public static CaseTriggerHandler getInstance() {
        if (instance == null) {
            instance = new CaseTriggerHandler();
        }
        return instance;
    }

    public void run(List<Case> newRecords, Map<Id,Case> oldRecords, TriggerOperation operation) {
        if (!CustomSettingsSelector.getInstance().getFeaturesEnabler().Case_Trigger__c) {
            return;
        }
        switch on operation {
            when BEFORE_UPDATE {
                onBeforeUpdate(newRecords, oldRecords);
            }
            when else {
                throw new IllegalArgumentException(Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE);
            }
        }
    }

    @TestVisible
    private void onBeforeUpdate(List<Case> newRecords, Map<Id,Case> oldRecords) {
        if (CustomSettingsSelector.getInstance().getFeaturesEnabler().Case_PreventStatusChangeByNotAnOwner__c) {
            CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        }
    }
}