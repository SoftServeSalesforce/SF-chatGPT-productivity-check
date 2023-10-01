@IsTest
private class TestAccountTrigger {

    @IsTest
    private static void testExecution() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountTriggerHandler mockedHandler = (AccountTriggerHandler) mocks.mock(AccountTriggerHandler.class);
        AccountTriggerHandler.instance = mockedHandler;

        Account acc = new Account(Name = 'Test');
        insert acc;
        
        ((AccountTriggerHandler) mocks.verify(mockedHandler, 0)).run(
            (List<Account>) fflib_Match.anyList(),
            (Map<Id,Account>) fflib_Match.anyObject(),
            (TriggerOperation) fflib_Match.anyObject()
        );
    }
}