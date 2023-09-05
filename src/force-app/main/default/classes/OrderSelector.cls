public with sharing class OrderSelector {
    
    public static List<Order> getOrdersByAccountId(Id accountId, Integer amount, Integer offset) {
        return [SELECT Id, OrderNumber, Status, EffectiveDate, LastStatusChanged__c, TotalAmount, 
        (SELECT Id, Title, ContentDocumentId FROM AttachedContentDocuments 
         WHERE Title LIKE 'Invoice%' ORDER BY CreatedDate DESC) 
        FROM Order WHERE AccountId = :accountId ORDER BY OrderNumber ASC LIMIT :amount OFFSET :offset ];
    }

    public static List<Order> getOrdersForUpdate(List<Id> orderIds) {
        return [SELECT Id, Status, OrderNumber FROM Order WHERE Id IN :orderIds FOR UPDATE];
    }
}
