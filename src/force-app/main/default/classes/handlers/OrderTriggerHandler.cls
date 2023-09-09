public with sharing class OrderTriggerHandler {
    //Testing support.
    // @TestVisible

    @TestVisible
    private static OrderTriggerHandler instance;

    public static OrderTriggerHandler getInstance() {
        if (instance == null) {
            instance = new OrderTriggerHandler();
        }
        return instance;
    }

    public void run(List<Order> newOrders, Map<Id, Order> oldOrders, TriggerOperation operation) {
        if (!CustomSettingsSelector.getInstance().getFeaturesEnabler().Order_Trigger__c) {
            return;
        }
        switch on operation {
            when BEFORE_INSERT {
                validateContextOnBeforeInsert(newOrders);
                onBeforeInsert(newOrders);
            }
            when BEFORE_UPDATE {
                validateContextOnBeforeUpdate(newOrders, oldOrders);
                onBeforeUpdate(newOrders, oldOrders);
            }
            when else {
                throw new IllegalArgumentException(Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE);
            }
        }
    }

    @TestVisible
    private void validateContextOnBeforeInsert(List<Order> newOrders) {
        if (null == newOrders) {
            throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL);
        }
        if (newOrders.isEmpty()) {
            throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY);
        }
    }

    @TestVisible
    private void validateContextOnBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
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
        if (newOrders.size() != oldOrders.size()) {
            throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_AND_OLD_SIZES_SHOULD_MATCH);
        }
        for (Order o : newOrders) {
            if (null == o.Id) {
                throw new IllegalArgumentException(Constants.EXCEPTION_TRIGGER_NEW_ITEMS_SHOULD_HAVE_IDS_ON_UPDATE);
            }
            if (!oldOrders.containsKey(o.Id)) {
                throw new IllegalArgumentException(Constants.EXCEPTION_EACH_TRIGGER_NEW_ITEM_SHOULD_HAVE_CORRESPONDING_OLD_ITEM_ON_UPDATE);
            }
        }
    }

    @TestVisible
    private void onBeforeInsert(List<Order> newOrders) {
        if (CustomSettingsSelector.getInstance().getFeaturesEnabler().Order_CaptureLastStatusChange__c) {
            OrderService.getInstance().captureLastStatusChange(newOrders, null);
        }
    }

    @TestVisible
    private void onBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        OrderService service = OrderService.getInstance();
        if (CustomSettingsSelector.getInstance().getFeaturesEnabler().Order_CaptureLastStatusChange__c) {
            service.captureLastStatusChange(newOrders, oldOrders);
        }
        if (CustomSettingsSelector.getInstance().getFeaturesEnabler().Order_ValidateActivation__c) {
            service.validateOrderStatusChangeToActivated(newOrders, oldOrders);
        }
        if (CustomSettingsSelector.getInstance().getFeaturesEnabler().Order_ValidateShipment__c) {
            service.validateOrderStatusChangeToShipped(newOrders, oldOrders);
        }
    }
}