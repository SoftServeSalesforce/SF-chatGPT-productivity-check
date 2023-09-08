@IsTest
public with sharing class TestOrderTrigger {
    @IsTest
    private static void test() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderTriggerHandler handlerMock = (OrderTriggerHandler)mocks.mock(OrderTriggerHandler.class);
        OrderTriggerHandler.instance = handlerMock;
        Account acc = new Account(
            Name = 'Test'
        );
        insert acc;
        Contract c = new Contract(
            AccountId = acc.Id,
            Status = Constants.CONTRACT_STATUS_DRAFT,
            ContractTerm = 12,
            StartDate = Date.today()
        );
        insert c;
        Order o = new Order(
            ContractId = c.Id,
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = Constants.ORDER_STATUS_DRAFT
        );
        insert o;
        update o;
        System.assertNotEquals(null, o.Id);
    }
}