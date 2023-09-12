public with sharing class AccountOrdersController {
    
    public with sharing class OrderDTO {

        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Decimal amount;
        
        public OrderDTO(Order order) {
            this.id = order.Id;
            this.orderNumber = order.OrderNumber;
            this.startDate = order.EffectiveDate;
            this.status = order.Status;
            this.amount = order.TotalAmount;
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