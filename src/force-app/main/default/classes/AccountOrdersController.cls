public with sharing class AccountOrdersController {

    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    
    private static final String ERROR_ORDER_INVALID_OPERATION = 'Invalid Operation for Order #';
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
        
        
        public OrderDTO(Order ord) {
            this.orderId = ord.Id;
            this.orderNumber = ord.OrderNumber;
            this.startDate = ord.EffectiveDate; // Assuming this is the start date
            this.status = ord.Status;
            this.amount = ord.TotalAmount; // This might be a custom field. Adjust accordingly
            
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
    public static Map<String, Object> activateOrder(Id orderId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            Order ord = OrderSelector.getOrderForUpdate(orderId);
            if(ord.Status != ORDER_STATUS_DRAFT) {
                response.put('status', STATUS_ERROR);
                response.put('ErrorMessage', ERROR_ORDER_INVALID_OPERATION + ord.Id);
                return response;
            }
            ord.Status = ORDER_STATUS_ACTIVATED;
            update ord;
            response.put('status', STATUS_OK);
        } catch(Exception e) {
            response.put('status', STATUS_ERROR);
            response.put('ErrorMessage', e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> markOrderAsShipped(Id orderId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            Order ord = OrderSelector.getOrderForUpdate(orderId);
            if(ord.Status != ORDER_STATUS_ACTIVATED) {
                response.put('status', STATUS_ERROR);
                response.put('ErrorMessage', ERROR_ORDER_INVALID_OPERATION + ord.Id);
                return response;
            }
            ord.Status = ORDER_STATUS_SHIPPED;
            update ord;
            response.put('status', STATUS_OK);
        } catch(Exception e) {
            response.put('status', STATUS_ERROR);
            response.put('ErrorMessage', e.getMessage());
        }
        return response;
    }
}
