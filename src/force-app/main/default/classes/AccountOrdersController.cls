public with sharing class AccountOrdersController {
    
    // Inner class for OrderDTO wrapper
    public class OrderDTO {
        @AuraEnabled
        public Id orderId { get; set; }
        @AuraEnabled
        public String orderName { get; set; }
        @AuraEnabled
        public String orderNumber { get; set; }
        @AuraEnabled
        public String orderStatus { get; set; }
        
        public OrderDTO(Id orderId, String orderName, String orderNumber, String orderStatus) {
            this.orderId = orderId;
            this.orderName = orderName;
            this.orderNumber = orderNumber;
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
            OrderDTO orderWrapper = new OrderDTO(order.Id, order.Name, order.OrderNumber, order.Status);
            orderDTOs.add(orderWrapper);
        }
        
        return orderDTOs;
    }
}
