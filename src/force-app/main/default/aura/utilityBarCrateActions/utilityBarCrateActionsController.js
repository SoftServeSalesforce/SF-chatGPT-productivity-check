({
    
    handleChanged: function(component, event, helper) {
        if (event != null) {
            var url = event.getParam('buildUrl');
            var workspaceApi = component.find("workspace");
            if (url != null) {
                workspaceApi.openTab({
                    url: url,
                    focus: true
                });
            }
            
        }
    }
})
