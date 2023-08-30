public with sharing class AccountOrdersController {
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

        public OrderDTO(Order ord) {
            this.Id = ord.Id;
            this.OrderNumber = ord.OrderNumber;
            this.Status = ord.Status;
            this.TotalAmount = ord.TotalAmount;
            this.EffectiveDate = ord.EffectiveDate;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        OrderSelector orderSelector = OrderSelector.newInstance();

        List<Order> orders = orderSelector.selectOrdersByAccountId(accountId);
        
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        for(Order ord : orders) {
            orderDTOs.add(new OrderDTO(ord));
        }
        
        return orderDTOs;
    }
}
