public with sharing class AccountOrdersController {
    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        if(accountId == null || String.isBlank(accountId)) {
            throw new IllegalArgumentException('Invalid Account ID provided.');
        }
        
        List<Order> orders = OrderSelector.getOrdersByAccountId(accountId);
        List<OrderDTO> orderDTOList = new List<OrderDTO>();
        
        for(Order o : orders) {
            orderDTOList.add(new OrderDTO(o));
        }
        
        return orderDTOList;
    }

    public class OrderDTO {
        public Id orderId;
        public String orderName;
        
        public OrderDTO(Order o) {
            this.orderId = o.Id;
            this.orderName = o.Name;
        }
    }
}