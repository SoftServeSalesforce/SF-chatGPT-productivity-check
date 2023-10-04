public with sharing class CreateCaseActionController {
    
    public class CreateCaseActionDTO {

       @AuraEnabled public String caseOrigin { get; set; }

        @AuraEnabled public Id accountId { get; set; }

        @AuraEnabled public Id contactId { get; set; }

        @AuraEnabled public String url { get; set; }


        public CreateCaseActionDTO(String origin) {
            this.caseOrigin = origin;
            url='/lightning/o/Case/new?&defaultFieldValues=Origin='+ origin;      
           
        }

        public CreateCaseActionDTO(Id accountId) {
            this.caseOrigin = Constants.CASE_ORIGIN_WEB;  
            this.accountId = accountId;
            url='/lightning/o/Case/new?&defaultFieldValues=Origin='+ Constants.CASE_ORIGIN_WEB+
            ',AccountId='+accountId;
            
           
        }

        public CreateCaseActionDTO(Id accountId, Id contactId) {
            this.caseOrigin = Constants.CASE_ORIGIN_WEB;  
            this.accountId = accountId;
            this.contactId = contactId;
            if(accountId!=null){
                url='/lightning/o/Case/new?&defaultFieldValues=Origin='+ 
                Constants.CASE_ORIGIN_WEB+
                ',AccountId='+accountId+
                ',ContactId='+contactId;
            }else{
                url='/lightning/o/Case/new?&defaultFieldValues=Origin='+ 
                Constants.CASE_ORIGIN_WEB+
                ',ContactId='+contactId;
            }   
           
        }
         

    }

    class unsupportedTypeException extends Exception{}


    
    @AuraEnabled
    public static CreateCaseActionController.CreateCaseActionDTO getData(Id recordId){

        try {
            
            String objecttype = recordId?.getSobjectType().getDescribe().getName();

            if(objecttype == null || objecttype.equals('Case')) {
                return new CreateCaseActionDTO(Constants.CASE_ORIGIN_WEB);
            }
            if(objecttype.equals('Account')) {
                return new CreateCaseActionDTO(recordId);
            }
            if(objecttype.equals('Contact')) {
                Contact contact = ContactSelector.getInstance().getContactById(recordId);
                return new CreateCaseActionDTO(contact.AccountId, recordId);
            }
            
            throw new AuraHandledException(Constants.UNSUPPORTED_OBJECT_TYPE);
                                

        } catch (Exception e) {
           
            throw new unsupportedTypeException(Constants.UNSUPPORTED_OBJECT_TYPE);
        }

    }



}