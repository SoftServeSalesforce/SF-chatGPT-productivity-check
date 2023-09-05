public with sharing class OrderTriggerHandler extends TriggerHandler {
    public OrderTriggerHandler() {
        super();
    }

    public override void beforeInsert() {
        updateLastStatusChanged();
    }

    public override void beforeUpdate() {
        updateLastStatusChanged();
    }

    private void updateLastStatusChanged() {
        for (SObject order : super.newRecords) {
            if (isStatusChanged(order)) {
                ((Order) order).LastStatusChanged__c = Datetime.now();
            }
        }
    }

    private Boolean isStatusChanged(SObject order) {
        Order newOrder = (Order) order;
        Order oldOrder = (Order) super.oldRecordMap?.get(order.Id);
        return oldOrder == null || newOrder.Status != oldOrder.Status;
    }
}