@IsTest
private class TestCaseTrigger {

    private static final Integer HANDLER_RUNS_ON_INSERT = 0;
    private static final Integer HANDLER_RUNS_ON_UPDATE = 1;
    private static final Integer HANDLER_RUNS_TOTAL = 
        HANDLER_RUNS_ON_INSERT + HANDLER_RUNS_ON_UPDATE;
    
    /**
     * @description test: Test method needed to ensure that
     * 'CaseTriggerHandler' class is executed when expected.
     */
    @IsTest
    private static void testHandlerExecution() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CaseTriggerHandler mockedHandler = (CaseTriggerHandler) mocks.mock(CaseTriggerHandler.class);
        CaseTriggerHandler.instance = mockedHandler;
        //Execute scenario.
        Case c = new Case(
            Origin = Constants.CASE_ORIGIN_WEB
        );
        insert c;
        c.Status = Constants.CASE_STATUS_CLOSED;
        update c;
        //Verify outcomes.
        ((CaseTriggerHandler) mocks.verify(
            mockedHandler,
            HANDLER_RUNS_TOTAL
        )).run(
            (List<Case>)fflib_Match.anyList(),
            (Map<Id,Case>)fflib_Match.anyObject(),
            (TriggerOperation)fflib_Match.anyObject()
        );
        delete c;
    }
}