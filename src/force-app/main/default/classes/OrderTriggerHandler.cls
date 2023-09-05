public with sharing class OrderTriggerHandler extends TriggerHandler {

    protected override void beforeInsert() {
        setOrderTimestamps(Trigger.new);
    }

    protected override void beforeUpdate() {
        updateOrderTimestamps((Map<Id, Order>) Trigger.oldMap, (Map<Id, Order>) Trigger.newMap);
    }

    private static void setOrderTimestamps(Order[] orders) {
        for (Order order : orders) {
            order.LastStatusChanged__c = Datetime.now();
        }
    }

    private static void updateOrderTimestamps(Map<Id, Order> oldMap, Map<Id, Order> newMap) {
        for (Order order : newMap.values()) {
            if (oldMap.get(order.Id).Status != order.Status) {
                order.LastStatusChanged__c = Datetime.now();
            }
        }
    }

}