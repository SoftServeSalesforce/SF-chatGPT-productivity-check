public with sharing class OrderSelector {

    public static List<Order> getOrdersWithAttachmentsByAccountId(Id accountId) {
        return [SELECT Id, EffectiveDate, OrderNumber, Status, TotalAmount, LastStatusChanged__c,        
        (SELECT Id, ContentDocumentId FROM AttachedContentDocuments 
         WHERE Title LIKE 'Invoice%' ORDER BY CreatedDate DESC) 
        FROM Order WHERE AccountId = :accountId];
    }

    public static Integer getOrderCountByAccountId(Id accountId) {
        return [SELECT COUNT() FROM Order WHERE AccountId = :accountId];
    }

    public static Order getOrderById(Id orderId) {
        return [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
    }

    public static List<Order> getOrdersByIds(List<Id> orderIds) {
        return [SELECT Id, Status FROM Order WHERE Id IN :orderIds FOR UPDATE];        
    }

    public static List<Order> getOrdersWithAttachmentsByAccountId(Id accountId, Integer limitSize, Integer offsetSize) {
        return [SELECT Id, EffectiveDate, OrderNumber, Status, TotalAmount, LastStatusChanged__c,
        (SELECT Id, ContentDocumentId FROM AttachedContentDocuments 
         WHERE Title LIKE 'Invoice%' ORDER BY CreatedDate DESC) 
        FROM Order WHERE AccountId = :accountId
        LIMIT :limitSize OFFSET :offsetSize];
    }
}