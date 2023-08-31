public with sharing class AccountOrdersController {
    private static final String ACCOUNT_ID_EMPTY_ERROR_MESSAGE = 'Account Id cannot be blank';
    @AuraEnabled
    public static List<OrderDTO> getOrders(Id accountId) {
        try {
            if (String.isBlank(accountId)) {
                throw new IllegalArgumentException(ACCOUNT_ID_EMPTY_ERROR_MESSAGE);
            }
            Map<Id, Order> orders = OrderSelector.getInstance().getOrdersByAccountId(accountId);
            return mapOrdersToDTO(orders.values());
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static List<OrderDTO> mapOrdersToDTO(List<Order> orders) {
        List<OrderDTO> orderDtos = new List<OrderDTO>();
        for (Order order : orders) {
            orderDtos.add(new OrderDTO(order));
        }
        return orderDtos;
    }

    public class OrderDTO {
        @AuraEnabled public String orderNumber;
        @AuraEnabled public String status;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Decimal amount;

        public OrderDTO(Order order) {
            this.orderNumber = order.OrderNumber;
            this.status = order.Status;
            this.startDate = order.EffectiveDate;
            this.amount = order.TotalAmount;
        }
    }
}