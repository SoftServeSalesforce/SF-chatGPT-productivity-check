public with sharing class OrderTriggerService {

    public static void handleLastStatusChanged(List<Order> newOrders, Map<Id, Order> oldOrders) {
        for(Order order : newOrders) {
            if(order.Status != oldOrders.get(order.Id).Status) {
                order.LastStatusChanged__c = Datetime.now();
            }
        }
    }   
}