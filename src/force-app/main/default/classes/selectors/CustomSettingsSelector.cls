/**
 * @description OrderSelector: Selector to access "ContentDocumentLink" SObject records.
 */
public with sharing class CustomSettingsSelector {
    @TestVisible
    private static CustomSettingsSelector instance;

    public static CustomSettingsSelector getInstance() {
        if (instance == null) {
            instance = new CustomSettingsSelector();
        }
        return instance;
    }

    public LWCPagination__c getLWCPaginationSettings() {
        return LWCPagination__c.getInstance();
    }
}