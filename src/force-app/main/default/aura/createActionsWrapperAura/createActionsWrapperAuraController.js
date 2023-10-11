({
    onInit : function(component, event, helper) {
        let utilityBarAPI = component.find("utilitybar");
        helper.handleInit(utilityBarAPI);
    },
    onRecordIdChange : function() {},
    
    onCreateActionsReceived: function(component, event, helper) {
        if (event != null) {
            let url = event.getParam('buildUrl');
            let workspaceApi = component.find("workspace");
            helper.handleCreateActionsReceivedURL(workspaceApi, url);
        }
    }
})