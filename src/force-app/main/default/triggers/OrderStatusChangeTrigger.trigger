trigger OrderStatusChangeTrigger on Order (before update) {
    OrderTriggerHandler.handleStatusChange(Trigger.old, Trigger.new);
}