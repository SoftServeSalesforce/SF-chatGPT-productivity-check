trigger OrderTrigger on Order (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {      
            OrderTriggerHandler.updateLastStatusChanged(Trigger.new, Trigger.oldMap);       
    }
}
