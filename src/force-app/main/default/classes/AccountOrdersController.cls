public with sharing class AccountOrdersController {
    
    // Inner class for OrderDTO wrapper
    public class OrderDTO {
        @AuraEnabled
        public String orderNumber { get; set; }
        @AuraEnabled
        public Date orderDate { get; set; }
        @AuraEnabled
        public Decimal orderAmount { get; set; }
        @AuraEnabled
        public String orderStatus { get; set; }
        
        public OrderDTO(String orderNumber, Date orderDate, Decimal orderAmount, String orderStatus) {
            this.orderNumber = orderNumber;
            this.orderDate = orderDate;
            this.orderAmount = orderAmount;
            this.orderStatus = orderStatus;
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
            OrderDTO orderWrapper = new OrderDTO(order.OrderNumber, order.EffectiveDate, order.TotalAmount, order.Status);
            orderDTOs.add(orderWrapper);
        }
        
        return orderDTOs;
    }
}
