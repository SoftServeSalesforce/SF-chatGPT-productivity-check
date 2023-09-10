public with sharing class AccountOrdersController {
    private static final String ORDER_ACTIVATED_STATUS = 'Activated';
    private static final String ORDER_SHIPPED_STATUS = 'Shipped';



    @AuraEnabled
    public static List<OrderDTO> getOrders(Id accountId) {
        OrderSelector orderSelector = OrderSelector.newInstance();

        List<Order> orders = orderSelector.selectOrdersByAccountId(accountId);
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        
        for(Order ord : orders) {
            orderDTOs.add(new OrderDTO(ord));
        }

        return orderDTOs;
    }

    @AuraEnabled
    public static Map<String, String> activateOrder(Id orderId) {
        Map<String, String> response = new Map<String, String>();

        try {
            OrderSelector selector = OrderSelector.newInstance(); 
            List<Order> ordersToActivate = selector.selectDraftOrderById(orderId);
            
            if (ordersToActivate.isEmpty()) {
                response.put('status', 'ERROR');
                response.put('ErrorMessage', 'Invalid operation for Order#' + orderId);
                return response;
            }

            Order orderToActivate = ordersToActivate[0];
            orderToActivate.Status = ORDER_ACTIVATED_STATUS;
            update orderToActivate;

            response.put('status', 'OK');
            response.put('ErrorMessage', null);
        } catch (Exception e) {
            response.put('status', 'ERROR');
            response.put('ErrorMessage', 'An error occured: ' + e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, String> markOrderAsShipped(Id orderId) {
        Map<String, String> response = new Map<String, String>();

        try {
            OrderSelector selector = OrderSelector.newInstance(); 
            List<Order> ordersToMarkShipped = selector.selectActiveOrderById(orderId);
            
            if (ordersToMarkShipped.isEmpty()) {
                response.put('status', 'ERROR');
                response.put('ErrorMessage', 'Invalid operation for Order#' + orderId);
                return response;
            }

            Order orderToMarkShipped = ordersToMarkShipped[0];
            orderToMarkShipped.Status = ORDER_SHIPPED_STATUS;
            update orderToMarkShipped;

            response.put('status', 'OK');
            response.put('ErrorMessage', null);
        } catch (Exception e) {
            response.put('status', 'ERROR');
            response.put('ErrorMessage', 'An error occured: ' + e.getMessage());
        }
        return response;
    }

    public class OrderDTO {
        @AuraEnabled
        public Id Id { get; set; }
        @AuraEnabled
        public String OrderNumber { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public Decimal TotalAmount { get; set; }
        @AuraEnabled
        public Date EffectiveDate { get; set; }
        @AuraEnabled
        public Id ContentDocumentId { get; set;}
        @AuraEnabled
        public String InvoiceUrl { get; set; }
        @AuraEnabled
        public Datetime LastStatusChanged { get; set; }
        @AuraEnabled
        public Datetime CreatedDate { get; set;}

        public OrderDTO(Order ord) {
            this.Id = ord.Id;
            this.OrderNumber = ord.OrderNumber;
            this.Status = ord.Status;
            this.TotalAmount = ord.TotalAmount;
            this.EffectiveDate = ord.EffectiveDate;
            this.LastStatusChanged = ord.LastStatusChanged__c;
            this.CreatedDate = ord.CreatedDate;
            if (ord.AttachedContentDocuments != null && !ord.AttachedContentDocuments.isEmpty()) {
                List<AttachedContentDocument> subq = (List<AttachedContentDocument>) ord.AttachedContentDocuments;
                this.ContentDocumentId = subq[0].ContentDocumentId;
                this.InvoiceUrl = '/sfc/servlet.shepherd/document/download/' + this.ContentDocumentId;
            }
        }
    }
}
