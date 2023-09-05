public with sharing class AccountOrdersController {

    private static final String ORDER_STATUS_DRAFT = 'Draft';

    private enum OrderAction { ACTIVATE_ORDER, MARK_SHIPPED }
    private static final String ORDER_STATUS_ACTIVE = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';

    @AuraEnabled(Cacheable=true)
    public static OrderDTO[] getOrders(Id accountId) {
        if (null == accountId) {
            return new OrderDTO[]{};
        }
        OrderDTO[] orderDTOS = new OrderDTO[]{};
        for (Order order : new OrderSelector().getOrdersByAccountId(accountId)) {
            orderDTOS.add(new OrderDTO(order));
        }
        return orderDTOS;
    }

    @AuraEnabled
    public static OrderActionResponse activateOrderById(Id orderId) {
        return orderAction(orderId, OrderAction.ACTIVATE_ORDER);
    }

    @AuraEnabled
    public static OrderActionResponse markAsShippedOrderById(Id orderId) {
        return orderAction(orderId, OrderAction.MARK_SHIPPED);
    }

    private static OrderActionResponse orderAction(Id orderId, OrderAction action) {
        if (null == orderId) {
            return new OrderActionResponse(false, 'Missing Order Id');
        }
        Order[] orders = new OrderSelector().getOrdersByIds(new Set<Id>{orderId});
        if (orders.isEmpty()) {
            return new OrderActionResponse(false, 'Order not found');
        }
        switch on action {
            when ACTIVATE_ORDER {
                if (orders[0].Status == ORDER_STATUS_DRAFT) {
                    orders[0].Status = ORDER_STATUS_ACTIVE;
                } else {
                    return new OrderActionResponse(false, 'Invalid Operation for Order #' + orders[0].OrderNumber);
                }
            }
            when MARK_SHIPPED {
                if (orders[0].Status == ORDER_STATUS_ACTIVE) {
                    orders[0].Status = ORDER_STATUS_SHIPPED;
                } else {
                    return new OrderActionResponse(false, 'Invalid Operation for Order #' + orders[0].OrderNumber);
                }
            }
        }
        try {
            update orders[0];
            return new OrderActionResponse(true, null);
        } catch (DmlException e) {
            return new OrderActionResponse(false, e.getMessage());
        }
    }

    public class OrderActionResponse {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String errorMessage;
        public OrderActionResponse(Boolean statusOk, String errorMessage) {
            this.status = statusOk ? 'OK' : 'ERROR';
            this.errorMessage = errorMessage;
        }
    }

    public class OrderDTO {
        @AuraEnabled
        public Id id { get; private set; }
        @AuraEnabled
        public String orderNumber { get; private set; }
        @AuraEnabled
        public Date startDate { get; private set; }
        @AuraEnabled
        public String status { get; private set; }
        @AuraEnabled
        public Decimal amount { get; private set; }
        @AuraEnabled
        public Id contentDocumentId { get; private set; }

        public OrderDTO(Order order) {
            if (null == order) {
                return;
            }
            this.id = order.Id;
            this.orderNumber = order.OrderNumber;
            this.startDate = order.EffectiveDate;
            this.status = order.Status;
            this.amount = order.TotalAmount;
            if (order.ContentDocumentLinks.size() > 0) {
                this.contentDocumentId = order.ContentDocumentLinks[0].ContentDocumentId;
            }
        }
    }

}