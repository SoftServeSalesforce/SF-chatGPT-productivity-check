public with sharing class OrderSelector {
    public static OrderSelector newInstance() {
        return new OrderSelector();
    }

    public List<Order> selectDraftOrderById(Id orderId) {
        return [
            SELECT Id, Status
            FROM Order
            WHERE Id = :orderId AND Status = 'Draft' 
            LIMIT 1
            FOR UPDATE
        ];
    }

    public List<Order> selectActiveOrderById(Id orderId) {
        return [
            SELECT Id, Status
            FROM Order
            WHERE Id = :orderId AND Status = 'Activated' 
            LIMIT 1
            FOR UPDATE
        ];
    }

    public List<Order> selectOrdersByAccountId(Id accountId) {
        return [
            SELECT Id, Status, EffectiveDate, OrderNumber, TotalAmount, LastStatusChanged__c, CreatedDate,
                   (SELECT ContentDocumentId
                    FROM AttachedContentDocuments 
                    WHERE ContentDocument.Title LIKE 'Invoice%' 
                    ORDER BY ContentDocument.CreatedDate DESC 
                    LIMIT 1)
            FROM Order
            WHERE AccountId = :accountId
        ];
    }
}
