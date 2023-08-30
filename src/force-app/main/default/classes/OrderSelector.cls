public with sharing class OrderSelector {
    public static OrderSelector newInstance() {
        return new OrderSelector();
    }

    public List<Order> selectOrdersByAccountId(Id accountId) {
        return [
            SELECT Id, OrderNumber, Status, TotalAmount, EffectiveDate
            FROM Order
            WHERE AccountId = :accountId
        ];
    }
}
