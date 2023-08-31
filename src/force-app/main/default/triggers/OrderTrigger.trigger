trigger OrderTrigger on Order (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}