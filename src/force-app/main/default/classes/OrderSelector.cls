public with sharing class OrderSelector {
    
    public static List<Order> selectOrdersByAccountId(Id accountId) {
        return [SELECT OrderNumber, Status, TotalAmount, EffectiveDate
                FROM Order
                WHERE AccountId = :accountId];
    }

}