public with sharing class AccountOrdersController {
    
    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        if(String.isBlank(accountId)) {
            throw new AuraHandledException('Invalid account Id');
        }
        try {
            List<Order> accountRelatedOrders = OrderSelector.getOrdersWithAttachmentsByAccountId(accountId);
            return populateOrderDTOs(accountRelatedOrders);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    private static List<OrderDTO> populateOrderDTOs(List<Order> orders) {
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        if(!orders.isEmpty()) {
            for(Order order : orders) {
                orderDTOs.add(new OrderDTO(order));
            }
        }
        return orderDTOs;
    }

    public class OrderDTO {
        @AuraEnabled
        public Id orderId;

        @AuraEnabled
        public String orderStatus;

        @AuraEnabled
        public String orderNumber;

        @AuraEnabled
        public Date startDate;

        @AuraEnabled
        public Decimal amount;       
        
        public OrderDTO(Order order) {
            this.orderId = order.Id;
            this.orderStatus = order.Status;
            this.orderNumber = order.OrderNumber;
            this.amount = order.TotalAmount;
            this.startDate = order.EffectiveDate;
        }
    }
}