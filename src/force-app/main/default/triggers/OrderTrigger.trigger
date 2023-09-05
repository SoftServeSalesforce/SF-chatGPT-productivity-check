trigger OrderTrigger on Order (before insert, before update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            OrderTriggerHandler.getInstance().onBeforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            OrderTriggerHandler.getInstance().onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}