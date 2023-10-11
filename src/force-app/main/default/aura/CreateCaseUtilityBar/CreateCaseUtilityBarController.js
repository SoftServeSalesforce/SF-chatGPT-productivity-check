({
    handleCreateNewCase: function(component, event, helper) {
        var wrapper = event.getParam('detail');
        console.log(wrapper);
        var createEvent = $A.get("e.force:createRecord");
              createEvent.setParams({
                 "entityApiName" : "Case",
                 "defaultFieldValues" : {
                    "AccountId" : wrapper.accountId,
                    "ContactId" : wrapper.contactId
              }
          });
          createEvent.fire();
    }
})
