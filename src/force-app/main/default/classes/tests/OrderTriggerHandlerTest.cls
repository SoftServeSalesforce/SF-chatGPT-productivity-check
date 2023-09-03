@IsTest
private class OrderTriggerHandlerTest {
    @IsTest
    static void shouldPopulateLastStatusChangedField() {
        Account account = TestDataFactory.createAccount(true);
        Order order = TestDataFactory.createOrder(account, true);
        

        Order updatedOrder1 = OrderSelector.getInstance().getOrderById(order.Id);
        System.assertNotEquals(null, updatedOrder1.LastStatusChanged__c);

        Test.startTest();
        Product2 product = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(product, true);
        TestDataFactory.createOrderItem(order, pricebookEntry, true);

        update new Order(Id = order.Id, Status = 'Activated');
        update new Order(Id = order.Id, Status = 'Shipped');
        update new Order(Id = order.Id, Status = 'Delivered');
        Test.stopTest();

        Order updatedOrder2 = OrderSelector.getInstance().getOrderById(order.Id);
        System.assertNotEquals(null, updatedOrder2.LastStatusChanged__c);
    }
}