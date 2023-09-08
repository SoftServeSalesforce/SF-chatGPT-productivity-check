@IsTest
public with sharing class TestOrderSelector {
    @IsTest
    private static void getQueryLocatorToOrdersByParentAccountIdTest() {
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Database.QueryLocator actual = OrderSelector.getInstance().getQueryLocatorToOrdersByParentAccountId(accId);
        System.assertNotEquals(null, actual);
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