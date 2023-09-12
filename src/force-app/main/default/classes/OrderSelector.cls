public with sharing class OrderSelector {
    
    public static List<Order> selectOrdersByAccountId(Id accountId) {
        return [SELECT OrderNumber, Status, TotalAmount, EffectiveDate,
                    (SELECT Id, ContentDocumentId 
                    FROM AttachedContentDocuments
                    WHERE Title LIKE 'Invoice%' 
                    ORDER BY CreatedDate DESC) 
                FROM Order
                WHERE AccountId = :accountId];
    }

}