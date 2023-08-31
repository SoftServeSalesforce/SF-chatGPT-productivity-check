public with sharing class OrderSelector {

    public static List<Order> getOrdersWithAttachmentsByAccountId(Id accountId) {
        return [SELECT Id, EffectiveDate, OrderNumber, Status, TotalAmount,        
        (SELECT ContentDocumentId FROM AttachedContentDocuments 
         WHERE Title LIKE 'Invoice%' ORDER BY CreatedDate DESC) 
        FROM Order WHERE AccountId = :accountId];
    }

    public static Order getOrderById(Id orderId) {
        return [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
    }
}