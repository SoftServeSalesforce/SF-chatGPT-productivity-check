public with sharing class OrderSelector {
    private static OrderSelector instance;
    
    private OrderSelector() {

    }

    public static OrderSelector getInstance() {
        if (instance == null) {
            instance = new OrderSelector();
        }
        return instance; 
    }

    public Order getOrderById(Id orderId) {
        return [
            SELECT OrderNumber, EffectiveDate, Status, TotalAmount, IsShipped__c
            FROM Order
            WHERE Id = :orderId
        ];
    }

    public Map<Id, Order> getOrdersByAccountId(Id accountId) {
        return new Map<Id, Order>([
            SELECT OrderNumber, EffectiveDate, Status, TotalAmount, IsShipped__c,
            (
                SELECT Title
                FROM CombinedAttachments
                WHERE Title LIKE 'Invoice%'
                ORDER BY CreatedDate DESC
                LIMIT 1
            )
            FROM Order
            WHERE AccountId = :accountId
        ]);
    }
}