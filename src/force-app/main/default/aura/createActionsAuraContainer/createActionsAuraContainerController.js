({
    openUtilityItem : function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function (response) {
            if (typeof response !== 'undefined') {
                utilityAPI.openUtility();
                helper.createCaseTab(component);
            }
        });
    },

    handleMessage: function(component, event, helper) {
        // Handle the Aura event and get the recordId
        var recordId = event.getParam("recordId");
        console.log("Received recordId: " + recordId);

        // Pass the recordId to the helper method to open a new tab
        helper.createCaseTab(component, recordId);
    },
    
    onRecordIdChange: function(component, event, helper) {
        var newRecordId = component.get("v.recordId");
        console.log(newRecordId);
    }
})
