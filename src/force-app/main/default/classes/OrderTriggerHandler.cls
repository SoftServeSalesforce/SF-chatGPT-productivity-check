public with sharing class OrderTriggerHandler {

    public static void setOrderTimestamps(Order[] orders) {
        for (Order order : orders) {
            order.LastStatusChanged__c = Datetime.now();
        }
    }

    public static void updateOrderTimestamps(Order[] orders, Map<Id, Order> oldMap) {
        for (Order order : orders) {
            if (oldMap.get(order.Id).Status != order.Status) {
                order.LastStatusChanged__c = Datetime.now();
            }
        }
    }

}