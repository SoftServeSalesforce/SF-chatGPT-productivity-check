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

    @IsTest
    private static void testPreventStatusChangeByNotAnOwner_InactiveOwner_Positive() {
        User inactiveUser = createUser(false);
        insert inactiveUser;

        Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
        Case oldCase = new Case(
            Id = caseId,
            OwnerId = inactiveUser.Id,
            Status = Constants.CASE_STATUS_NEW
        );
        Case newCase = new Case(
            Id = caseId,
            OwnerId = inactiveUser.Id,
            Status = Constants.CASE_STATUS_CLOSED
        );
        Map<Id, Case> oldRecords = new Map<Id, Case> { caseId => oldCase };
        List<Case> newRecords = new List<Case>{ newCase };
        
        CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        System.assert(!newCase.hasErrors());
    }

    @isTest
    private static void testPreventStatusChangeByNotAnOwner_InactiveOwner_Negative() {
        User activeUser = createUser(true);
        insert activeUser;

        Id caseId = fflib_IDGenerator.generate(Case.SObjectType);
        Case oldCase = new Case(
            Id = caseId,
            OwnerId = activeUser.Id,
            Status = Constants.CASE_STATUS_NEW
        );
        Case newCase = new Case(
            Id = caseId,
            OwnerId = activeUser.Id,
            Status = Constants.CASE_STATUS_CLOSED
        );
        Map<Id, Case> oldRecords = new Map<Id, Case> { caseId => oldCase };
        List<Case> newRecords = new List<Case>{ newCase };
        
        CasesService.getInstance().preventStatusChangeByNotAnOwner(newRecords, oldRecords);
        System.assert(newCase.hasErrors(), Constants.ERROR_RECORD_SHOULD_BE_ERRORED);
        List<Database.Error> errors = newCase.getErrors();
        System.assertEquals(
            Constants.ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS,
            errors[0].getMessage(),
            Constants.ERROR_RECORD_HAS_UNEXPECTED_ERROR
        );
    }

    private static User createUser(Boolean isActive) {
        Id adminProfileId = getAdminProfileId();
        return new User(
            FirstName = 'Test',
            LastName = 'Testenko',
            UserName = 'preventTest@test.com',
            Email = 'preventTest@test.org',
            Alias = 'ttest',
            IsActive = isActive,
            ProfileId = adminProfileId,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
    }

    private static Id getAdminProfileId() {
        return [SELECT Id FROM Profile WHERE Name = :Constants.ADMIN_PROFILE_NAME LIMIT 1][0].Id;
    }
}