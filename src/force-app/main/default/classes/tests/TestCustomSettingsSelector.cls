@IsTest
public with sharing class TestCustomSettingsSelector {
    @IsTest
    private static void getLWCPaginationSettingsTest() {
        LWCPagination__c expected = LWCPagination__c.getInstance();
        LWCPagination__c actual = CustomSettingsSelector.getInstance().getLWCPaginationSettings();
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void getFeaturesEnablerTest() {
        FeaturesEnabler__c expected = FeaturesEnabler__c.getInstance();
        FeaturesEnabler__c actual = CustomSettingsSelector.getInstance().getFeaturesEnabler();
        System.assertEquals(expected, actual);
    }
}