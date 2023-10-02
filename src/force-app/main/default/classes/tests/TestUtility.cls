@IsTest
public with sharing class TestUtility {
    private static final String TEST_PROFILE = 'Standard User';
    private static final String TEST_LAST_NAME = 'Test';
    private static final String TEST_EMAIL_ENCODING = 'UTF-8';
    private static final String TEST_LANGUAGE_LOCALE = 'en_US';
    private static final String TEST_TIME_ZONE = 'America/Los_Angeles';
    private static final String TEST_ALIAS = 'kmacz';
    private static final String TEST_LOCALE = 'en_US';
    private static final String TEST_STATUS = 'New';
    private static final String TEST_SUBJECT = 'subject test';
    private static final String TEST_EMAIL = 'kmacz@softserveinc.com';

    private static Id getTestProfileId() {
        return [SELECT Id FROM Profile WHERE Name =: TEST_PROFILE].Id;
    }

    public static User insertUser() {
        User user = new User();
        user.Email = TEST_EMAIL;
        user.IsActive = true;
        user.Username = TEST_EMAIL + '.' + TEST_LAST_NAME + '.testuser';
        user.LastName = TEST_LAST_NAME;
        user.Alias = TEST_ALIAS;
        user.ProfileId = getTestProfileId();
        user.EmailEncodingKey = TEST_EMAIL_ENCODING;
        user.LanguageLocaleKey = TEST_LANGUAGE_LOCALE;
        user.TimeZoneSidKey = TEST_TIME_ZONE;
        user.LocaleSidKey = TEST_LOCALE;
        insert user;
        return user;
    }

    public static List<Case> insertCases(Id ownerId, Integer numberOfCases) {
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < numberOfCases; i++) {
            Case singleCase = new Case();
            singleCase.OwnerId = ownerId;
            singleCase.Status = TEST_STATUS;
            singleCase.Subject = TEST_SUBJECT;
            casesToInsert.add(singleCase);
        }
        if(casesToInsert.size() > 0) {
            insert casesToInsert;
        }
        
        return casesToInsert;
    }

}
