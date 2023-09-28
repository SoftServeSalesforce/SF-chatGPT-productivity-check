public with sharing class TestDataFactory {

    public class TestDataFactoryException extends Exception {}

     // static var for generating random a-zA-Z0-9 strings
    static Integer[] charset;
    // static initialization brace for random string generation
    static {
        charset = new Integer[0];
        for(Integer i = 48; i < 58; i++) charset.add(i);
        for(Integer i = 65; i < 91; i++) charset.add(i);
        for(Integer i = 97; i < 123; i++) charset.add(i);
    }

    public static List<User> createUsers(Integer num, Id profileId, List<String> permissionSetsNames, User userOverride, Boolean doInsert){
        List<User> users = new List<User>();
        for(Integer i = 1; i <= num; i++) {
            User u = (User) TestDataFactory.createSObject(userOverride, 'TestDataFactory.UserDefaults');
            users.add(u);
        }
        if(profileId != null){
            for(User usr : users){
                usr.ProfileId = profileId;
            }
        }
        if(doInsert) {
            insert users;
            if(permissionSetsNames != null && permissionSetsNames.size() > 0) {
                List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetsNames];
                List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
                for(PermissionSet permissionSet : permissionSets) {
                    for(User testUser : users) {
                        permissionSetAssignments.add( new PermissionSetAssignment (
                                PermissionSetId = permissionSet.Id,
                                AssigneeId = testUser.Id)
                        );
                    }
                }
                insert permissionSetAssignments;
            }
        }        
        return users;
    }

    public static SObject createSObject(SObject sObj, String defaultClassName) {
        System.debug('createSObject start  ');
        // Create an instance of the defaults class so we can get the Map of field defaults
        Type t = Type.forName(defaultClassName);
        System.debug('Type t  ' + t);
        if (t == null) {
            Throw new TestDataFactoryException('Invalid defaults class.');
        }
        FieldDefaults defaults = (FieldDefaults)t.newInstance();
        System.debug('defaults  ' + defaults);
        addFieldDefaults(sObj, defaults.getFieldDefaults());
        return sObj;
    }

    private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
        // Loop through the map of fields and if they weren't specifically assigned, fill them.
        Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
        System.debug('populatedFields ' + populatedFields);
        for (Schema.SObjectField field : defaults.keySet()) {
            if (!populatedFields.containsKey(String.valueOf(field))) {
                sObj.put(field, defaults.get(field));
            }
        }
    }

    public static String genRandomString(Integer len) {
        Integer[] chars = new Integer[len];
        Integer key, size = charset.size();

        for(Integer idx = 0; idx < len; idx++) {
            chars[idx] = charset[Math.mod(Math.abs(Crypto.getRandomInteger()), size)];
        }

        return String.fromCharArray(chars);
    }

    // Use the FieldDefaults interface to set up values you want to default in for all objects.
    public interface FieldDefaults {
        Map<Schema.SObjectField, Object> getFieldDefaults();
    }  
    
    private static User dummyUser {
        get {
            if (dummyUser==null) {
                dummyUser = [SELECT TimeZoneSidKey, LocaleSidKey,
                        EmailEncodingKey, ProfileId, LanguageLocaleKey
                FROM User WHERE isActive = true LIMIT 1];
            }
            System.assertNotEquals(null, dummyUser);
            return dummyUser ;
        }
        set {
            System.assert(true);
        }        
    }

    public class UserDefaults implements FieldDefaults {
       
        Boolean isActive;
        String lastName = genRandomString(10);
        String email = lastName+'@hotmail.com';
        String alias = genRandomString(5);
        String nick = genRandomString(5);
        public Map<Schema.SObjectField, Object> getFieldDefaults() {

            return new Map<Schema.SObjectField, Object> {
                    User.FirstName => 'TestFName',
                    User.LastName => lastName,
                    User.Email => email,
                    User.Username => email,
                    User.ProfileId => dummyUser.ProfileId,
                    User.Alias => alias,
                    User.CommunityNickname => nick,
                    User.TimeZoneSidKey => (String)dummyUser.get('TimeZoneSidKey'),
                    User.LocaleSidKey => dummyUser.LocaleSidKey,
                    User.EmailEncodingKey => dummyUser.EmailEncodingKey,
                    User.LanguageLocaleKey => dummyUser.LanguageLocaleKey
            };
        }
    }   
}