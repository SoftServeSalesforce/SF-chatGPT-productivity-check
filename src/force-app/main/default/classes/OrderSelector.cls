public with sharing class OrderSelector {
    public static Order getOrderStatusById(Id orderId) {
        if (!Schema.sObjectType.Order.fields.Status.isUpdateable()) {
            return null;
        }

        return [
            SELECT Id, Status 
            FROM Order 
            WHERE Id = :orderId LIMIT 1
        ];
    }

    public static List<Order> getOrdersByIds(List<Id> orderIds) {
        if (!Schema.sObjectType.Order.fields.Status.isUpdateable()) {
            return null;
        }

        return [
            SELECT Id, Status 
            FROM Order 
            WHERE Id IN :orderIds 
        ];        
    }

    public static List<Order> getOrdersWithInvoiceInfo(Id accountId) {
        return [
            SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount, CreatedDate,  LastStatusChanged__c, 
                (SELECT Id, Title, ContentDocumentId 
                FROM AttachedContentDocuments 
                WHERE Title LIKE 'Invoice%') 
            FROM Order 
            WHERE AccountId = :accountId
            ORDER BY CreatedDate DESC
        ];
    }

    public static List<Order> getOrdersWithInvoiceInfo(Id accountId, Integer pageSize, Integer offsetSize) {
        return [
            SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount, CreatedDate, LastStatusChanged__c, 
                (SELECT Id, Title, ContentDocumentId 
                 FROM AttachedContentDocuments 
                 WHERE Title LIKE 'Invoice%') 
            FROM Order 
            WHERE AccountId = :accountId
            ORDER BY CreatedDate DESC
            LIMIT :pageSize OFFSET :offsetSize
        ];
    }

    public static Integer getOrderCountByAccountId(Id accountId) {
        return [
            SELECT COUNT() 
            FROM Order 
            WHERE AccountId = :accountId
        ];
    }
}