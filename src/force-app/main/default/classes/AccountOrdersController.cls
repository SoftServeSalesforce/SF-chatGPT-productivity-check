public with sharing class AccountOrdersController {
    
    public with sharing class OrderDTO {
        public Id id;
        public String name;
        public String status;
        
        public OrderDTO(Order order) {
            this.id = order.Id;
            this.name = order.Name;
            this.status = order.Status;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {       
        List<Order> orders = OrderSelector.selectOrdersByAccountId(accountId);
        
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        for(Order ord : orders) {
            orderDTOs.add(new OrderDTO(ord));
        }

        return orderDTOs;
    }

}