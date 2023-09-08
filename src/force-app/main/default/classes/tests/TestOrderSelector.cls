@IsTest
public with sharing class TestOrderSelector {
    @IsTest
    private static void getQueryLocatorToOrdersByParentAccountIdTest() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Database.QueryLocator expected = Database.getQueryLocator([
            SELECT Id, OrderNumber, EffectiveDate, Status, TotalAmount, LastStatusChanged__c
            FROM Order
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
            LIMIT 10000
        ]);
        Database.QueryLocator actual = OrderSelector.getInstance().getQueryLocatorToOrdersByParentAccountId(accountId);
    }

    @IsTest
    private static void getOrdersByIdTest() {
        Set<Id> orderIds = new Set<Id> { fflib_IDGenerator.generate(Order.SObjectType) };
        List<Order> expected = [
            SELECT Id, OrderNumber, Status
            FROM Order
            WHERE Id IN :orderIds
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate ASC
        ];
        List<Order> actual = OrderSelector.getInstance().getOrdersById(orderIds);
        System.assertEquals(expected, actual);
    }
}