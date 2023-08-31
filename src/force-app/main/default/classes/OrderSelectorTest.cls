@IsTest
private class OrderSelectorTest {
    @IsTest
    static void shouldReturnOrdersByAccountId() {
        Account account = TestDataFactory.createAccount(true);
        Contract contract = TestDataFactory.createContract(account, true);
        TestDataFactory.createOrder(account, contract, true);

        List<Order> orders = OrderSelector.getInstance().getOrdersByAccountId(account.Id).values();

        System.assertEquals(1, orders.size());
    }
}