@IsTest
private class OrderSelectorTest {
    @IsTest
    static void shouldReturnOrdersById() {
        Account account = TestDataFactory.createAccount(true);
        Order order = TestDataFactory.createOrder(account, true);

        Order foundOrder = OrderSelector.getInstance().getOrderById(order.Id);

        System.assertEquals(order.Id, foundOrder.Id);
    }

    @IsTest
    static void shouldReturnOrdersByAccountId() {
        Account account = TestDataFactory.createAccount(true);
        TestDataFactory.createOrder(account, true);

        List<Order> orders = OrderSelector.getInstance().getOrdersByAccountId(account.Id).values();

        System.assertEquals(1, orders.size());
    }
}