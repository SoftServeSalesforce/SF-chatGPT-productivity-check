public with sharing class OrderTriggerHandler {
    
    public static void beforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        OrderTriggerService.handleLastStatusChanged(newOrders, oldOrders);
    }
}