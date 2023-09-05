
@IsTest
private class AccountOrdersControllerTest {    
    @IsTest
    static void shouldReturnOrdersByAccountId() {
        Account account = TestDataFactory.createAccount(true);
        Order order = TestDataFactory.createOrder(account, true);

        List<AccountOrdersController.OrderDTO> orderDtos = AccountOrdersController.getOrders(account.Id);

        System.assertEquals(1, orderDtos.size());
        System.assertEquals(orderDtos[0].status, 'Draft');
        System.assertEquals(orderDtos[0].startDate, Date.today());
    }

    @IsTest
    static void shouldThrowExceptionWhenIdIsNull() {
        try {
            AccountOrdersController.getOrders(null);
            System.assert(false);
        } catch (Exception ex) {
            System.assert(true);
        }
    }

    @IsTest
    static void shouldActivateOrder() {
        Account account = TestDataFactory.createAccount(true);
        Product2 product = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(product, true);
        Order order = TestDataFactory.createOrder(account, true);
        TestDataFactory.createOrderItem(order, pricebookEntry, true);

        AccountOrdersController.OrderDTO orderDTO = new AccountOrdersController.OrderDTO(order);
        AccountOrdersController.OrderUpdateResponse response = AccountOrdersController.activateOrder(JSON.serialize(orderDTO));

        System.assertEquals(AccountOrdersController.OK_STATUS, response.status);

        Order updatedOrder = OrderSelector.getInstance().getOrderById(order.Id);
        System.assertEquals('Activated', updatedOrder.Status);
    }

    @IsTest
    static void shouldReturnErrorWhenTryToActivateOrderInWrongStatus() {
        Account account = TestDataFactory.createAccount(true);
        Product2 product = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(product, true);
        Order order = TestDataFactory.createOrder(account, true);
        TestDataFactory.createOrderItem(order, pricebookEntry, true);

        order.Status = 'Activated';
        update order;

        AccountOrdersController.OrderDTO orderDTO = new AccountOrdersController.OrderDTO(order);
        AccountOrdersController.OrderUpdateResponse response = AccountOrdersController.activateOrder(JSON.serialize(orderDTO));

        System.assertEquals(AccountOrdersController.ERROR_STATUS, response.status);
    }

    @IsTest
    static void shouldMarkOrderAsShipped() {
        Account account = TestDataFactory.createAccount(true);
        Product2 product = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(product, true);
        Order order = TestDataFactory.createOrder(account, true);
        TestDataFactory.createOrderItem(order, pricebookEntry, true);

        order.Status = 'Activated';
        update order;

        AccountOrdersController.OrderDTO orderDTO = new AccountOrdersController.OrderDTO(order);
        AccountOrdersController.OrderUpdateResponse response = AccountOrdersController.markOrderAsShipped(JSON.serialize(orderDTO));

        System.assertEquals(AccountOrdersController.OK_STATUS, response.status);

        Order updatedOrder = OrderSelector.getInstance().getOrderById(order.Id);
        System.assertEquals('Shipped', updatedOrder.Status);
    }

    @IsTest
    static void shouldReturnErrorWhenTryToMarkOrderAsShippedInWrongStatus() {
        Account account = TestDataFactory.createAccount(true);
        Product2 product = TestDataFactory.createProduct(true);
        PricebookEntry pricebookEntry = TestDataFactory.createPricebookEntry(product, true);
        Order order = TestDataFactory.createOrder(account, true);
        TestDataFactory.createOrderItem(order, pricebookEntry, true);

        AccountOrdersController.OrderDTO orderDTO = new AccountOrdersController.OrderDTO(order);
        AccountOrdersController.OrderUpdateResponse response = AccountOrdersController.markOrderAsShipped(JSON.serialize(orderDTO));
        
        System.assertEquals(AccountOrdersController.ERROR_STATUS, response.status);
    }
}