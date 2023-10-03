@IsTest
private class TestAccountTrigger {
    private static final Integer HANDLER_RUNS_ON_INSERT = 0;
    private static final Integer HANDLER_RUNS_ON_UPDATE = 1;
    private static final Integer HANDLER_RUNS_TOTAL = 
        HANDLER_RUNS_ON_INSERT + HANDLER_RUNS_ON_UPDATE;
    
    @IsTest
    private static void testHandlerExecution() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountTriggerHandler mockedHandler = (AccountTriggerHandler) mocks.mock(AccountTriggerHandler.class);
        AccountTriggerHandler.instance = mockedHandler;

        Account a = new Account(
            Name = 'Test Account'
        );
        insert a;
        a.Name = 'Test Updated Account';
        update a;

        ((AccountTriggerHandler) mocks.verify(
            mockedHandler,
            HANDLER_RUNS_TOTAL
        )).run(
            (List<Account>)fflib_Match.anyList(),
            (Map<Id,Account>)fflib_Match.anyObject(),
            (TriggerOperation)fflib_Match.anyObject()
        );
        delete a;
    }
}
