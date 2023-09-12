public with sharing class OrderSelector {
    public static OrderSelector newInstance() {
        return new OrderSelector();
    }

    public List<Order> selectDraftOrderById(List<Id> orderIds) {
        return [
            SELECT Id, Status
            FROM Order
            WHERE Id IN :orderIds AND Status = 'Draft' 
            FOR UPDATE
        ];
    }

    public List<Order> selectActiveOrderById(List<Id> orderIds) {
        return [
            SELECT Id, Status
            FROM Order
            WHERE Id IN :orderIds AND Status = 'Activated' 
            FOR UPDATE
        ];
    }

    public List<Order> selectOrdersByAccountId(Id accountId, Integer limitSize, Integer offsetSize) {
        return [
            SELECT Id, Status, EffectiveDate, OrderNumber, TotalAmount, LastStatusChanged__c, CreatedDate,
                   (SELECT ContentDocumentId
                    FROM AttachedContentDocuments 
                    WHERE ContentDocument.Title LIKE 'Invoice%' 
                    ORDER BY ContentDocument.CreatedDate DESC 
                    LIMIT 1)
            FROM Order
            WHERE AccountId = :accountId
            LIMIT :limitSize
            OFFSET :offsetSize
        ];
    }

    public Integer countOrdersByAccounId(Id accountId) {
       AggregateResult agg = [SELECT COUNT(Id) total
                                FROM Order
                                WHERE AccountId = :accountId
       ];
       Integer totalOrders = (Integer)agg.get('total');
    return totalOrders; 
    }

    public OrderPageSize__c selectUserPageSize() {
        return [SELECT Page_Size__c
                FROM OrderPageSize__c
                WHERE SetupOwnerId = :UserInfo.getUserId()
                LIMIT 1];
    }
}
