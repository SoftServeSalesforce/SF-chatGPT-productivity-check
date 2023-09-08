@IsTest
public with sharing class TestOrderService {
    @IsTest
    private static void setOrdersStatusToActivedTest_negative() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_DELIVERED
        );
        List<Order> newOrders = new List<Order> { newOrder };
        OrderService.getInstance().setOrdersStatusToActived(newOrders);
        System.assertNotEquals(Constants.ORDER_STATUS_ACTIVATED, newOrder.Status);
    }

    @IsTest
    private static void setOrdersStatusToActivedTest_positive() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_DRAFT
        );
        List<Order> newOrders = new List<Order> { newOrder };
        OrderService.getInstance().setOrdersStatusToActived(newOrders);
        System.assertEquals(Constants.ORDER_STATUS_ACTIVATED, newOrder.Status);
    }

    @IsTest
    private static void setOrdersStatusToShippedTest_negative() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_DRAFT
        );
        List<Order> newOrders = new List<Order> { newOrder };
        OrderService.getInstance().setOrdersStatusToShipped(newOrders);
        System.assertNotEquals(Constants.ORDER_STATUS_SHIPPED, newOrder.Status);
    }

    @IsTest
    private static void setOrdersStatusToShippedTest_positive() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_ACTIVATED
        );
        List<Order> newOrders = new List<Order> { newOrder };
        OrderService.getInstance().setOrdersStatusToShipped(newOrders);
        System.assertEquals(Constants.ORDER_STATUS_SHIPPED, newOrder.Status);
    }

    @IsTest
    private static void captureLastStatusChangeTest_onInsert() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_SHIPPED
        );
        List<Order> newOrders = new List<Order> { newOrder };
        OrderService.getInstance().captureLastStatusChange(newOrders, null);
        System.assertNotEquals(null, newOrder.LastStatusChanged__c);
    }

    @IsTest
    private static void captureLastStatusChangeTest_negativeOnUpdate() {
        Datetime oldLastStatusChanged = Datetime.now().addDays(-1);
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_SHIPPED,
            LastStatusChanged__c = oldLastStatusChanged
        );
        Order oldOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_SHIPPED,
            LastStatusChanged__c = oldLastStatusChanged
        );
        List<Order> newOrders = new List<Order> { newOrder };
        Map<Id, Order> oldOrders = new Map<Id, Order> { orderId => oldOrder };
        OrderService.getInstance().captureLastStatusChange(newOrders, oldOrders);
        System.assertEquals(oldLastStatusChanged, oldOrder.LastStatusChanged__c);
        System.assertEquals(oldLastStatusChanged, newOrder.LastStatusChanged__c);
    }

    @IsTest
    private static void captureLastStatusChangeTest_positiveOnUpdate() {
        Datetime oldLastStatusChanged = Datetime.now().addDays(-1);
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_ACTIVATED,
            LastStatusChanged__c = oldLastStatusChanged
        );
        Order oldOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_SHIPPED,
            LastStatusChanged__c = oldLastStatusChanged
        );
        List<Order> newOrders = new List<Order> { newOrder };
        Map<Id, Order> oldOrders = new Map<Id, Order> { orderId => oldOrder };
        OrderService.getInstance().captureLastStatusChange(newOrders, oldOrders);
        System.assertEquals(oldLastStatusChanged, oldOrder.LastStatusChanged__c);
        System.assertNotEquals(oldLastStatusChanged, newOrder.LastStatusChanged__c);
        System.assert(oldOrder.LastStatusChanged__c < newOrder.LastStatusChanged__c);
    }

    @IsTest
    private static void validateOrderStatusChangeToActivatedTest_negative() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_ACTIVATED
        );
        Order oldOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_SHIPPED
        );
        List<Order> newOrders = new List<Order> { newOrder };
        Map<Id, Order> oldOrders = new Map<Id, Order> { orderId => oldOrder };
        OrderService.getInstance().validateOrderStatusChangeToActivated(newOrders, oldOrders);
        System.assert(newOrder.hasErrors());
        List<Database.Error> errors = newOrder.getErrors();
        List<String> errorMessages = new List<String>();
        for (Database.Error err : errors) {
            errorMessages.add(err.getMessage());
        }
        System.assert(errorMessages.contains(String.format(
            Constants.EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_ACTIVATED,
            new List<String> { String.valueOf(newOrder.Status) }
        )));
    }

    @IsTest
    private static void validateOrderStatusChangeToActivatedTest_positive() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_ACTIVATED
        );
        Order oldOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_DRAFT
        );
        List<Order> newOrders = new List<Order> { newOrder };
        Map<Id, Order> oldOrders = new Map<Id, Order> { orderId => oldOrder };
        OrderService.getInstance().validateOrderStatusChangeToActivated(newOrders, oldOrders);
        System.assert(!newOrder.hasErrors());
    }

    @IsTest
    private static void validateOrderStatusChangeToShippedTest_negative() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_SHIPPED
        );
        Order oldOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_DRAFT
        );
        List<Order> newOrders = new List<Order> { newOrder };
        Map<Id, Order> oldOrders = new Map<Id, Order> { orderId => oldOrder };
        OrderService.getInstance().validateOrderStatusChangeToShipped(newOrders, oldOrders);
        System.assert(newOrder.hasErrors());
        List<Database.Error> errors = newOrder.getErrors();
        List<String> errorMessages = new List<String>();
        for (Database.Error err : errors) {
            errorMessages.add(err.getMessage());
        }
        System.assert(errorMessages.contains(String.format(
            Constants.EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_SHIPPED,
            new List<String> { String.valueOf(newOrder.Status) }
        )));
    }

    @IsTest
    private static void validateOrderStatusChangeToShippedTest_positive() {
        Id orderId = fflib_IDGenerator.generate(Order.SobjectType);
        Order newOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_SHIPPED
        );
        Order oldOrder = new Order(
            Id = orderId,
            Status = Constants.ORDER_STATUS_ACTIVATED
        );
        List<Order> newOrders = new List<Order> { newOrder };
        Map<Id, Order> oldOrders = new Map<Id, Order> { orderId => oldOrder };
        OrderService.getInstance().validateOrderStatusChangeToShipped(newOrders, oldOrders);
        System.assert(!newOrder.hasErrors());
    }
}