@IsTest
private class TestCasesService {
    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        //Verify that instance is null by default.
        CasesService original = CasesService.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        CasesService newInstance = CasesService.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testPreventStatusChangeByNotAnOwner_Positive: Test method needed to ensure
     * that 'preventStatusChangeByNotAnOwner' method of 'CasesService' class does not prevent 
     * Owner from changing Case Status.
     */
    @IsTest
    private static void testPreventStatusChangeByNotAnOwner_Positive() {
        //Setup data.
        Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
        User inactiveUser = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            IsActive = false
        );
        //set inactive user as owner object
        Case newCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = inactiveUser.Id
        );
        Case oldCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = inactiveUser.Id
        );
        List<Case> newRecords = new List<Case> { newCase };
        Map<Id,Case> oldRecords = new Map<Id,Case> { caseId => oldCase };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserSelector userSelector = (UserSelector) mocks.mock(UserSelector.class);
        // mock userSelector.getUsersByIds method
        mocks.startStubbing();
        mocks.when(userSelector.getUsersByIds(new List<Id> {inactiveUser.Id})).thenReturn(new List<User>{inactiveUser});
        mocks.stopStubbing();
        // set mock userSelector in CasesService class
        CasesService.getInstance().userSelector = userSelector;
        //Execute scenario.
        CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(!newCase.hasErrors());
    }

    /**
     * @description testPreventStatusChangeByNotAnOwner_Negative: Test method needed to ensure
     * that 'preventStatusChangeByNotAnOwner' method of 'CasesService' class prevent non-Owner
     * from changing Case Status by adding expected error.
     */
    @IsTest
    private static void testPreventStatusChangeByNotAnOwner_Negative() {
        //Setup data.
        Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
        User activeUser = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            IsActive = true
        );
        Case newCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = activeUser.Id
        );
        Case oldCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = activeUser.Id
        );
        List<Case> newRecords = new List<Case> { newCase };
        Map<Id,Case> oldRecords = new Map<Id,Case> { caseId => oldCase }; 

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserSelector userSelector = (UserSelector) mocks.mock(UserSelector.class);
        // mock userSelector.getUsersByIds method
        mocks.startStubbing();
        mocks.when(userSelector.getUsersByIds(new List<Id> {activeUser.Id})).thenReturn(new List<User>{activeUser});
        mocks.stopStubbing();
        // set mock userSelector in CasesService class
        CasesService.getInstance().userSelector = userSelector;
        //Execute scenario.
        CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(newCase.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newCase.getErrors();
        for (Database.Error error : errors) {
            System.assertEquals(
                Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }

    /**
     * @description testPreventStatusChangeByNotAnOwner_Mixed: Test method needed to
     * ensure that 'preventStatusChangeByNotAnOwner' method of 'CasesService' class
     * adds expected error only when necessary.
     */
    @IsTest
    private static void testPreventStatusChangeByNotAnOwner_Mixed() {
        Id caseIdPositive = fflib_IDGenerator.generate(Case.SObjectType);
        Id caseIdNegative = fflib_IDGenerator.generate(Case.SObjectType);
        User inactiveUser = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            IsActive = false
        );
        User activeUser = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            IsActive = true
        );
        Case newCasePositive = new Case(
            Id = caseIdPositive,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = inactiveUser.Id
        );
        Case newCaseNegative = new Case(
            Id = caseIdNegative,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = activeUser.Id
        );
        Case oldCasePositive = new Case(
            Id = caseIdPositive,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = inactiveUser.Id
        );
        Case oldCaseNegative = new Case(
            Id = caseIdNegative,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = activeUser.Id
        );
        List<Case> newRecords = new List<Case> { 
            newCasePositive,
            newCaseNegative
        };
        Map<Id,Case> oldRecords = new Map<Id,Case> {
            caseIdPositive => oldCasePositive,
            caseIdNegative => oldCaseNegative
        }; 
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserSelector userSelector = (UserSelector) mocks.mock(UserSelector.class);
        mocks.startStubbing();
        mocks.when(userSelector.getUsersByIds(new List<Id> {inactiveUser.Id, activeUser.Id})).thenReturn(new List<User>{inactiveUser, activeUser});
        mocks.stopStubbing();
         // set mock userSelector in CasesService class
         CasesService.getInstance().userSelector = userSelector;

        //Execute scenario.
        CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(!newCasePositive.hasErrors(), Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR);
        System.assert(newCaseNegative.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newCaseNegative.getErrors();
        for (Database.Error error : errors) {
            System.assertEquals(
                Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS,
                error.getMessage(),
                Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
            );
        }
    }
}