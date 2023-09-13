public with sharing class OrderSelector {
    
    public static List<Order> selectOrdersByAccountId(Id accountId) {
        return [SELECT OrderNumber, Status, TotalAmount, EffectiveDate, LastStatusChanged__c,
                    (SELECT Id, ContentDocumentId 
                    FROM AttachedContentDocuments
                    WHERE Title LIKE 'Invoice%' 
                    ORDER BY CreatedDate DESC) 
                FROM Order
                WHERE AccountId = :accountId];
    }

    public static List<Order> selectOrdersById(Id orderId) {
        return [SELECT Status
                FROM Order
                WHERE Id = :orderId];
    }

}