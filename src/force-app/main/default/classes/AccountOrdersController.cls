public with sharing class AccountOrdersController {

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        List<OrderDTO> result = new List<OrderDTO>();
        List<Order> accOrders = OrderSelector.getOrdersbyAccountId(accountId);
        for (Order o : accOrders) {
            OrderDTO temp = new OrderDTO(o);
            result.add(temp);
        }
        return result;
    }

    public static String activateOrder(OrderDTO source, String status){}
    
    public static String marOrderAsShipped(OrderDTO source, String status){}

    public class OrderDTO {
        @AuraEnabled public Id id{get;set;}
        @AuraEnabled public Id accountId{get; set;}
        @AuraEnabled public String orderNumber{get;set;}
        @AuraEnabled public Date orderDate{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public Decimal amount{get;set;}

        public OrderDTO (Order source) {
            this.id = source.Id;
            this.accountId = source.AccountId;
            this.orderNumber = source.OrderNumber;
            this.orderDate = source.EffectiveDate;
            this.status = source.Status;
            this.amount = source.TotalAmount;
        }
    }
}