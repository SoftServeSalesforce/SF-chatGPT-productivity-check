public with sharing class OrderSelector {
    
    public static List<Order> getOrdersByAccountId(Id accountId) {
        return [SELECT Id, OrderNumber, EffectiveDate, Status, TotalAmount 
                FROM Order 
                WHERE AccountId = :accountId];
    }
}
