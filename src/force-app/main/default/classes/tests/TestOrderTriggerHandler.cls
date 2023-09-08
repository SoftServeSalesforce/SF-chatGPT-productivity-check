@IsTest
public with sharing class TestOrderTriggerHandler {
    @IsTest
    private static void runTest_allValidOnBeforeUpdate() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderTriggerHandler handlerMock = (OrderTriggerHandler)mocks.mock(OrderTriggerHandler.class);
        OrderTriggerHandler.instance = handlerMock;
        //Prepare data.
        Order newOrder = new Order (
            Id = fflib_IDGenerator.generate(Order.SobjectType),
            Status = Constants.ORDER_STATUS_DRAFT
        );
        Order oldOrder = new Order (
            Id = newOrder.Id,
            Status = Constants.ORDER_STATUS_ACTIVATED
        );
        List<Order> newOrders = new List<Order> { newOrder };
        Map<Id, Order> oldOrders = new Map<Id, Order> { oldOrder.Id => oldOrder };
        //Execute scenario.
        OrderTriggerHandler.getInstance().run(newOrders, oldOrders, TriggerOperation.BEFORE_UPDATE);
        //Verify outcomes.
        ((OrderTriggerHandler) mocks.verify(handlerMock, 1)).onBeforeUpdate(newOrders, oldOrders);
    }

    @IsTest
    private static void runTest_allValidOnBeforeInsert() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderTriggerHandler handlerMock = (OrderTriggerHandler)mocks.mock(OrderTriggerHandler.class);
        OrderTriggerHandler.instance = handlerMock;
        //Prepare data.
        Order newOrder = new Order (
            Id = fflib_IDGenerator.generate(Order.SobjectType),
            Status = Constants.ORDER_STATUS_DRAFT
        );
        List<Order> newOrders = new List<Order> { newOrder };
        //Execute scenario.
        OrderTriggerHandler.getInstance().run(newOrders, null, TriggerOperation.BEFORE_INSERT);
        //Verify outcomes.
        ((OrderTriggerHandler) mocks.verify(handlerMock, 1)).onBeforeInsert(newOrders);
    }

    @IsTest
    private static void runTest_oldMapIsEmptyOnBeforeUpdate() {
        String expected = Constants.EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_EMPTY;
        String actual;
        try {
            Order o = new Order(
                Id = fflib_IDGenerator.generate(Order.SobjectType)
            );
            OrderTriggerHandler.getInstance().run(new List<Order> { o }, new Map<Id, Order>(), TriggerOperation.BEFORE_UPDATE);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_oldMapIsNullOnBeforeUpdate() {
        String expected = Constants.EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_NULL;
        String actual;
        try {
            Order o = new Order(
                Id = fflib_IDGenerator.generate(Order.SobjectType)
            );
            OrderTriggerHandler.getInstance().run(new List<Order> { o }, null, TriggerOperation.BEFORE_UPDATE);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_newListIsEmptyOnBeforeUpdate() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY;
        String actual;
        try {
            OrderTriggerHandler.getInstance().run(new List<Order>(), null, TriggerOperation.BEFORE_UPDATE);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_newListIsNullOnBeforeUpdate() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL;
        String actual;
        try {
            OrderTriggerHandler.getInstance().run(null, null, TriggerOperation.BEFORE_UPDATE);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_newListIsEmptyOnBeforeInsert() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY;
        String actual;
        try {
            OrderTriggerHandler.getInstance().run(new List<Order>(), null, TriggerOperation.BEFORE_INSERT);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_newListIsNullOnBeforeInsert() {
        String expected = Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL;
        String actual;
        try {
            OrderTriggerHandler.getInstance().run(null, null, TriggerOperation.BEFORE_INSERT);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_operationTypeIsNotSupported() {
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;
        try {
            OrderTriggerHandler.getInstance().run(null, null, TriggerOperation.BEFORE_DELETE);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void runTest_operationTypeIsNull() {
        String expected = Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE;
        String actual;
        try {
            OrderTriggerHandler.getInstance().run(null, null, null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void onBeforeInsertTest() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        //Prepare data.
        List<Order> newOrders = new List<Order>();
        //Execute scenario.
        OrderTriggerHandler.getInstance().onBeforeInsert(newOrders);
        //Verify outcomes.
        ((OrderService) mocks.verify(serviceMock, 1)).captureLastStatusChange(newOrders, null);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToActivated(newOrders, null);
        ((OrderService) mocks.verify(serviceMock, 0)).validateOrderStatusChangeToShipped(newOrders, null);
    }

    @IsTest
    private static void onBeforeUpdateTest() {
        //Prepare mocks.
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OrderService serviceMock = (OrderService)mocks.mock(OrderService.class);
        OrderService.instance = serviceMock;
        //Prepare data.
        List<Order> newOrders = new List<Order>();
        Map<Id, Order> oldOrders = new Map<Id, Order>();
        //Execute scenario.
        OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
        //Verify outcomes.
        ((OrderService) mocks.verify(serviceMock, 1)).captureLastStatusChange(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 1)).validateOrderStatusChangeToActivated(newOrders, oldOrders);
        ((OrderService) mocks.verify(serviceMock, 1)).validateOrderStatusChangeToShipped(newOrders, oldOrders);
    }
}