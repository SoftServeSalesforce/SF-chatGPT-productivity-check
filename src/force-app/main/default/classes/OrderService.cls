/**
 * @description OrderService: Order Service to capture Business logic.
 * @note: Uses inherited sharing to enforce the sharing rules of the class that calls it.
 * //TODO: Cover with Apex Tests.
 */
public inherited sharing class OrderService {
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
     * @param orders: Orders to progress to "Activated" Status.
     * @note: Does not execute any DML operations.
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
     * @param orders: Orders to progress to "Shipped" Status.
     * @note: Does not execute any DML operations.
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
}