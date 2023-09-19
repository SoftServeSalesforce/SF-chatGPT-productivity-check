public with sharing class OrderSelector {
    
    public static Integer countOrdersByAccountId(Id accountId) {
        return [SELECT COUNT()
                FROM Order
                WHERE AccountId = :accountId];
    }

    public static List<Order> selectOrdersByAccountId(Id accountId, Integer limitSize, Integer offsetSize) {
        return [SELECT OrderNumber, Status, TotalAmount, EffectiveDate, LastStatusChanged__c,
                    (SELECT Id, ContentDocumentId 
                    FROM AttachedContentDocuments
                    WHERE Title LIKE 'Invoice%' 
                    ORDER BY CreatedDate DESC) 
                FROM Order
                WHERE AccountId = :accountId
                LIMIT :limitSize OFFSET :offsetSize];
    }

    public static List<Order> selectOrdersByIds(List<Id> orderIds) {
        return [SELECT Status
                FROM Order
                WHERE Id IN :orderIds];
    }

}