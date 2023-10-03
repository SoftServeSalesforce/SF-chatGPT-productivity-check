({
    onInit : function(component, event, helper) {
        var utilityBarAPI = component.find("utilitybar");
        helper.handleInit(utilityBarAPI);
    },
    onRecordIdChange : function() {},
    
    onCreateActionsReceived: function(component, event, helper) {
        if (event != null) {
            var url = event.getParam('buildUrl');
            var workspaceApi = component.find("workspace");
            helper.handleCreateActionsReceivedURL(workspaceApi, url);
        }
    }
})