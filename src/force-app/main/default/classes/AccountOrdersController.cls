public with sharing class AccountOrdersController {

    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String INVALID_OPERATION_FOR_ORDER = 'Invalid Operation for Order #';

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
        return bulkOrderAction(new List<Id>{orderId}, OrderAction.ACTIVATE_ORDER);
    }

    @AuraEnabled
    public static OrderActionResponse activateOrdersByIds(List<Id> orderIds) {
        return bulkOrderAction(orderIds, OrderAction.ACTIVATE_ORDER);
    }

    @AuraEnabled
    public static OrderActionResponse markAsShippedOrderById(Id orderId) {
        return bulkOrderAction(new List<Id>{orderId}, OrderAction.MARK_SHIPPED);
    }

    @AuraEnabled
    public static OrderActionResponse markAsShippedOrdersByIds(List<Id> orderIds) {
        return bulkOrderAction(orderIds, OrderAction.MARK_SHIPPED);
    }

    private static OrderActionResponse bulkOrderAction(List<Id> orderIds, OrderAction action) {
        if (orderIds == null || orderIds.isEmpty()) {
            return new OrderActionResponse(false, 'Missing Order Ids');
        }
        
        Order[] orders = new OrderSelector().getOrdersByIds(new Set<Id>(orderIds));
        
        if (orders.isEmpty()) {
            return new OrderActionResponse(false, 'Orders not found');
        }

        List<Order> ordersToUpdate = new List<Order>();

        for (Order ord : orders) {
            switch on action {
                when ACTIVATE_ORDER {
                    if (ord.Status == ORDER_STATUS_DRAFT) {
                        ord.Status = ORDER_STATUS_ACTIVE;
                        ordersToUpdate.add(ord);
                    } else {
                        return new OrderActionResponse(false, INVALID_OPERATION_FOR_ORDER + ord.OrderNumber);
                    }
                }
                when MARK_SHIPPED {
                    if (ord.Status == ORDER_STATUS_ACTIVE) {
                        ord.Status = ORDER_STATUS_SHIPPED;
                        ordersToUpdate.add(ord);
                    } else {
                        return new OrderActionResponse(false, INVALID_OPERATION_FOR_ORDER + ord.OrderNumber);
                    }
                }
                when else {
                    return new OrderActionResponse(false, INVALID_OPERATION_FOR_ORDER + ord.OrderNumber);
                }
            }
        }

        try {
            update ordersToUpdate;
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
        @AuraEnabled
        public Datetime lastStatusChangedTimestamp { get; private set; }

        public OrderDTO(Order order) {
            if (null == order) {
                return;
            }
            this.id = order.Id;
            this.orderNumber = order.OrderNumber;
            this.startDate = order.EffectiveDate;
            this.status = order.Status;
            this.amount = order.TotalAmount;
            this.lastStatusChangedTimestamp = order.LastStatusChanged__c;
            if (!order.ContentDocumentLinks.isEmpty()) {
                this.contentDocumentId = order.ContentDocumentLinks[0].ContentDocumentId;
            }
        }
    }
}