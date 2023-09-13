public with sharing class AccountOrdersController {
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String ORDER_STATUS_ACTIVE = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    
    public with sharing class OrderDTO {

        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public Id contentDocumentId;
        
        public OrderDTO(Order order) {
            this.id = order.Id;
            this.orderNumber = order.OrderNumber;
            this.startDate = order.EffectiveDate;
            this.status = order.Status;
            this.amount = order.TotalAmount;
            if (order.AttachedContentDocuments.size() > 0) {
                this.contentDocumentId = order.AttachedContentDocuments[0].ContentDocumentId;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {       
        List<Order> orders = OrderSelector.selectOrdersByAccountId(accountId);
        
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        for(Order ord : orders) {
            orderDTOs.add(new OrderDTO(ord));
        }

        return orderDTOs;
    }

    @AuraEnabled
    public static Map<String, String> markOrderAsShipped(Id orderId) {
        Map<String, String> result = new Map<String, String>();
        List<Order> orders = OrderSelector.selectOrdersById(orderId);
        if (orders[0].Status == ORDER_STATUS_ACTIVE) {
            orders[0].Status = ORDER_STATUS_SHIPPED;
        } else {
            result.put('status', 'ERROR');
            result.put('message', 'Invalid Operation for Order #' + orderId);
            return result;
        }
        try {
            update orders[0];
            result.put('status', 'OK');
        } catch (DmlException e) {
            result.put('status', 'ERROR');
            result.put('message', 'Invalid Operation for Order #' + orderId);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, String> activateOrder(Id orderId) {
        Map<String, String> result = new Map<String, String>();
        List<Order> orders = OrderSelector.selectOrdersById(orderId);
        if (orders[0].Status == ORDER_STATUS_DRAFT) {
            orders[0].Status = ORDER_STATUS_ACTIVE;
        } else {
            result.put('status', 'ERROR');
            result.put('message', 'Invalid Operation for Order #' + orderId);
            return result;
        }
        try {
            update orders[0];
            result.put('status', 'OK');
        } catch (DmlException e) {
            result.put('status', 'ERROR');
            result.put('message', 'Invalid Operation for Order #' + orderId);
        }
        return result;
    }
}