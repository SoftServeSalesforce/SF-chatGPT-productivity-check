@IsTest
public with sharing class OrderSelectorTest {
    
    private static final Integer RECORDS_AMOUNT = 10; 

    @TestSetup
    static void makeData(){
        Account acct = TestDataFactory.createAccount('Test');
        Contract contr = TestDataFactory.createContract(acct.Id);
        TestDataFactory.createOrders(acct.Id, contr.Id, RECORDS_AMOUNT);
    }

    @IsTest
    static void testGetOrdersByAccountIdReturnOrders() {
        Account acct = fetchAccount();
        Test.startTest();
        List<Order> testOrders = OrderSelector.getOrdersByAccountId(acct.Id, RECORDS_AMOUNT, 0);
        Assert.areEqual(RECORDS_AMOUNT, testOrders.size(), 'Unexpected amount of records returned');
        Test.stopTest();
    }

    @IsTest
    static void testGetOrdersForUpdateReturnOrders() {
        List<Id> orderIds = fetchOrderIds();
        Test.startTest();
        List<Order> testOrders = OrderSelector.getOrdersForUpdate(orderIds);
        Assert.areEqual(orderIds.size(), testOrders.size(), 'Unexpected amount of records returned');
        Test.stopTest();
    }

    private static Account fetchAccount() {
        return [SELECT Id FROM Account LIMIT 1];
    }

    private static List<Id> fetchOrderIds() {
        return new List<Id> (new Map<Id, Order> ([SELECT Id FROM Order LIMIT :RECORDS_AMOUNT]).keySet());
    }

}