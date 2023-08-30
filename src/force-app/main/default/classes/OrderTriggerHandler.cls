public with sharing class OrderTriggerHandler {
    
    public static void handleStatusChange(List<Order> oldOrders, List<Order> newOrders) {
        for (Integer i = 0; i < newOrders.size(); i++) {
            if (oldOrders[i].Status != newOrders[i].Status) {
                newOrders[i].LastStatusChanged__c = System.now();
            }
        }
    }
}