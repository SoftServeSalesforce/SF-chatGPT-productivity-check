@IsTest
public class TestDataFactory {

    static final Id PROFILE_ID = getCustomerSupportProfileId();
    public static final String PERMISSION_SET_CSM = 'Customer_Support_Member';


    public static SObject createSObject(SObject sObj, String defaultClassName) {
		
		Type t = Type.forName(defaultClassName);
		if (t == null) {
			Throw new TestFactoryException('Invalid defaults class.');
		}
		FieldDefaults defaults = (FieldDefaults)t.newInstance();
		addFieldDefaults(sObj, defaults.getFieldDefaults());
		return sObj;
	}

    public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
        SObject retObject = createSObject(sObj, defaultClassName);
        if (doInsert) {
            insert retObject;
        }
        return retObject;
    }

    private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
		// Loop through the map of fields and if they weren't specifically assigned, fill them.
		Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
        	for (Schema.SObjectField field : defaults.keySet()) {
			if (!populatedFields.containsKey(String.valueOf(field))) {
				sObj.put(field, defaults.get(field));
			}
		}
	}

    public class TestFactoryException extends Exception {}

	public interface FieldDefaults {
		Map<Schema.SObjectField, Object> getFieldDefaults();
	}

    public static String generateRandomString(Integer lengthOfString) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < lengthOfString) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }


    public class UserDefaults implements FieldDefaults {
       
        public Map<Schema.SObjectField, Object> getFieldDefaults() {

            return new Map<Schema.SObjectField, Object> {

                User.EmailEncodingKey    => 'UTF-8',
                User.LanguageLocaleKey  => 'en_US',
                User.LocaleSidKey        => 'en_US', 
                User.ProfileId           => PROFILE_ID,
                User.TimeZoneSidKey      => 'America/Los_Angeles',
                User.FirstName           => 'FirstName',
                User.LastName => generateRandomString(7),
                User.Email => generateRandomString(8) + '@gmail.com',  
                User.Username => generateRandomString(8)+'@gmail.com.devOrg',
                User.Alias =>  generateRandomString(4),
                User.CommunityNickname => generateRandomString(5)
   
            };
        }
    } 
    

    private static String getCustomerSupportProfileId(){
       
       
        Profile p = [select id from profile WHERE name= 'Customer Support' limit 1];
        return p.Id;
    }

    
    public static List<User> buildTestUser(Integer i, User userOverride, Boolean doInsert){
        List<User> usersToInsert = new List<User>();
        for(Integer x = 1; x <= i; x++) {
            User user = (User) TestDataFactory.createSObject(userOverride, 'TestDataFactory.UserDefaults');
            usersToInsert.add(user);
        }

        if(doInsert) {
            Database.insert (usersToInsert);

            PermissionSetGroup psg = [select Id, Status from PermissionSetGroup where DeveloperName =: PERMISSION_SET_CSM];

            // force calculation of the PSG if it is not already Updated
            if (psg.Status != 'Updated') {
                Test.calculatePermissionSetGroup(psg.Id);
            }

         
                List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
                
                    for(User userInserted : usersToInsert) {
                        permissionSetAssignments.add( new PermissionSetAssignment (
                            PermissionSetGroupId = psg.Id,
                                AssigneeId = userInserted.Id)
                        );
                    }
               
                Database.insert (permissionSetAssignments);
            
        }

        return usersToInsert;

    }


   


}