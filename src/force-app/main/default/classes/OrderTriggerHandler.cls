public with sharing class OrderTriggerHandler {
    public static void handleBeforeUpdate(List<Order> oldOrders, List<Order> newOrders) {
        for (Integer i = 0; i < newOrders.size(); i++) {
            Order oldOrder = oldOrders[i];
            Order newOrder = newOrders[i];
            
            if (oldOrder.Status != newOrder.Status) {
                newOrder.LastStatusChanged__c = DateTime.now();
            }
        }
    }
}

