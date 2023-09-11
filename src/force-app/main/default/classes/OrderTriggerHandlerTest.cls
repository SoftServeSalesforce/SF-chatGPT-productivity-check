@isTest
private class OrderTriggerHandlerTest {

    @isTest static void testSetOrderTimestamps() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Order testOrder = new Order(AccountId = testAcc.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert testOrder;

        OrderTriggerHandler.setOrderTimestamps(new List<Order>{testOrder});

        System.assertNotEquals(null, testOrder.LastStatusChanged__c);
    }

    @isTest static void testUpdateOrderTimestamps() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Order testOrder = new Order(AccountId = testAcc.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert testOrder;

        Map<Id, Order> oldMap = new Map<Id, Order>{testOrder.Id => testOrder.clone()};
        testOrder.Status = 'Activated';

        OrderTriggerHandler.updateOrderTimestamps(new List<Order>{testOrder}, oldMap);

        System.assertNotEquals(null, testOrder.LastStatusChanged__c);
    }
}
