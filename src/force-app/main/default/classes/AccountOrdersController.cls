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
        public Datetime lastStatusChanged;
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
            this.lastStatusChanged = order.LastStatusChanged__c;
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
    public static Map<String, String> markOrderAsShipped(List<Id> orderIds) {
        Map<String, String> result = new Map<String, String>();
        List<Order> orders = OrderSelector.selectOrdersByIds(orderIds);
        result.put('status', 'OK');
        result.put('message', '');
        for (Order order : orders){
            if (order.Status == ORDER_STATUS_ACTIVE) {
                order.Status = ORDER_STATUS_SHIPPED;
            } else {
                result.put('status', 'ERROR');
                result.put('message', 'Invalid Operation for Order #' + order.Id);
                return result;
            }
        }
        
        try {
            update orders;
            result.put('status', 'OK');
        } catch (DmlException e) {
            result.put('status', 'ERROR');
            result.put('message', e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static Map<String, String> activateOrder(List<Id> orderIds) {
        Map<String, String> result = new Map<String, String>();
        List<Order> orders = OrderSelector.selectOrdersByIds(orderIds);
        result.put('status', 'OK');
        result.put('message', '');
        String message = '';
        for (Order order : orders){            
            if (order.Status == ORDER_STATUS_DRAFT) {
                order.Status = ORDER_STATUS_ACTIVE;
            } else {
                result.put('status', 'ERROR');
                result.put('message', 'Invalid Operation for Order #' + order.Id);
                return result;
            }
        }

        try {
            update orders;
            result.put('status', 'OK');
        } catch (DmlException e) {
            result.put('status', 'ERROR');
            result.put('message', e.getMessage());
        }
        return result;
    }
}