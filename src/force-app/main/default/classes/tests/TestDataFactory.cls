@IsTest
public with sharing class TestDataFactory {
    private static TestDataFactory instance;
    //User constants
    private static final String PROFILE_STANDARD_USER = 'Standard User';
    private static final String USER_LAST_NAME = 'Test';
    private static final String USER_EMAIL_ENCODING = 'UTF-8';
    private static final String USER_LANGUAGE_LOCALE_KEY = 'en_US';
    private static final String USER_TIME_ZONE_SID_KEY = 'America/Los_Angeles';
    private static final String USER_LOCALE_SID_KEY = 'en_US';
    //Case constants
    private static final String CASE_STATUS_NEW = 'New';
    private static final String CASE_ORIGIN_PHONE = 'Phone';
    private static final String CASE_PRIORITY_MEDIUM = 'Medium';
    private static final String CASE_SUBJECT = 'Test Case';

    private Id standartProfileId;

    private TestDataFactory() {
        standartProfileId = [SELECT Id FROM Profile WHERE Name =: PROFILE_STANDARD_USER].Id;
    }

    public static TestDataFactory getInstance() {
        if (instance == null) {
            instance = new TestDataFactory();
        }
        return instance;
    }

    public User createUser(String email) {
        User user = new User();
        user.Email = email;
        user.IsActive = true;
        user.Username = email + System.currentTimeMillis();
        user.LastName = USER_LAST_NAME;
        user.Alias = email.substring(0, 8);
        user.ProfileId = standartProfileId;
        user.EmailEncodingKey = USER_EMAIL_ENCODING;
        user.LanguageLocaleKey = USER_LANGUAGE_LOCALE_KEY;
        user.TimeZoneSidKey = USER_TIME_ZONE_SID_KEY;
        user.LocaleSidKey = USER_LOCALE_SID_KEY;
        insert user;
        return user;
    }

    public Case buildCase(Id ownerId) {
        Case cs = new Case();
        cs.OwnerId = ownerId;
        cs.Status = CASE_STATUS_NEW;
        cs.Origin = CASE_ORIGIN_PHONE;
        cs.Priority = CASE_PRIORITY_MEDIUM;
        cs.Subject = CASE_SUBJECT;
        return cs;
    }

    public List<Case> createCases(Id ownerId, Integer numberOfCases) {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < numberOfCases; i++) {
            cases.add(buildCase(ownerId));
        }
        insert cases;
        return cases;
    }

}