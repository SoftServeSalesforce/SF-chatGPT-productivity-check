
@IsTest
private class AccountOrdersControllerTest {
    @IsTest
    static void shouldReturnOrdersByAccountId() {
        Account account = TestDataFactory.createAccount(true);
        Contract contract = TestDataFactory.createContract(account, true);
        TestDataFactory.createOrder(account, contract, true);

        List<AccountOrdersController.OrderDTO> orderDtos = AccountOrdersController.getOrders(account.Id);

        System.assertEquals(1, orderDtos.size());
        System.assertEquals(orderDtos[0].status, 'Draft');
        System.assertEquals(orderDtos[0].startDate, Date.today());
    }

    @IsTest
    static void shouldThrowExceptionWhenIdIsNull() {
        try {
            List<AccountOrdersController.OrderDTO> orderDtos = AccountOrdersController.getOrders(null);
            System.assert(false);
        } catch (Exception ex) {
            System.assert(true);
        }
    }
}