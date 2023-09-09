@IsTest
public with sharing class TestOrderTriggerHandler {
    private static final Integer FEATURES_ENABLER_CHECKS_AT_RUN = 1;
    private static final Integer FEATURES_ENABLER_CHECKS_AT_BEFORE_INSERT_HANDLER = 1;
    private static final Integer FEATURES_ENABLER_CHECKS_AT_BEFORE_UPDATE_HANDLER = 3;

    @IsTest
    private static void runTest_unsupportedOperationType() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_Trigger__c = true
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;
        try {
            OrderTriggerHandler.getInstance().run(null, null, TriggerOperation.AFTER_INSERT);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_triggerDisabledOnBeforeInsert() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        Order o = new Order (
            Id = fflib_IDGenerator.generate(Order.SobjectType),
            Status = Constants.ORDER_STATUS_DRAFT
        );
        List<Order> newOrders = new List<Order> { o };
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_Trigger__c = false,
            Order_CaptureLastStatusChange__c = true
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().run(newOrders, null, TriggerOperation.BEFORE_INSERT);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_RUN)).getFeaturesEnabler();
    }

    @IsTest
    private static void runTest_disabledOnBeforeUpdate() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        Order o = new Order (
            Id = fflib_IDGenerator.generate(Order.SobjectType),
            Status = Constants.ORDER_STATUS_DRAFT
        );
        List<Order> newOrders = new List<Order> { o };
        Map<Id, Order> oldOrders = new Map<Id, Order> { o.Id => o };
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_Trigger__c = false
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().run(newOrders, oldOrders, TriggerOperation.BEFORE_UPDATE);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_RUN)).getFeaturesEnabler();
    }
    
    @IsTest
    private static void validateContextOnBeforeInsertTest_newOrdersIsNull() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeInsert(null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeInsertTest_newOrdersIsEmpty() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeInsert(new List<Order>());
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeInsertTest_positive() {
        String expected;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeInsert(new List<Order>{ new Order() });
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }
    
    @IsTest
    private static void validateContextOnBeforeUpdateTest_newOrdersIsNull() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(null, null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeUpdateTest_newOrdersIsEmpty() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(new List<Order>(), null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeUpdateTest_oldOrdersIsNull() {
        String expected = Constants.EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_NULL;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(new List<Order> { new Order() }, null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeUpdateTest_oldOrdersIsEmpty() {
        String expected = Constants.EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_EMPTY;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(new List<Order>{ new Order() }, new Map<Id,Order>());
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeUpdateTest_sizesMismatch() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_AND_OLD_SIZES_SHOULD_MATCH;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(
                new List<Order>{ new Order(), new Order() },
                new Map<Id,Order> { null => new Order()}
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeUpdateTest_noIdOnUpdate() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_ITEMS_SHOULD_HAVE_IDS_ON_UPDATE;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(
                new List<Order>{ new Order() },
                new Map<Id,Order> { null => new Order()}
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeUpdateTest_noCorrespondingItem() {
        String expected = Constants.EXCEPTION_EACH_TRIGGER_NEW_ITEM_SHOULD_HAVE_CORRESPONDING_OLD_ITEM_ON_UPDATE;
        String actual;
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(
                new List<Order>{ new Order(Id = fflib_IDGenerator.generate(Order.SobjectType)) },
                new Map<Id,Order> { null => new Order()}
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void validateContextOnBeforeUpdateTest_positive() {
        String expected;
        String actual;
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order o = new Order(
            Id = orderId
        );
        try {
            OrderTriggerHandler.getInstance().validateContextOnBeforeUpdate(
                new List<Order>{ o },
                new Map<Id,Order> { orderId => o}
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void onBeforeInsertTest_allDsiabled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        List<Order> newOrders = new List<Order>();
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_CaptureLastStatusChange__c = false
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().onBeforeInsert(newOrders);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_BEFORE_INSERT_HANDLER)).getFeaturesEnabler();
        ((OrderService) mocks.verify(serviceMock, 0)).captureLastStatusChange(newOrders, null);
    }

    @IsTest
    private static void onBeforeInsertTest_allEnabled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        List<Order> newOrders = new List<Order>();
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_CaptureLastStatusChange__c = true
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().onBeforeInsert(newOrders);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_BEFORE_INSERT_HANDLER)).getFeaturesEnabler();
        ((OrderService) mocks.verify(serviceMock, 1)).captureLastStatusChange(newOrders, null);
    }

    @IsTest
    private static void onBeforeUpdateTest_allEnabled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        List<Order> newOrders = new List<Order>();
        Map<Id, Order> oldOrders = new Map<Id, Order>();
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_CaptureLastStatusChange__c = true,
            Order_ValidateActivation__c = true,
            Order_ValidateShipment__c = true
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_BEFORE_UPDATE_HANDLER)).getFeaturesEnabler();
        ((OrderService) mocks.verify(serviceMock, 1)).captureLastStatusChange(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 1)).validateOrderStatusChangeToActivated(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 1)).validateOrderStatusChangeToShipped(newOrders, oldOrders);
    }

    @IsTest
    private static void onBeforeUpdateTest_allDisabled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        List<Order> newOrders = new List<Order>();
        Map<Id, Order> oldOrders = new Map<Id, Order>();
        FeaturesEnabler__c fe = new FeaturesEnabler__c();
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_BEFORE_UPDATE_HANDLER)).getFeaturesEnabler();
        ((OrderService) mocks.verify(serviceMock, 0)).captureLastStatusChange(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToActivated(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToShipped(newOrders, oldOrders);
    }

    @IsTest
    private static void onBeforeUpdateTest_validateOrderStatusChangeToShippedEnabled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        List<Order> newOrders = new List<Order>();
        Map<Id, Order> oldOrders = new Map<Id, Order>();
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_ValidateShipment__c = true
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_BEFORE_UPDATE_HANDLER)).getFeaturesEnabler();
        ((OrderService) mocks.verify(serviceMock, 0)).captureLastStatusChange(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToActivated(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 1)).validateOrderStatusChangeToShipped(newOrders, oldOrders);
    }

    @IsTest
    private static void onBeforeUpdateTest_validateOrderStatusChangeToActivatedEnabled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        List<Order> newOrders = new List<Order>();
        Map<Id, Order> oldOrders = new Map<Id, Order>();
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_ValidateActivation__c = true
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_BEFORE_UPDATE_HANDLER)).getFeaturesEnabler();
        ((OrderService) mocks.verify(serviceMock, 0)).captureLastStatusChange(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 1)).validateOrderStatusChangeToActivated(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToShipped(newOrders, oldOrders);
    }

    @IsTest
    private static void onBeforeUpdateTest_captureLastStatusChangeEnabled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CustomSettingsSelector selectorMock = (CustomSettingsSelector)mocks.mock(CustomSettingsSelector.class);
        CustomSettingsSelector.instance = selectorMock;
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        List<Order> newOrders = new List<Order>();
        Map<Id, Order> oldOrders = new Map<Id, Order>();
        FeaturesEnabler__c fe = new FeaturesEnabler__c(
            Order_CaptureLastStatusChange__c = true
        );
        mocks.startStubbing();
        mocks.when(selectorMock.getFeaturesEnabler()).thenReturn(fe);
        mocks.stopStubbing();
        OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
        ((CustomSettingsSelector) mocks.verify(selectorMock, FEATURES_ENABLER_CHECKS_AT_BEFORE_UPDATE_HANDLER)).getFeaturesEnabler();
        ((OrderService) mocks.verify(serviceMock, 1)).captureLastStatusChange(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToActivated(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToShipped(newOrders, oldOrders);
    }
}