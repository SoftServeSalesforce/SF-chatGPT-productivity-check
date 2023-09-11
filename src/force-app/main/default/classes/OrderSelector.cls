public with sharing class OrderSelector {

    public Order[] getOrdersByAccountId(Id accountId) {
        if (accountId == null) {
            return new Order[]{};
        }
        return [
            SELECT 
                Id, OrderNumber, EffectiveDate, Status, TotalAmount, LastStatusChanged__c,
                (
                    SELECT Id, ContentDocument.Title, ContentDocumentId
                    FROM ContentDocumentLinks
                    WHERE ContentDocument.Title LIKE 'invoice%'
                    ORDER BY SystemModstamp DESC
                    LIMIT 1
                )
            FROM Order
            WHERE AccountId = :accountId
        ];
    }

    public Order[] getOrdersByIds(Set<Id> orderIdsSet) {
        if (orderIdsSet == null || orderIdsSet.isEmpty()) {
            return new Order[]{};
        }
        return [
            SELECT 
                Id, OrderNumber, EffectiveDate, Status, TotalAmount, LastStatusChanged__c,
                (
                    SELECT Id, ContentDocument.Title, ContentDocumentId
                    FROM ContentDocumentLinks
                    WHERE ContentDocument.Title LIKE 'invoice%'
                    ORDER BY SystemModstamp DESC
                    LIMIT 1
                )
            FROM Order
            WHERE Id IN :orderIdsSet
        ];
    }

}