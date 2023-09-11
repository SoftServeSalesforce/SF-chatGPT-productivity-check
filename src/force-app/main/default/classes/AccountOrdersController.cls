public with sharing class AccountOrdersController {

    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String INVALID_OPERATION_FOR_ORDER = 'Invalid Operation for Order #';

    private enum OrderAction { ACTIVATE_ORDER, MARK_SHIPPED }
    private static final String ORDER_STATUS_ACTIVE = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';

    @AuraEnabled(Cacheable=true)
    public static OrderPage getOrders(Id accountId, Integer pageNumber, Integer pageSize) {
        OrderPage orderPage = new OrderPage();
        if (orderPage.orders == null) {
            orderPage.orders = new List<OrderDTO>();
        }

        if (accountId == null) {
            return orderPage;
        }

        List<Order> allOrders = new OrderSelector().getOrdersByAccountId(accountId);
        if (allOrders == null) {
            allOrders = new List<Order>();
        }

        // Set total records count
        orderPage.totalRecords = allOrders.size();

        Integer startIndex = (pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, allOrders.size());

        for (Integer i = startIndex; i < endIndex; i++) {
            orderPage.orders.add(new OrderDTO(allOrders[i]));
        }

        System.debug('OrderPage being returned: ' + orderPage);
        return orderPage;
    }

    public class OrderPage {
        @AuraEnabled
        public List<OrderDTO> orders;
        @AuraEnabled
        public Integer totalRecords;
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

    @AuraEnabled(cacheable=true)
    public static Integer getPageSize() {
        try {
            UserInterfaceSettings__c setting = UserInterfaceSettings__c.getInstance();
            if (setting == null) {
                setting = new UserInterfaceSettings__c();
                setting.PageSize__c = 10; // Set a default page size if the setting doesn't exist
                upsert setting;
            }
            return setting.PageSize__c.intValue();
        } catch (Exception e) {
            System.debug('Exception in getPageSize: ' + e.getMessage());
            return 10; // Default page size in case of an error
        }
    }

    @AuraEnabled
    public static String setPageSize(Integer newSize) {
        try {
            UserInterfaceSettings__c setting = UserInterfaceSettings__c.getInstance();
            if (setting == null) {
                setting = new UserInterfaceSettings__c();
            }
            setting.PageSize__c = newSize;
            upsert setting;
            return 'OK';
        } catch (Exception e) {
            System.debug('Exception in setPageSize: ' + e.getMessage());
            return e.getMessage();
        }
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
        public Boolean isSelected { get; private set; }
        @AuraEnabled
        public String orderUrl { get; private set; }
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
            this.isSelected = false;
            this.orderNumber = order.OrderNumber;
            this.orderUrl = '/' + order.Id;
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