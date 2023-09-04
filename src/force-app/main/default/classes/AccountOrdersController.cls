public with sharing class AccountOrdersController {

    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    
    private static final String ERROR_ORDER_INVALID_OPERATION = 'Invalid Operation for Order #';
    private static final String ERROR_EMPTY_INPUT = 'Please verify your input';
    private static final String STATUS_OK = 'OK';
    private static final String STATUS_ERROR = 'ERROR';

    
    // Wrapper class for Order SObject
    public class OrderDTO {
        @AuraEnabled
        public Id orderId;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public Id invoiceId;
        @AuraEnabled
        public String invoiceName;
        @AuraEnabled
        public Id contentDocumentId;
        @AuraEnabled
        public Datetime lastStatusChanged;
        
        
        public OrderDTO(Order ord) {
            this.orderId = ord.Id;
            this.orderNumber = ord.OrderNumber;
            this.startDate = ord.EffectiveDate; // Assuming this is the start date
            this.status = ord.Status;
            this.amount = ord.TotalAmount; // This might be a custom field. Adjust accordingly
            this.lastStatusChanged = ord.LastStatusChanged__c;
            
            if(!ord.AttachedContentDocuments.isEmpty()) {
                this.invoiceId = ord.AttachedContentDocuments[0].Id;
                this.invoiceName = ord.AttachedContentDocuments[0].Title;
                this.contentDocumentId = ord.AttachedContentDocuments[0].ContentDocumentId;
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        try {
            List<Order> orderList = OrderSelector.getOrdersByAccountId(accountId);
            List<OrderDTO> orderDTOList = new List<OrderDTO>();
            for(Order o : orderList) {
                orderDTOList.add(new OrderDTO(o));
            }

            return orderDTOList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> activateOrders(List<Id> orderIds) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            validateAndUpdateOrdersByStatus(orderIds, ORDER_STATUS_DRAFT, ORDER_STATUS_ACTIVATED);
            response.put('status', STATUS_OK);
        } catch(Exception e) {
            response.put('status', STATUS_ERROR);
            response.put('errorMessage', e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> markOrdersAsShipped(List<Id> orderIds) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            validateAndUpdateOrdersByStatus(orderIds, ORDER_STATUS_ACTIVATED, ORDER_STATUS_SHIPPED);
            response.put('status', STATUS_OK);
        } catch(Exception e) {
            response.put('status', STATUS_ERROR);
            response.put('errorMessage', e.getMessage());
        }
        return response;
    }

    private static void validateAndUpdateOrdersByStatus(List<Id> orderIds, String statusFrom, String newStatus) {
        if (orderIds.isEmpty()) {
            throw new OrderInvalidOperationException(ERROR_EMPTY_INPUT);
        }
        List<Order> orders = OrderSelector.getOrdersForUpdate(orderIds);
        for(Order ord: orders) {
            if(ord.Status != statusFrom) {
                throw new OrderInvalidOperationException(ERROR_ORDER_INVALID_OPERATION + ord.OrderNumber);
            }
            ord.Status = newStatus;
        }
        update orders;
    }
}
