public with sharing class OrderTriggerHandler {

    public static void handleStatusChange(List<Order> newOrders, Map<Id, Order> oldOrdersMap) {

        for (Order newOrder : newOrders) {
            Order oldOrder = oldOrdersMap.get(newOrder.Id);

            if (oldOrder != null && oldOrder.Status != newOrder.Status) {
                newOrder.LastStatusChanged__c = Datetime.now();
            }
        }
    }
}
