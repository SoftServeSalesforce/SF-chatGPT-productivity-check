({
    doInit : function(component, event, helper) {
        let utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function (response) {
            if (response) {
                utilityAPI.openUtility();
            }
        });
    },

    handleMessageChannel: function(component, event, helper) {
        if (event) {
            const caseURL = event.getParam("URL");
            let workspaceAPI = component.find("workspace");
            workspaceAPI.openTab({
                url: caseURL,
                focus: true
            });
        }
    }
})
