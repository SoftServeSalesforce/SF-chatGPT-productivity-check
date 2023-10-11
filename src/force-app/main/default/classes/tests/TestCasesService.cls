@IsTest
private class TestCasesService {
    // Case Mock Fields
    private static final String CASE_OWNER_LOOKUP_FIELD_NAME = 'Owner';
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
        //Stub selector.
        stubCaseSelectorWithUserMock(oldRecords, true);
        //Execute scenario.
        CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(!newCase.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
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
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
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
        //Stub selector.
        stubCaseSelectorWithUserMock(oldRecords, true);
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
        //Setup data.
        Id caseIdPositive = fflib_IDGenerator.generate(Case.SObjectType);
        Id caseIdNegative = fflib_IDGenerator.generate(Case.SObjectType);
        Id ownerIdPositive = UserInfo.getUserId();
        Id ownerIdNegative = fflib_IDGenerator.generate(User.SObjectType);
        Case newCasePositive = new Case(
            Id = caseIdPositive,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = ownerIdPositive
        );
        Case newCaseNegative = new Case(
            Id = caseIdNegative,
            Status = Constants.CASE_STATUS_NEW,
            OwnerId = ownerIdNegative
        );
        Case oldCasePositive = new Case(
            Id = caseIdPositive,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = ownerIdPositive
        );
        Case oldCaseNegative = new Case(
            Id = caseIdNegative,
            Status = Constants.CASE_STATUS_CLOSED,
            OwnerId = ownerIdNegative
        );
        List<Case> newRecords = new List<Case> { 
            newCasePositive,
            newCaseNegative
        };
        Map<Id,Case> oldRecords = new Map<Id,Case> {
            caseIdPositive => oldCasePositive,
            caseIdNegative => oldCaseNegative
        };
        //Stub selector.
        stubCaseSelectorWithUserMock(oldRecords, true);
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

    /**
     * @description testAllowStatusChange_When_OwnerIsInactive: Test method needed to
     * ensure that 'preventStatusChangeByNotAnOwner' method of 'CasesService' class
     * does not prevent Owner from changing Case Status when Owner is inactive.
     */
    @IsTest
    private static void testAllowStatusChange_When_OwnerIsInactive() {
        //Setup data.
        Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
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
        //Stub selector.
        stubCaseSelectorWithUserMock(oldRecords, false);
        //Execute scenario.
        CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        //Verify outcomes.
        System.assert(!newCase.hasErrors(), Constants.ERROR_RECORD_SHOULD_NOT_BE_ERRORED);
    }

    /*
    * @description stubCaseSelectorWithUserMock: Helper method needed to stub
    * 'CaseSelector' selector with 'User' mock.
    * @param oldRecords: Map<Id, Case> - Map of old Case records.
    */
    private static void stubCaseSelectorWithUserMock(Map<Id, Case> oldRecords, Boolean isUserActive) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Case[] mockCases = new List<Case>();
        Map<Id, User> mockUsers = new Map<Id, User>();
        for(Case cs: oldRecords.values()) {
            if (!mockUsers.containsKey(cs.OwnerId)) {
                mockUsers.put(cs.OwnerId, new User(
                    Id = cs.OwnerId,
                    IsActive = isUserActive
                ));
            }
            User mockUser = mockUsers.get(cs.OwnerId);
            Case mockCaseWithUser = (Case) fflib_ApexMocksUtils.setReadOnlyFields(cs, Case.class, new Map<String, Object> {
                CASE_OWNER_LOOKUP_FIELD_NAME => mockUser
            });
            mockCases.add(mockCaseWithUser);
        }
        
        CaseSelector mockCaseSelector = (CaseSelector) mocks.mock(CaseSelector.class);
        CaseSelector.instance = mockCaseSelector;
        mocks.startStubbing();
        mocks.when(mockCaseSelector.getCasesWithOwnerStatusByIds(oldRecords.keySet())).thenReturn(mockCases);
        mocks.stopStubbing();
    }
}