({
    handleInit: function(utilityBarAPI) {
        utilityBarAPI.getAllUtilityInfo().then(function (response) {
            if (typeof response !== 'undefined') {
                utilityBarAPI.openUtility();
            }
        });
    },

    handleCreateActionsReceivedURL: function(workspaceApi, url) {
        if (url != null) {
            workspaceApi.openTab({
                url: url,
                focus: true
            });
        }
    }
})
