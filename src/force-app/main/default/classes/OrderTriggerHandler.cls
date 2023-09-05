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
}