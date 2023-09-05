trigger OrderTrigger on Order (before insert, before update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        OrderTriggerHandler.setOrderTimestamps(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderTriggerHandler.updateOrderTimestamps(Trigger.new, Trigger.oldMap);
    }

}