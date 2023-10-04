public with sharing class ContactSelector {
 
        @TestVisible
        private static ContactSelector instance;
    
        public static ContactSelector getInstance() {
            if (instance == null) {
                instance = new ContactSelector();
            }
            return instance;
        }
    
       
        public Contact getContactById(Id recordId) {
            return [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Id =: recordId 
                WITH SECURITY_ENFORCED 
                LIMIT 1];
        }
}