public with sharing class AccountOrdersController {
    private static final String ERROR_INVALID_ACOOUN_ID = 'Invalid Account ID provided.';
    private static final String ERROR_IVALID_OPERATION_FOR_ORDER = 'Invalid Operation for Order #';
    private static final String STATUS_OK = 'OK';
    private static final String STATUS_ERROR = 'ERROR';

    private static final String ORDER_STATUS_ACTIVATED = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    private static final String ORDER_STATUS_DRAFT = 'Draft';

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        if(accountId == null || String.isBlank(accountId)) {
            throw new IllegalArgumentException(ERROR_INVALID_ACOOUN_ID);
        }
        
        List<Order> orders = OrderSelector.getOrdersWithInvoiceInfo(accountId);
        List<OrderDTO> orderDTOList = new List<OrderDTO>();
        
        for(Order o : orders) {
            orderDTOList.add(new OrderDTO(o));
        }
        
        return orderDTOList;
    }

    @AuraEnabled
    public static Map<String, Object> activateOrder(Id orderId) {
        Map<String, Object> response = new Map<String, Object>();

        Order ord = OrderSelector.getOrderStatusById(orderId);
        if(ord.Status != ORDER_STATUS_DRAFT) {
            response.put('status', STATUS_ERROR);
            response.put('ErrorMessage', ERROR_IVALID_OPERATION_FOR_ORDER + orderId);
            return response;
        }

        ord.Status = ORDER_STATUS_ACTIVATED;
        update ord;

        response.put('status', STATUS_OK);
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> markOrderAsShipped(Id orderId) {
        Map<String, Object> response = new Map<String, Object>();

        Order ord = OrderSelector.getOrderStatusById(orderId);
        if(ord.Status != ORDER_STATUS_ACTIVATED) {
            response.put('status', STATUS_ERROR);
            response.put('ErrorMessage', ERROR_IVALID_OPERATION_FOR_ORDER + orderId);
            return response;
        }

        ord.Status = ORDER_STATUS_SHIPPED;
        update ord;

        response.put('status', STATUS_OK);
        return response;
    }

    public class OrderDTO {
        @AuraEnabled
        public Id orderId;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Date startDate;
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

        public OrderDTO(Order o) {
            this.orderId = o.Id;
            this.orderNumber = o.OrderNumber;
            this.status = o.Status;
            this.startDate = o.EffectiveDate;
            this.amount = o.TotalAmount;
            this.lastStatusChanged = o.LastStatusChanged__c;

            if(o.AttachedContentDocuments != null && !o.AttachedContentDocuments.isEmpty()) {
                this.invoiceId = o.AttachedContentDocuments[0].Id;
                this.invoiceName = o.AttachedContentDocuments[0].Title;
                this.contentDocumentId = o.AttachedContentDocuments[0].ContentDocumentId;
            }
        }
    }
}