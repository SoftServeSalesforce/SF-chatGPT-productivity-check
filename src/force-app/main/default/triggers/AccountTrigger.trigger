trigger AccountTrigger on Account (before insert, before update) {
    if (Trigger.isInsert) {
        AccountHandler.handleNew(Trigger.new);
    } else if (Trigger.isUpdate) {
        AccountHandler.handleUpdate(Trigger.newMap, Trigger.oldMap);
    }
}
