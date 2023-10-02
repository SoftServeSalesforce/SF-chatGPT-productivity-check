({
    createCaseTab: function(component, recordId) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            
            // Specify the objectApiName and actionName for Case creation
            var pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'create',
                    recordId: recordId // Use the recordId from the Aura event
                }
            };
            
            // Open a new console tab for creating a case record
            workspaceAPI.openTab({
                parentTabId: focusedTabId,
                pageReference: pageReference,
                focus: true
            });
        });
    }
})
