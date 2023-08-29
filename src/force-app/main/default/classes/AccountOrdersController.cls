public with sharing class AccountOrdersController {
    
    // Wrapper class for Order SObject
    public class OrderDTO {
        public Id orderId;
        public String orderName;
        // Add other fields as necessary
        
        public OrderDTO(Order o) {
            this.orderId = o.Id;
            this.orderName = o.Name;
            // map other fields
        }
    }
    
    @AuraEnabled
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
}
