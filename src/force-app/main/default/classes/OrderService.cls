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
     * @description buildOrders: Helper method used to rebuild Order records
     * with given Ids.
     * @param orderIds: Scope.
     * @return: Order records instances.
     */
    public List<Order> buildOrders(Set<Id> orderIds) {
        List<Order> result = new List<Order>();
        for (Id oId : orderIds) {
            result.add(
                new Order(
                    Id = oId
                )
            );
        }
        return result;
    }

    /**
     * @description setOrdersStatusToActived: Helper method used to apply
     * changes necessary to move given Order records to "Activated" Status.
     * @param orders: Orders to progress to "Activated" Status.
     * @note: Does not execute any DML operations.
     */
    public void setOrdersStatusToActived(List<Order> orders) {
        for (Order o : orders) {
            o.Status = Constants.ORDER_STATUS_ACTIVATED;
        }
    }

    /**
     * @description setOrdersStatusToShipped: Helper method used to apply 
     * changes necessary to move given Order records to "Shipped" Status.
     * @param orders: Orders to progress to "Shipped" Status.
     * @note: Does not execute any DML operations.
     */
    public void setOrdersStatusToShipped(List<Order> orders) {
        for (Order o : orders) {
            o.Status = Constants.ORDER_STATUS_ACTIVATED;
        }
    }

    /**
     * @description canBeActivated: Helper method used to conditionally
     * display "Activate" action button for 'AccountOrders' LWC
     * when criteria are met.
     * @param o: Order to check.
     * @return: "true" if "Status" value is "Draft", "false" otherwise.
     */
    public Boolean canBeActivated(Order o) {
        return Constants.ORDER_STATUS_DRAFT.equalsIgnoreCase(o.Status);
    }

    /**
     * @description canBeActivated: Helper method used to conditionally
     * display "Mark as Shipped" action button for 'AccountOrders' LWC
     * when criteria are met.
     * @param o: Order to check.
     * @return: "true" if "Status" value is "Activated", "false" otherwise.
     */
    public Boolean canBeShipped(Order o) {
        return Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(o.Status);
    }
}