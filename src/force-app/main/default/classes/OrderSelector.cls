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

    public Map<Id, Order> getOrdersByAccountId(Id accountId) {
        return new Map<Id, Order>([
            SELECT OrderNumber, EffectiveDate, Status, TotalAmount
            FROM Order
            WHERE AccountId = :accountId
        ]);
    }
}