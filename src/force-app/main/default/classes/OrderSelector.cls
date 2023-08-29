public with sharing class OrderSelector {
    
    public static List<Order> getOrdersByAccountId(Id accountId) {
        return [SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount,
        (SELECT Id, Title, ContentDocumentId FROM AttachedContentDocuments 
         WHERE Title LIKE 'Invoice%' ORDER BY CreatedDate DESC) 
        FROM Order WHERE AccountId = :accountId];
    }

    public static Order getOrderForUpdate(Id orderId) {
        return [SELECT Id, Status FROM Order WHERE Id = :orderId FOR UPDATE];
    }
}
