@IsTest
public with sharing class TestCustomSettingsSelector {
    /**
     * @description testGetInstance: Test method needed to ensure that singleton
     * pattern is properly implemented.
     */
    @IsTest
    private static void testGetInstance() {
        //Verify that instance is null by default.
        CustomSettingsSelector original = CustomSettingsSelector.instance;
        System.assertEquals(null, original, Constants.ERROR_INSTANCE_SHOULD_BE_NULL);
        //Verify that public accessor works.
        CustomSettingsSelector newInstance = CustomSettingsSelector.getInstance();
        System.assertNotEquals(null, newInstance, Constants.ERROR_INSTANCE_SHOULD_NOT_BE_NULL);
    }

    /**
     * @description testGetFeaturesEnabler: Test method needed to ensure that
     * 'getFeaturesEnabler' method of 'CustomSettingsSelector' class returns
     * expected FeaturesEnabler__c instance.
     */
    @IsTest
    private static void testGetFeaturesEnabler() {
        //Prepare data.
        FeaturesEnabler__c expected = FeaturesEnabler__c.getInstance();
        //Execute scenario.
        FeaturesEnabler__c actual = CustomSettingsSelector.getInstance().getFeaturesEnabler();
        //Verify outcomes.
        System.assertEquals(expected, actual);
    }
}