@IsTest
private class TestAccountTrigger {
    private static final Integer HANDLER_RUNS_ON_INSERT = 1;
    private static final Integer HANDLER_RUNS_ON_UPDATE = 1;
    private static final Integer HANDLER_RUNS_TOTAL = 
        HANDLER_RUNS_ON_INSERT + HANDLER_RUNS_ON_UPDATE;
   
    /**
     * @description test: Test method needed to ensure that
     * 'AccountTriggerHandler' class is executed when expected.
     */
    @IsTest
    private static void testHandlerExecution() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountTriggerHandler mockedHandler = (AccountTriggerHandler) mocks.mock(AccountTriggerHandler.class);
        AccountTriggerHandler.instance = mockedHandler;
        //Execute scenario.
        Account acc = new Account(
            Name = Constants.TEST_ACCOUNT
        );
        insert acc;
        acc.Active__c = Constants.ACCOUNT_INACTIVE;
        update acc;
        //Verify outcomes.
        ((AccountTriggerHandler) mocks.verify(
            mockedHandler,
            HANDLER_RUNS_TOTAL
        )).run(
            (List<Account>)fflib_Match.anyList(),
            (Map<Id, Account>)fflib_Match.anyOf(fflib_Match.anyObject(), fflib_Match.isNull()),
            (TriggerOperation)fflib_Match.anyObject()
        );
        delete acc;
    }
}