trigger CaseTrigger on Case (before update) {
    CaseTriggerHandler.getInstance().run(
        Trigger.new,
        Trigger.oldMap,
        Trigger.operationType
    );
}