/**
 * @description OrderService: Order Service to capture Business logic.
 * //TODO: Cover with Apex Tests.
 */
public with sharing class OrderService {
    @TestVisible
    private static OrderService instance;

    /**
     * @description getInstance: Public access to the Class.
     * @return: Order Service instance.
     */
    public static OrderService getInstance() {
        if (instance == null) {
            instance = new OrderService();
        }
        return instance;
    }

    /**
     * @description setOrdersStatusToActived: Helper method used to apply
     * changes necessary to move given Order records to "Activated" Status.
     * @param orderIds: Ids of the Order records to progress to "Activated" Status.
     */
    public void setOrdersStatusToActived(List<Id> orderIds) {
        List<Order> orders = OrderSelector.getInstance().getOrdersById(
            new Set<Id> (orderIds)
        );
        for (Order o : orders) {
            if (Constants.ORDER_STATUS_DRAFT.equalsIgnoreCase(o.Status)) {
                o.Status = Constants.ORDER_STATUS_ACTIVATED;
            } else {
                throw new IllegalArgumentException(
                    String.format(
                        Constants.EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_ACTIVATED,
                        new List<String> { String.valueOf(o.OrderNumber), String.valueOf(Order.Status) }
                    )
                );
            }
        }
        update orders;
    }

    /**
     * @description setOrdersStatusToShipped: Helper method used to apply 
     * changes necessary to move given Order records to "Shipped" Status.
     * @param orderIds: Ids of the Order records to progress to "Shipped" Status.
     */
    public void setOrdersStatusToShipped(List<Id> orderIds) {
        List<Order> orders = OrderSelector.getInstance().getOrdersById(
            new Set<Id> (orderIds)
        );
        for (Order o : orders) {
            if (Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(o.Status)) {
                o.Status = Constants.ORDER_STATUS_SHIPPED;
            } else {
                throw new IllegalArgumentException(
                    String.format(
                        Constants.EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_SHIPPED,
                        new List<String> { String.valueOf(o.OrderNumber), String.valueOf(Order.Status) }
                    )
                );
            }
        }
        update orders;
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
            String oldStatus = null == oldOrders ? '' : oldOrders.get(o.Id).Status;
            if (!newStatus.equalsIgnoreCase(oldStatus)) {
                o.LastStatusChanged__c = Datetime.now();
            }
        }
    }
}