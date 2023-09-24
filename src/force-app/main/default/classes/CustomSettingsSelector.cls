public with sharing class CustomSettingsSelector {
    @TestVisible
    private static CustomSettingsSelector instance;

    public static CustomSettingsSelector getInstance() {
        if (instance == null) {
            instance = new CustomSettingsSelector();
        }
        return instance;
    }

    public FeaturesEnabler__c getFeaturesEnabler() {
        return FeaturesEnabler__c.getInstance();
    }
}