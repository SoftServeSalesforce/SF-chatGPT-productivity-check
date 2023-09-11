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
    public static Map<String, String> activateOrder(List<Id> orderIds) {
        system.debug('input ids ' + orderIds);
        Map<String, String> response = new Map<String, String>();

        try {
            OrderSelector selector = OrderSelector.newInstance(); 
            List<Order> ordersToActivate = selector.selectDraftOrderById(orderIds);
            system.debug('selected ids ' + ordersToActivate);

            if (ordersToActivate.isEmpty()) {
                response.put('status', 'ERROR');
                response.put('ErrorMessage', 'Invalid operation for Order#' + orderIds);
                return response;
            }

            for (Order ord : ordersToActivate) {
                ord.Status = ORDER_ACTIVATED_STATUS;
            }
            update ordersToActivate;

            response.put('status', 'OK');
            response.put('ErrorMessage', null);
        } catch (Exception e) {
            response.put('status', 'ERROR');
            response.put('ErrorMessage', 'An error occured: ' + e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, String> markOrderAsShipped(List<Id> orderIds) {
        Map<String, String> response = new Map<String, String>();

        try {
            OrderSelector selector = OrderSelector.newInstance(); 
            List<Order> ordersToMarkShipped = selector.selectActiveOrderById(orderIds);
            
            if (ordersToMarkShipped.isEmpty()) {
                response.put('status', 'ERROR');
                response.put('ErrorMessage', 'Invalid operation for Order#' + orderIds);
                return response;
            }

            for (Order ord : ordersToMarkShipped) {
                ord.Status = ORDER_SHIPPED_STATUS;
            }
            update ordersToMarkShipped;

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
