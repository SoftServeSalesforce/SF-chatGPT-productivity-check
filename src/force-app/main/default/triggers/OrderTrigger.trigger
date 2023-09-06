trigger OrderTrigger on Order (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {      
            OrderTriggerHandler.newLastStatusChanged(Trigger.new, Trigger.oldMap);       
    }
}