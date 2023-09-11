@isTest
private class AccountOrdersControllerTest {

    @isTest static void testOrderOperations() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        PricebookEntry stdPbe = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert stdPbe;

        Pricebook2 customPb = new Pricebook2(Name = 'Custom Price Book', IsActive = true);
        insert customPb;

        PricebookEntry customPbe = new PricebookEntry(Pricebook2Id = customPb.Id, Product2Id = prod.Id, UnitPrice = 100, IsActive = true);
        insert customPbe;

        Order testOrder1 = new Order(AccountId = testAcc.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = customPb.Id);
        Order testOrder2 = new Order(AccountId = testAcc.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = customPb.Id);
        insert new List<Order>{testOrder1, testOrder2};

        OrderItem oi1 = new OrderItem(OrderId = testOrder1.Id, PricebookEntryId = customPbe.Id, Quantity = 1, UnitPrice = 100);
        OrderItem oi2 = new OrderItem(OrderId = testOrder2.Id, PricebookEntryId = customPbe.Id, Quantity = 1, UnitPrice = 100);
        insert new List<OrderItem>{oi1, oi2};

        AccountOrdersController.OrderPage orderPage = AccountOrdersController.getOrders(testAcc.Id, 1, 10);
        System.assertEquals(2, orderPage.totalRecords);

        AccountOrdersController.OrderActionResponse response1 = AccountOrdersController.activateOrderById(testOrder1.Id);
        System.assertEquals('OK', response1.status);

        AccountOrdersController.OrderActionResponse response2 = AccountOrdersController.markAsShippedOrderById(testOrder1.Id);
        System.assertEquals('OK', response2.status);

        AccountOrdersController.OrderActionResponse response3 = AccountOrdersController.activateOrdersByIds(new List<Id>{testOrder2.Id});
        System.assertEquals('OK', response3.status);

        AccountOrdersController.OrderActionResponse response4 = AccountOrdersController.markAsShippedOrdersByIds(new List<Id>{testOrder2.Id});
        System.assertEquals('OK', response4.status);

        Integer pageSize = AccountOrdersController.getPageSize();
        System.assertEquals(10, pageSize);

        String setSizeResponse = AccountOrdersController.setPageSize(20);
        System.assertEquals('OK', setSizeResponse);
        Integer newPageSize = AccountOrdersController.getPageSize();
        System.assertEquals(20, newPageSize);
    }
}