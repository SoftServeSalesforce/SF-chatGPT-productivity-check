public with sharing class OrderSelector {
    
    public static List<Order> selectOrdersByAccountId(Id accountId) {
        return [SELECT Id, Name, OrderNumber, Status, TotalAmount
                FROM Order
                WHERE AccountId = :accountId];
    }
}