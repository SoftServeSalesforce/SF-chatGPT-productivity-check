public with sharing class OrderSelector {
    public static Order getOrderStatusById(Id orderId) {
        return [
            SELECT Id, Status 
            FROM Order 
            WHERE Id = :orderId LIMIT 1
        ];
    }

    public static List<Order> getOrdersWithInvoiceInfo(Id accountId) {
        return [
            SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount,  LastStatusChanged__c, 
            (SELECT Id, Title, ContentDocumentId FROM AttachedContentDocuments WHERE Title LIKE 'Invoice%') 
            FROM Order WHERE AccountId = :accountId
        ];
    }
    
}