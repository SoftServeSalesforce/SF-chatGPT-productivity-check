@IsTest
public with sharing class TestCustomSettingsSelector {
    @IsTest
    private static void getLWCPaginationSettingsTest() {
        LWCPagination__c expected = LWCPagination__c.getInstance();
        LWCPagination__c actual = CustomSettingsSelector.getInstance().getLWCPaginationSettings();
        System.assertEquals(expected, actual);
    }
}