@IsTest
private class TestAccountTrigger {

    private static final Integer HANDLER_RUNS_ON_UPDATE = 1;
    private static final Integer HANDLER_RUNS_TOTAL = HANDLER_RUNS_ON_UPDATE;

    /**
     * @description testHandlerExecution: Test method needed to ensure that
     * 'AccountTriggerHandler' class is executed when expected.
     */
    @IsTest
    private static void testHandlerExecution() {
        // Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountTriggerHandler mockedHandler = (AccountTriggerHandler) mocks.mock(AccountTriggerHandler.class);
        AccountTriggerHandler.instance = mockedHandler;

        // Execute scenario.
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        acc.Name = 'Updated Test Account';
        update acc;

        // Verify outcomes.
        ((AccountTriggerHandler) mocks.verify(
            mockedHandler,
            HANDLER_RUNS_TOTAL
        )).run(
            (List<Account>) fflib_Match.anyList(),
            (Map<Id, Account>) fflib_Match.anyObject(),
            (TriggerOperation) fflib_Match.anyObject()
        );

        delete acc;
    }
}