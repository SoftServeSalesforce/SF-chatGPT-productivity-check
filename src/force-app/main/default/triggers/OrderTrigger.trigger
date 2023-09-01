trigger OrderTrigger on Order (before update) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            OrderTriggerHandler.updateLastStatusChanged(Trigger.new, Trigger.oldMap);
        }
    }
}
