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
                OrderTriggerHandler.getInstance().onBeforeInsert(newOrders);
            }
            when BEFORE_UPDATE {
                OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
            }
            when else {
                throw new IllegalArgumentException(Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE);
            }
        }
    }

    private void onBeforeInsert(List<Order> newOrders) {
        OrderService.getInstance().captureLastStatusChange(newOrders, null);
    }

    private void onBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        OrderService.getInstance().captureLastStatusChange(newOrders, oldOrders);
    }
}