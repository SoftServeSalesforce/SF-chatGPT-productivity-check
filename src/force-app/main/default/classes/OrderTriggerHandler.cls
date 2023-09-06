public with sharing class OrderTriggerHandler {
    @TestVisible
    private static OrderTriggerHandler instance;

    public static OrderTriggerHandler getInstance() {
        if (instance == null) {
            instance = new OrderTriggerHandler();
        }
        return instance;
    }

    public void onBeforeInsert(List<Order> newOrders) {
        OrderService.getInstance().captureLastStatusChange(newOrders, null);
    }

    public void onBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        OrderService.getInstance().captureLastStatusChange(newOrders, oldOrders);
    }

    public static void run(List<Order> newOrders, Map<Id, Order> oldOrders) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                OrderTriggerHandler.getInstance().onBeforeInsert(newOrders);
            }
            when BEFORE_UPDATE {
                OrderTriggerHandler.getInstance().onBeforeUpdate(newOrders, oldOrders);
            }
        }
    }
}