trigger OrderTrigger on Order (before insert, before update) {
    OrderTriggerHandler.getInstance().run(Trigger.new, Trigger.oldMap, Trigger.operationType);
}