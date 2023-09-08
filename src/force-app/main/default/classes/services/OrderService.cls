/**
 * @description OrderService: Order Service to capture Business logic.
 */
public with sharing class OrderService {
    @TestVisible
    private static OrderService instance;

    public static OrderService getInstance() {
        if (instance == null) {
            instance = new OrderService();
        }
        return instance;
    }

    /**
     * @description setOrdersStatusToActived: Helper method used to apply
     * changes necessary to move given Order records to "Activated" Status.
     * @param orders: Scope.
     */
    public List<Database.SaveResult> setOrdersStatusToActived(List<Order> orders) {
        for (Order o : orders) {
            if (Constants.ORDER_STATUS_DRAFT.equalsIgnoreCase(o.Status)) {
                o.Status = Constants.ORDER_STATUS_ACTIVATED;
            }
        }
        return Database.update(orders, false);
    }

    /**
     * @description setOrdersStatusToShipped: Helper method used to apply 
     * changes necessary to move given Order records to "Shipped" Status.
     * @param orders: Scope.
     */
    public List<Database.SaveResult> setOrdersStatusToShipped(List<Order> orders) {
        for (Order o : orders) {
            if (Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(o.Status)) {
                o.Status = Constants.ORDER_STATUS_SHIPPED;
            }
        }
        return Database.update(orders, false);
    }

    /**
     * @description captureLastStatusChange: Method used to update "LastStatusChanged__c"
     * field on Status change.
     * @param newOrders: A list of the new versions of the Order records.
     * @param oldOrders: A map of IDs to the old versions of the Order records.
     * @note: Does not execute any DML operations, so should be executed from
     * Trigger's BEFORE insert/update context.
     */
    public void captureLastStatusChange(List<Order> newOrders, Map<Id, Order> oldOrders) {
        for (Order o : newOrders) {
            String newStatus = o.Status;
            String oldStatus = null == oldOrders ? '' : oldOrders.get(o.Id)?.Status;
            if (!newStatus.equalsIgnoreCase(oldStatus)) {
                o.LastStatusChanged__c = Datetime.now();
            }
        }
    }

    public void validateOrderStatusChangeToActivated(List<Order> newOrders, Map<Id, Order> oldOrders) {
        for (Order o : newOrders) {
            String newStatus = o.Status;
            String oldStatus = oldOrders.get(o.Id).Status;
            if (
                !newStatus.equalsIgnoreCase(oldStatus)
                && Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(newStatus)
                && !Constants.ORDER_STATUS_DRAFT.equalsIgnoreCase(oldStatus)
            ) {
                o.addError(String.format(
                    Constants.EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_ACTIVATED,
                    new List<String> { String.valueOf(o.Status) }
                ));
            }
        }   
    }

    public void validateOrderStatusChangeToShipped(List<Order> newOrders, Map<Id, Order> oldOrders) {
        for (Order o : newOrders) {
            String newStatus = o.Status;
            String oldStatus = oldOrders.get(o.Id).Status;
            if (
                !newStatus.equalsIgnoreCase(oldStatus)
                && Constants.ORDER_STATUS_SHIPPED.equalsIgnoreCase(newStatus)
                && !Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(oldStatus)
            ) {
                o.addError(String.format(
                    Constants.EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_SHIPPED,
                    new List<String> { String.valueOf(o.Status) }
                ));
            }
        }   
    }
}