@IsTest
private class TestAccountTrigger {
    private static final Integer HANDLER_RUNS_ON_INSERT = 1;
    private static final Integer HANDLER_RUNS_ON_UPDATE = 1;
    private static final Integer HANDLER_RUNS_TOTAL = 
        HANDLER_RUNS_ON_INSERT + HANDLER_RUNS_ON_UPDATE;
    private static final String ACCOUNT_NAME = 'Test Account';
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
        Account acct = new Account(
            Name = ACCOUNT_NAME
        );
        insert acct;
        acct.Active__c = Constants.ACCOUNT_ACTIVE_PICKLIST_NO;
        update acct;
        //Verify outcomes.
        ((AccountTriggerHandler) mocks.verify(
            mockedHandler,
            HANDLER_RUNS_TOTAL
        )).run(
            (List<Account>)fflib_Match.anyList(),
            (Map<Id, Account>)fflib_Match.anyOf(fflib_Match.anyObject(), fflib_Match.isNull()),
            (TriggerOperation)fflib_Match.anyObject()
        );
        delete acct;
    }
}