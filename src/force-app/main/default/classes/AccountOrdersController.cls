public with sharing class AccountOrdersController {
    
    // Wrapper class for Order SObject
    public class OrderDTO {
        @AuraEnabled
        public Id orderId;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Decimal amount;
        
        public OrderDTO(Order o) {
            this.orderId = o.Id;
            this.orderNumber = o.OrderNumber;
            this.startDate = o.EffectiveDate; // Assuming this is the start date
            this.status = o.Status;
            this.amount = o.TotalAmount; // This might be a custom field. Adjust accordingly
        }
    }
    
    @AuraEnabled(cacheable=true)
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
