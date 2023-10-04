({
    
    handleChanged: function(component, event, helper) {
        if (event != null) {
            let url = event.getParam('buildUrl');
            let  workspaceApi = component.find("workspace");
            if (url != null) {
                workspaceApi.openTab({
                    url: url,
                    focus: true
                });
            }
            
        }
    }
})
