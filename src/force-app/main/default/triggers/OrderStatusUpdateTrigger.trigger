trigger OrderStatusUpdateTrigger on Order (before update) {
    OrderTriggerHandler.handleBeforeUpdate(Trigger.old, Trigger.new);
}

