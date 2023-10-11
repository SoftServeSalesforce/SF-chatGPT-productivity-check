trigger AccountTrigger on Account (before insert, before update) {
    AccountTriggerHandler.getInstance().run(
        Trigger.new,
        Trigger.oldMap,
        Trigger.operationType
    );
}


