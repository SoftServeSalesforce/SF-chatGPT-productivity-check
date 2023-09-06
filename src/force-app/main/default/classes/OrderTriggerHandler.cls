public without sharing class OrderTriggerHandler {
    public static void newLastStatusChanged(List<Order> orders, Map<Id, Order> oldMap) {
        for (Order order : orders) {
            if (order.Status != oldMap.get(order.Id).Status) {
                order.LastStatusChanged__c = System.now();
               
            }
        }

       
    }
}