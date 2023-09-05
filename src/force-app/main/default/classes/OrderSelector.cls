public with sharing class OrderSelector {

    public Order[] getOrdersByAccountId(Id accountId) {
        if (null == accountId) {
            return new Order[]{};
        }
        return [
                SELECT OrderNumber, EffectiveDate, Status, TotalAmount, LastStatusChanged__c, (
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
        if (null == orderIdsSet || orderIdsSet.isEmpty()) {
            return new Order[]{};
        }
        return [
                SELECT Status, OrderNumber
                FROM Order
                WHERE Id IN :orderIdsSet
        ];
    }

}