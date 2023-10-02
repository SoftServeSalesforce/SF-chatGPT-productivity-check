trigger AccountTrigger on Account (before update) {
    AccountTriggerHandler.getInstance().run(
        Trigger.new,
        Trigger.oldMap,
        Trigger.operationType
    );
}
