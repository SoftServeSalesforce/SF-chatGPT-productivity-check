({
    handleCreateCase: function (component, event, helper) {  
        let detail = event.getParam("result");
        if (detail) {
            let createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Case",
                "defaultFieldValues": {
                    'AccountId': detail.accountId,
                    'ContactId': detail.contactId,
                    'Origin': detail.origin
                }
            });
            createRecordEvent.fire();
            } 
        }        
})
