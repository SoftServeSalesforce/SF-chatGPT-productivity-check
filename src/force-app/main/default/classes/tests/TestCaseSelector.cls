@IsTest
public with sharing class TestCaseSelector {

    // Test assertation constants
    private static final String ERROR_CASES_SHOULD_NOT_BE_NULL = 'Cases should not be null';
    private static final String ERROR_CASES_SHOULD_NOT_BE_EMPTY = 'Cases should not be empty';
    private static final String ERROR_ACTIVE_USER_CASES_AMOUNT_SHOULD_BE = 'Amount of active user cases should be ';
    private static final String ERROR_INACTIVE_USER_CASES_AMOUNT_SHOULD_BE = 'Amount of inactive user cases should be ';

    // Data constants
    private static final String ACTIVE_USER_EMAIL = 'active@example.com.test';
    private static final String INACTIVE_USER_EMAIL = 'inactive@example.com.test';
    private static final Integer NUMBER_OF_CASES = 10;

    @TestSetup
    static void makeData(){
        User activeUser = TestDataFactory.getInstance().createUser(ACTIVE_USER_EMAIL);
        User inactiveUser = TestDataFactory.getInstance().createUser(INACTIVE_USER_EMAIL);
        TestDataFactory.getInstance().createCases(activeUser.Id, NUMBER_OF_CASES);
        TestDataFactory.getInstance().createCases(inactiveUser.Id, NUMBER_OF_CASES);
    }

    @IsTest
    private static void testGetInstance() {
        CaseSelector original = CaseSelector.instance;
        Assert.isNull(original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        CaseSelector newInstance = CaseSelector.getInstance();
        Assert.isNotNull(newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    @IsTest
    private static void testGetAllCases() {
        CaseSelector instance = CaseSelector.getInstance();
        List<Case> cases = instance.getAllCases();
        Assert.isNotNull(cases, ERROR_CASES_SHOULD_NOT_BE_NULL);
        Assert.areNotEqual(0, cases.size(), ERROR_CASES_SHOULD_NOT_BE_EMPTY);
    }

    @IsTest
    private static void testGetCasesWithOwnerStatus() {
        CaseSelector caseSelector = CaseSelector.getInstance();
        Map<Id,Case> testCases = new Map<Id, Case> (caseSelector.getAllCases());
        deactivateUser();
        List<Case> cases = caseSelector.getCasesWithOwnerStatusByIds(testCases.keySet());
        Assert.isNotNull(cases, ERROR_CASES_SHOULD_NOT_BE_NULL);
        Assert.areNotEqual(0, cases.size(), ERROR_CASES_SHOULD_NOT_BE_EMPTY);
        Integer activeUserCases = 0;
        Integer inactiveUserCases = 0;
        for(Case c : cases){
            if(c.Owner.IsActive){
                activeUserCases++;
                continue;
            }
            inactiveUserCases++;
        }
        Assert.areEqual(NUMBER_OF_CASES, activeUserCases, ERROR_ACTIVE_USER_CASES_AMOUNT_SHOULD_BE + NUMBER_OF_CASES);
        Assert.areEqual(NUMBER_OF_CASES, inactiveUserCases, ERROR_INACTIVE_USER_CASES_AMOUNT_SHOULD_BE + NUMBER_OF_CASES);
    }

    private static void deactivateUser() {
        User user = [SELECT Id FROM User WHERE Email = :INACTIVE_USER_EMAIL];
        user.IsActive = false;
        update user;
    }
}