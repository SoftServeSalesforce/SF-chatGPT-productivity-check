public with sharing class OrderTriggerHandler {
    @TestVisible
    private static OrderTriggerHandler instance;

    public static OrderTriggerHandler getInstance() {
        if (instance == null) {
            instance = new OrderTriggerHandler();
        }
        return instance;
    }

    public void run(List<Order> newOrders, Map<Id, Order> oldOrders, TriggerOperation operation) {
        switch on operation {
            when BEFORE_INSERT {
                if (null == newOrders) {
                    throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL);
                }
                if (newOrders.isEmpty()) {
                    throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY);
                }
                OrderTriggerHandler.getInstance().onBeforeInsert(newOrders);
            }
            when BEFORE_UPDATE {
                if (null == newOrders) {
                    throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL);
                }
                if (newOrders.isEmpty()) {
                    throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY);
                }
                if (null == oldOrders) {
                    throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_NULL);
                }
                if (oldOrders.isEmpty()) {
                    throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_EMPTY);
                }
                OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
            }
            when else {
                throw new IllegalArgumentException(Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE);
            }
        }
    }

    @TestVisible
    private void onBeforeInsert(List<Order> newOrders) {
        OrderService.getInstance().captureLastStatusChange(newOrders, null);
    }

    @TestVisible
    private void onBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        OrderService service = OrderService.getInstance();
        service.captureLastStatusChange(newOrders, oldOrders);
        service.validateOrderStatusChangeToActivated(newOrders, oldOrders);
        service.validateOrderStatusChangeToShipped(newOrders, oldOrders);
    }
}