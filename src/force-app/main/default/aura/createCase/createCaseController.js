({
    doInit: function(component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function (response) {
            if (typeof response !== 'undefined') {
                        utilityAPI.openUtility();
            }
        });
    },

    handleMessage: function(cmp, message, helper) {
        if (message != null) {
            const sobjName = cmp.get("v.sObjectName");
            const objApiName = cmp.get("v.objectApiName");
            const recordId = cmp.get("v.recordId");
            console.log("sobjName", sobjName);
            console.log("objapiName", objApiName);
            console.log("recordid", recordId);
            
            const newCaseUrl = message.getParam("URL");
            let workspaceAPI = cmp.find("workspace");
            workspaceAPI.openTab({
                url: newCaseUrl,
                focus: true
            });
        } 
    }
})
