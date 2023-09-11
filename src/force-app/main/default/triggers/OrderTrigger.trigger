trigger OrderTrigger on Order (before insert,before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {      
            OrderTriggerHandler.updateLastStatusChanged(Trigger.new, Trigger.oldMap);       
    }

    if (Trigger.isBefore && Trigger.isInsert) {  
        OrderTriggerHandler.insertLastStatusChanged(Trigger.new);    
    }
}
