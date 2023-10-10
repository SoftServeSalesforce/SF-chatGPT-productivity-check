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
        Id ownerId = UserInfo.getUserId();
        Case newCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = ownerId
        );
        Case oldCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = ownerId
        );
        List<Case> newRecords = new List<Case> { newCase };
        Map<Id,Case> oldRecords = new Map<Id,Case> { caseId => oldCase }; 
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
        // Setup data.
        Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
        User owner = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            IsActive = true
        );
    
        // Create mock objects using fflib_ApexMocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserSelector mockUserSelector = (UserSelector) mocks.mock(UserSelector.class);
    
        // Set up expectations and responses for the mock.
        Set<Id> userIds = new Set<Id> { owner.Id };
        List<User> activeUsers = new List<User> { owner };
    
        // Expect a call to getActiveUsers with userIds and return activeUsers.
        mocks.startStubbing();
        mocks.when(mockUserSelector.getActiveUsers(userIds)).thenReturn(activeUsers);
        mocks.stopStubbing();
    
        // Replace the real instance with the mock instance in UserSelector.
        UserSelector.instance = mockUserSelector;
    
        // Create CasesService instance with the mocked UserSelector behavior.
        CasesService casesService = new CasesService();
    
        Case newCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = owner.Id
        );
        Case oldCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = owner.Id
        );
        List<Case> newRecords = new List<Case> { newCase };
        Map<Id, Case> oldRecords = new Map<Id, Case> { caseId => oldCase };
    
        // Execute scenario.
        Test.startTest();
        casesService.preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        Test.stopTest();
    
        // Verify outcomes.
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
        // Setup data.
        Id caseIdPositive = fflib_IDGenerator.generate(Case.SObjectType);
        Id caseIdNegative = fflib_IDGenerator.generate(Case.SObjectType);
    
        // Create mock objects using fflib_ApexMocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserSelector mockUserSelector = (UserSelector) mocks.mock(UserSelector.class);
    
        // Set up expectations and responses for the mock.
        User ownerPositive = new User(
            Id = UserInfo.getUserId(),
            IsActive = true
        );
        User ownerNegative = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            IsActive = true
        );
        
        Set<Id> userIds = new Set<Id> { ownerPositive.Id, ownerNegative.Id };
        List<User> activeUsers = new List<User> { ownerPositive, ownerNegative };
    
        // Expect a call to getActiveUsers with userIds and return activeUsers.
        mocks.startStubbing();
        mocks.when(mockUserSelector.getActiveUsers(userIds)).thenReturn(activeUsers);
        mocks.stopStubbing();
    
        // Replace the real instance with the mock instance in UserSelector.
        UserSelector.instance = mockUserSelector;
    
        // Create CasesService instance with the mocked UserSelector behavior.
        CasesService casesService = new CasesService();
    
        Case newCasePositive = new Case(
            Id = caseIdPositive,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = ownerPositive.Id
        );
        Case newCaseNegative = new Case(
            Id = caseIdNegative,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = ownerNegative.Id
        );
        Case oldCasePositive = new Case(
            Id = caseIdPositive,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = ownerPositive.Id
        );
        Case oldCaseNegative = new Case(
            Id = caseIdNegative,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = ownerNegative.Id
        );
        List<Case> newRecords = new List<Case> { 
            newCasePositive,
            newCaseNegative
        };
        Map<Id, Case> oldRecords = new Map<Id, Case> {
            caseIdPositive => oldCasePositive,
            caseIdNegative => oldCaseNegative
        };
    
        // Execute scenario.
        Test.startTest();
        casesService.preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        Test.stopTest();
    
        // Verify outcomes.
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
    
    /**
     * @description testPreventStatusChangeByNotAnOwner_Inactive: Test method needed to ensure
     * that 'preventStatusChangeByNotAnOwner' method of 'CasesService' class allows inactive
     * owners to change Case Status without adding any expected error.
     */
    @IsTest
    private static void testPreventStatusChangeByNotAnOwner_Inactive() {
        // Setup data.
        Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
        User owner = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType),
            IsActive = false // Inactive user
        );
        
        // Create mock objects using fflib_ApexMocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        UserSelector mockUserSelector = (UserSelector) mocks.mock(UserSelector.class);

        // Set up expectations and responses for the mock.
        Set<Id> userIds = new Set<Id> { owner.Id };
        List<User> activeUsers = new List<User>(); // Empty list, indicating an inactive user.

        // Expect a call to getActiveUsers with userIds and return activeUsers.
        mocks.startStubbing();
        mocks.when(mockUserSelector.getActiveUsers(userIds)).thenReturn(activeUsers);
        mocks.stopStubbing();

        // Replace the real instance with the mock instance in UserSelector.
        UserSelector.instance = mockUserSelector;

        // Create CasesService instance with the mocked UserSelector behavior.
        CasesService casesService = new CasesService();

        Case newCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = owner.Id
        );
        Case oldCase = new Case(
            Id = caseId,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = owner.Id
        );
        List<Case> newRecords = new List<Case> { newCase };
        Map<Id, Case> oldRecords = new Map<Id, Case> { caseId => oldCase };

        // Execute scenario.
        Test.startTest();
        casesService.preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        Test.stopTest();

        // Verify outcomes.
        System.assert(!newCase.hasErrors(), 'No errors should be thrown for an inactive owner.');
    }
}