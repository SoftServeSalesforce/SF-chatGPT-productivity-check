trigger OrderTrigger on Order (before insert, before update) {
    OrderTriggerHandler.run(Trigger.new, Trigger.oldMap);
}