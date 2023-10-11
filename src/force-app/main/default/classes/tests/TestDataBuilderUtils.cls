@isTest public inherited sharing class TestDataBuilderUtils {

    public static Map<String, Profile> createProfileMap(List<Profile> profiles) {
        Map<String, Profile> profileMap = new Map<String, Profile>();
        for (Profile profile : profiles) {
            profileMap.put(profile.Name, profile);
        }
        return profileMap;
    } 

    public static Map<String, Profile> profileMap = createProfileMap([SELECT Id, Name FROM Profile]);


    public static User createActiveTestUser() {
        User user = new User(
            Alias = 'testuser',
            Email = 'testuser@myorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestingActive',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId =  profileMap.get('Standard User').Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuseractive@myorg.com',
            IsActive = true
        );

        insert user;
        return user;
    }

    public static User createInactiveTestUser() {
        User user = new User(
            Alias = 'testuser',
            Email = 'testuser@myorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestingInActive',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId =  profileMap.get('Standard User').Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuserinactive@myorg.com',
            IsActive = false
        );

        insert user;
        return user;
    }
}