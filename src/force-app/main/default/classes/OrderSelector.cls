/**
 * @description OrderSelector: Apex Class used to access "Order" SObject records.
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

    /**
     * @description getOrdersByAccountId: Method used to query records 
     * of the "Order" SObject with given value specified for "AccountId" lookup.
     * @param accountId: Id of a parent "Account" record.
     * @return: List of the "Order" records which match filter criteria OR empty list.
     */
    public List<Order> getOrdersByParentAccountId(Id accountId) {
        return [
            SELECT Id, OrderNumber, EffectiveDate, Status, TotalAmount, LastStatusChanged__c
            FROM Order
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate DESC
        ];
    }

    /**
     * @description getOrdersById: Method used to query records 
     * of the "Order" SObject with given value specified for "Id" field.
     * @param orderIds: Scope.
     * @return: Orders with given Ids.
     */
    public List<Order> getOrdersById(Set<Id> orderIds) {
        return [
            SELECT Id, OrderNumber, Status
            FROM Order
            WHERE Id IN :orderIds
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate DESC
        ]; 
    }
}