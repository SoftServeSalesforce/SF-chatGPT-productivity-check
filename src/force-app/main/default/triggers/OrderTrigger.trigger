trigger OrderTrigger on Order (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderTriggerHandler.handleStatusChange(Trigger.new, Trigger.oldMap);
    }
}