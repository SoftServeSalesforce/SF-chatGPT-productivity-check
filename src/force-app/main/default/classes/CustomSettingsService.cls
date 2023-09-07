/**
 * @description OrderSelector: Service to capture Custom Settings-related Business logic.
 */
public with sharing class CustomSettingsService {
    @TestVisible
    private static CustomSettingsService instance;

    public static CustomSettingsService getInstance() {
        if (instance == null) {
            instance = new CustomSettingsService();
        }
        return instance;
    }

    public void capturePreferredLWCPaginationPageSize(Integer pageSize) {
        LWCPagination__c settings = CustomSettingsSelector.getInstance().getLWCPaginationSettings();
        settings.PageSize__c = pageSize;
        upsert settings;
    }
}