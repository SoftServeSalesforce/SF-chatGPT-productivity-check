public with sharing class OrderSelector {

    public static List<Order> getOrdersWithAttachmentsByAccountId(Id accountId) {
        return [SELECT Id, EffectiveDate, OrderNumber, Status, TotalAmount 
        FROM Order WHERE AccountId = :accountId];
    }
}