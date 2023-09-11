public with sharing class OrderTriggerHandler {
    public static void updateLastStatusChanged(List<Order> orders, Map<Id, Order> oldMap) {
       

        for (Order order : orders) {         
            // Check if the status field has changed
            if (order.Status != oldMap.get(order.Id).Status) {
                order.LastStatusChanged__c = DateTime.now();
               
            }
        }

       
    }


    public static void insertLastStatusChanged(List<Order> orders) {
        for (Order order : orders) {   
                order.LastStatusChanged__c = DateTime.now();        
            
        }
    }


}
