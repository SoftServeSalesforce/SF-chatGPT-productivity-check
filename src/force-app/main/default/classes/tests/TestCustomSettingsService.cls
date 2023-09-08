@IsTest
public with sharing class TestCustomSettingsService {
    @IsTest
    private static void capturePreferredLWCPaginationPageSizeTest() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        //Prepare data.
        LWCPagination__c settings = new LWCPagination__c();
        Integer pageSize = Constants.LWC_PAGINATION_PAGE_SIZE_DEFAULT * 4;
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getLWCPaginationSettings()).thenReturn(settings);
        mocks.stopStubbing();
        //Execute scenario.
        CustomSettingsService.getInstance().capturePreferredLWCPaginationPageSize(pageSize);
        //Verify outcomes.
        System.assertEquals(pageSize, LWCPagination__c.getInstance().PageSize__c);
    }
}