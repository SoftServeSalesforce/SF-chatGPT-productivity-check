/**
 * @description OrderSelector: Selector to access "Order" SObject records.
 */
public with sharing class OrderSelector {

    @TestVisible
    private static OrderSelector instance;

    public static OrderSelector getInstance() {
        if (instance == null) {
            instance = new OrderSelector();
        }
        return instance;
    }

    public Database.QueryLocator getQueryLocatorToOrdersByParentAccountId(Id accountId) {
        return Database.getQueryLocator([
            SELECT Id, OrderNumber, EffectiveDate, Status, TotalAmount, LastStatusChanged__c
            FROM Order
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY OrderNumber DESC
            LIMIT 10000
        ]);
    }

    public List<Order> getOrdersById(Set<Id> orderIds) {
        return [
            SELECT Id, OrderNumber, Status
            FROM Order
            WHERE Id IN :orderIds
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
    }
}