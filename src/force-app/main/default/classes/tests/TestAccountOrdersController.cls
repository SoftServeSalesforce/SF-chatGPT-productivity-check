@IsTest
public with sharing class TestAccountOrdersController {

    @IsTest
    private static void getPageSizeFromLWCPaginationSetting_withCustomSetting() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        Integer expected = 200;
        LWCPagination__c setting = new LWCPagination__c(
            PageSize__c = expected
        );
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getLWCPaginationSettings()).thenReturn(setting);
        mocks.stopStubbing();
        Integer result = AccountOrdersController.getPageSizeFromLWCPaginationSetting();
        System.assertNotEquals(null, result);
        System.assertEquals(expected, result);
        ((CustomSettingsSelector) mocks.verify(selectorMock, 1)).getLWCPaginationSettings();
    }

    @IsTest
    private static void getPageSizeFromLWCPaginationSetting_noCustomSetting() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        Integer expected = Constants.LWC_PAGINATION_PAGE_SIZE_DEFAULT;
        LWCPagination__c setting = new LWCPagination__c();
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getLWCPaginationSettings()).thenReturn(setting);
        mocks.stopStubbing();
        Integer result = AccountOrdersController.getPageSizeFromLWCPaginationSetting();
        System.assertNotEquals(null, result);
        System.assertEquals(expected, result);
        ((CustomSettingsSelector) mocks.verify(selectorMock, 1)).getLWCPaginationSettings();
    }

    @IsTest
    private static void updatePageSizeForLWCPaginationSettingTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsService serviceMock = (CustomSettingsService)mocks.mock(CustomSettingsService.class);
        CustomSettingsService.instance = serviceMock;
        Integer pageSize = Constants.LWC_PAGINATION_PAGE_SIZE_DEFAULT;
        AccountOrdersController.updatePageSizeForLWCPaginationSetting(pageSize);
        ((CustomSettingsService) mocks.verify(serviceMock, 1)).capturePreferredLWCPaginationPageSize(pageSize);
    }

    @IsTest
    private static void updatePageSizeForLWCPaginationSettingTest_pageSizeIsZero() {
        String expected = Constants.EXCEPTION_PAGESIZE_CANNOT_BE_EQUAL_TO_OR_LESS_THAN_ZERO;
        String actual;
        try {
            AccountOrdersController.updatePageSizeForLWCPaginationSetting(0);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void updatePageSizeForLWCPaginationSettingTest_pageSizeIsNull() {
        String expected = Constants.EXCEPTION_PAGESIZE_CANNOT_BE_NULL;
        String actual;
        try {
            AccountOrdersController.updatePageSizeForLWCPaginationSetting(null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void getOrdersTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderSelector selectorMock = (OrderSelector)mocks.mock(OrderSelector.class);
        OrderSelector.instance = selectorMock;
        ContentDocumentLinkService serviceMock = (ContentDocumentLinkService)mocks.mock(ContentDocumentLinkService.class);
        ContentDocumentLinkService.instance = serviceMock;
        Id accountId = fflib_IDGenerator.generate(Account.SobjectType);
        Integer pageNumber = 1;
        Integer pageSize = 1;
        Map<Id, Order> ordersById = new Map<Id, Order>();
        Database.QueryLocator ql = Database.getQueryLocator([SELECT Id FROM Order]);
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getQueryLocatorToOrdersByParentAccountId(accountId)).thenReturn(ql);
        mocks.stopStubbing();
        PageWithOrdersDTO result = AccountOrdersController.getOrders(accountId, pageNumber, pageSize);
        System.assertNotEquals(null, result);
        ((OrderSelector) mocks.verify(selectorMock, 1)).getQueryLocatorToOrdersByParentAccountId(accountId);
        ((ContentDocumentLinkService) mocks.verify(serviceMock, 1)).getTheMostRecentInvoicesIdsByParentId(ordersById.keySet());
    }

    @IsTest
    private static void validateGetOrdersRequestTest_pageSizeIsZero() {
        String expected = Constants.EXCEPTION_PAGESIZE_CANNOT_BE_EQUAL_TO_OR_LESS_THAN_ZERO;
        String actual;
        try {
            AccountOrdersController.validateGetOrdersRequest(
                fflib_IDGenerator.generate(Account.SobjectType), 1, 0
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateGetOrdersRequestTest_pageSizeIsNull() {
        String expected = Constants.EXCEPTION_PAGESIZE_CANNOT_BE_NULL;
        String actual;
        try {
            AccountOrdersController.validateGetOrdersRequest(
                fflib_IDGenerator.generate(Account.SobjectType), 1, null
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateGetOrdersRequestTest_pageNumberIsZero() {
        String expected = Constants.EXCEPTION_PAGENUMBER_BE_EQUAL_TO_OR_LESS_THAN_ZERO;
        String actual;
        try {
            AccountOrdersController.validateGetOrdersRequest(
                fflib_IDGenerator.generate(Account.SobjectType), 0, null
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateGetOrdersRequestTest_pageNumberIsNull() {
        String expected = Constants.EXCEPTION_PAGENUMBER_CANNOT_BE_NULL;
        String actual;
        try {
            AccountOrdersController.validateGetOrdersRequest(
                fflib_IDGenerator.generate(Account.SobjectType), null, null
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateGetOrdersRequestTest_nonAccountId() {
        String expected = Constants.EXCEPTION_ACCOUNTID_IS_NOT_VALID;
        String actual;
        try {
            AccountOrdersController.validateGetOrdersRequest(
                fflib_IDGenerator.generate(Order.SobjectType), null, null
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateGetOrdersRequestTest_accountIdIsNull() {
        String expected = Constants.EXCEPTION_ACCOUNTID_CANNOT_BE_BLANK;
        String actual;
        try {
            AccountOrdersController.validateGetOrdersRequest(null, null, null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void moveOrdersToActivatedStatusTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderSelector selectorMock = (OrderSelector)mocks.mock(OrderSelector.class);
        OrderSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Set<Id> orderIdsSet = new Set<Id> { orderId };
        List<Id> orderIdsList = new List<Id> { orderId };
        Order o = new Order(Id = orderId);
        List<Order> orders = new List<Order> { o };
        Database.SaveResult dsr = (Database.SaveResult)JSON.deserialize(
            Constants.DSR_WITH_NO_ERROR_TEMPLATE.replace('{0}', orderId),
            Database.SaveResult.class
        );
        List<Database.SaveResult> dsrs = new List<Database.SaveResult> { dsr };
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getOrdersById(orderIdsSet)).thenReturn(orders);
        mocks.when(serviceMock.setOrdersStatusToActived(orders)).thenReturn(dsrs);
        mocks.stopStubbing();
        OrderUpdateResultDTO result = AccountOrdersController.moveOrdersToActivatedStatus(orderIdsList);
        System.assertNotEquals(null, result);
        ((OrderSelector) mocks.verify(selectorMock, 1)).getOrdersById(orderIdsSet);
        ((OrderService) mocks.verify(serviceMock, 1)).setOrdersStatusToActived(orders);
    }

    @IsTest
    private static void moveOrdersToShippedStatusTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderSelector selectorMock = (OrderSelector)mocks.mock(OrderSelector.class);
        OrderSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Set<Id> orderIdsSet = new Set<Id> { orderId };
        List<Id> orderIdsList = new List<Id> { orderId };
        Order o = new Order(Id = orderId);
        List<Order> orders = new List<Order> { o };
        Database.SaveResult dsr = (Database.SaveResult)JSON.deserialize(
            Constants.DSR_WITH_NO_ERROR_TEMPLATE.replace('{0}', orderId),
            Database.SaveResult.class
        );
        List<Database.SaveResult> dsrs = new List<Database.SaveResult> { dsr };
        //Stub data.
        mocks.startStubbing();
        mocks.when(selectorMock.getOrdersById(orderIdsSet)).thenReturn(orders);
        mocks.when(serviceMock.setOrdersStatusToShipped(orders)).thenReturn(dsrs);
        mocks.stopStubbing();
        OrderUpdateResultDTO result = AccountOrdersController.moveOrdersToShippedStatus(orderIdsList);
        System.assertNotEquals(null, result);
        ((OrderSelector) mocks.verify(selectorMock, 1)).getOrdersById(orderIdsSet);
        ((OrderService) mocks.verify(serviceMock, 1)).setOrdersStatusToShipped(orders);
    }

    @IsTest
    private static void validateStatusChangeRequestTest_orderIdsIsNull() {
        String expected = Constants.EXCEPTION_ORDERIDS_CANNOT_BE_NULL;
        String actual;
        try {
            AccountOrdersController.validateStatusChangeRequest(null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateStatusChangeRequest_orderIdsIsEmpty() {
        String expected = Constants.EXCEPTION_ORDERIDS_CANNOT_BE_EMPTY;
        String actual;
        try {
            AccountOrdersController.validateStatusChangeRequest(new List<Id>());
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateStatusChangeRequest_invalidOrderIds() {
        String expected = Constants.EXCEPTION_ORDERIDS_SHOULD_CONTAIN_ONLY_VALID_ORDER_IDS;
        String actual;
        try {
            AccountOrdersController.validateStatusChangeRequest(new List<Id>{
                fflib_IDGenerator.generate(Account.SObjectType)
            });
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }
}