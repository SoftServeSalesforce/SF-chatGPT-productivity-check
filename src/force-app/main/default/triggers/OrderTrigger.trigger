trigger OrderTrigger on Order (before insert, before update) {
    TriggerHandler.configureHandler(OrderTriggerHandler.class).execute();
}