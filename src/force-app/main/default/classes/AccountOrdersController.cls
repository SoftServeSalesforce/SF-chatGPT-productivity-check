public with sharing class AccountOrdersController {
    
    // Inner class for OrderDTO wrapper
    public class OrderDTO {
        @AuraEnabled
        public String orderId { get; set; }
        @AuraEnabled
        public String orderNumber { get; set; }
        @AuraEnabled
        public Date orderDate { get; set; }
        @AuraEnabled
        public Decimal orderAmount { get; set; }
        @AuraEnabled
        public String orderStatus { get; set; }
        @AuraEnabled
        public String latestInvoiceFileName {get; set; }
        @AuraEnabled
        public String cdURL {get; set; }
        @AuraEnabled
        public Id invoiceId {get; set; }
        
        public OrderDTO(String orderNumber, Date orderDate, Decimal orderAmount, String orderStatus, String latestInvoiceFileName, 
                        String cdURL, String orderId, Id invoiceId) {
            this.orderNumber = orderNumber;
            this.orderDate = orderDate;
            this.orderAmount = orderAmount;
            this.orderStatus = orderStatus;
            this.latestInvoiceFileName = latestInvoiceFileName;
            this.cdURL = cdURL;
            this.orderId = orderId;
            this.invoiceId = invoiceId;
        }
    }
    
    // Method to retrieve orders for a specified account
    @AuraEnabled
    public static List<OrderDTO> getOrders(Id accountId) {
        OrderSelector orderSelector = OrderSelector.create();
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        
        // Query for orders related to the specified account
        List<Order> orders = orderSelector.getOrdersForAccount(accountId);

        // Convert Order SObjects to OrderDTO wrappers
        for (Order order : orders) {
            ContentDocument latestInvoiceFile = orderSelector.getLatestInvoiceFile(order.OrderNumber);
            String latestInvoiceFileName = (latestInvoiceFile != null) ? latestInvoiceFile.Title : '';
            String cdURL = orderSelector.getUrlForInvoice(latestInvoiceFile.Id);
            OrderDTO orderWrapper = new OrderDTO(order.OrderNumber, order.EffectiveDate, order.TotalAmount, order.Status, 
                                                latestInvoiceFileName, cdURL, '/' + order.Id, latestInvoiceFile.Id);
            orderDTOs.add(orderWrapper);
        }
        
        return orderDTOs;
    }

    // Action method to activate an order
    @AuraEnabled
    public static Map<String, String> activateOrder(String orderNumber) {
        OrderSelector orderSelector = OrderSelector.create();
        Map<String, String> response = new Map<String, String>();
        response.put('status', 'ERROR');
        
        Order order = orderSelector.getOrderByNumber(orderNumber);

        if (order != null) {
            if (order.Status == 'Pending') {
                order.Status = 'Active';
                update order;
                response.put('status', 'OK');
                response.put('ErrorMessage', null);
            } else {
                response.put('ErrorMessage', 'Invalid Operation: Order is not in Pending status.');
            }
        } else {
            response.put('ErrorMessage', 'Invalid Order Number: Order not found.');
        }
        
        return response;
    }

    // Action method to mark an order as shipped
    @AuraEnabled
    public static Map<String, String> markOrderAsShipped(String orderNumber) {
        OrderSelector orderSelector = OrderSelector.create();
        Map<String, String> response = new Map<String, String>();
        response.put('status', 'ERROR');
        
        Order order = orderSelector.getOrderByNumber(orderNumber);

        if (order != null) {
            if (order.Status == 'Active') {
                order.Status = 'Shipped';
                update order;
                response.put('status', 'OK');
                response.put('ErrorMessage', null);
            } else {
                response.put('ErrorMessage', 'Invalid Operation: Order is not in Active status.');
            }
        } else {
            response.put('ErrorMessage', 'Invalid Order Number: Order not found.');
        }
        
        return response;
    }
}
