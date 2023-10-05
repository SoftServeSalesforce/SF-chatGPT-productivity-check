public with sharing class CreateCaseController {

    @AuraEnabled(cacheable=true)
    public static NewCaseParametersDto getNewCaseParameters(Id recordId) {
        if (recordId != null) {
            String objectName = recordId.getSObjectType().getDescribe().getName();
            if (objectName == 'Account') {
                return getNewCaseParametersDTO(recordId);
            } else if (objectName == 'Contact') {
                return getNewCaseParametersDTO([SELECT Id, Name, AccountId FROM Contact WHERE Id = :recordId]);
            }
        }
        return new NewCaseParametersDto();
    }

    @TestVisible
    private static NewCaseParametersDto getNewCaseParametersDto(Id accountId) {
        NewCaseParametersDTO newCaseParametersDTO = new NewCaseParametersDTO();
        newCaseParametersDTO.accountId = accountId;
        return newCaseParametersDTO;
    }

    @TestVisible
    private static NewCaseParametersDto getNewCaseParametersDto(Contact contact) {
        NewCaseParametersDto newCaseParametersDTO = new NewCaseParametersDto();
        newCaseParametersDTO.contactId = contact.Id;
        newCaseParametersDTO.accountId = contact.accountId;
        return newCaseParametersDTO;
    }

    public class NewCaseParametersDto {
        @AuraEnabled public String accountId;
        @AuraEnabled public String contactId;
    }
}
