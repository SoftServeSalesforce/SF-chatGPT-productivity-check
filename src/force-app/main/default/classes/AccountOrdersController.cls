public with sharing class AccountOrdersController {

    @AuraEnabled(Cacheable=true)
    public static OrderDTO[] getOrders(Id accountId) {
        if (null == accountId) {
            return new OrderDTO[]{};
        }
        OrderDTO[] orderDTOS = new OrderDTO[]{};
        for (Order order : new OrderSelector().getOrdersByAccountId(accountId)) {
            orderDTOS.add(new OrderDTO(order));
        }
        return orderDTOS;
    }

    public class OrderDTO {
        @AuraEnabled
        public Id id { get; private set; }
        @AuraEnabled
        public String orderNumber { get; private set; }
        @AuraEnabled
        public Date startDate { get; private set; }
        @AuraEnabled
        public String status { get; private set; }
        @AuraEnabled
        public Decimal amount { get; private set; }

        public OrderDTO(Order order) {
            if (null == order){
                return;
            }
            this.id = order.Id;
            this.orderNumber = order.OrderNumber;
            this.startDate = order.EffectiveDate;
            this.status = order.Status;
            this.amount = order.TotalAmount;
        }
    }

}