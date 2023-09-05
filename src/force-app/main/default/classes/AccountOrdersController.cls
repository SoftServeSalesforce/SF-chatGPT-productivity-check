public with sharing class AccountOrdersController {
    public static final String OK_STATUS = 'OK';
    public static final String ERROR_STATUS = 'ERROR';
    public static final String ACCOUNT_ID_EMPTY_ERROR_MESSAGE = 'Account Id cannot be blank';
    public static final String ORDER_INVALID_STATUS_ERROR_MESSAGE = 'Order is in invalid status';
    
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

    @AuraEnabled
    public static OrderUpdateResponse activateOrder(String order) {
        OrderDTO orderDto = (OrderDTO) JSON.deserializeStrict(order, OrderDTO.class);
        try {
            if (orderDto.status != 'Draft') {
                return new OrderUpdateResponse(ERROR_STATUS, ORDER_INVALID_STATUS_ERROR_MESSAGE);
            }
            update new Order(Id = orderDto.orderId, Status = 'Activated');
            return new OrderUpdateResponse(OK_STATUS, null);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static OrderUpdateResponse markOrderAsShipped(String order) {
        OrderDTO orderDto = (OrderDTO) JSON.deserializeStrict(order, OrderDTO.class);
        try {
            if (orderDto.status != 'Activated') {
                return new OrderUpdateResponse(ERROR_STATUS, ORDER_INVALID_STATUS_ERROR_MESSAGE);
            }
            update new Order(Id = orderDto.orderId, Status = 'Shipped');
            return new OrderUpdateResponse(OK_STATUS, null);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
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
        @AuraEnabled public Id orderId;
        @AuraEnabled public String orderNumber;
        @AuraEnabled public String status;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Id lastInvoiceId;
        @AuraEnabled public Datetime lastStatusChanged;

        public OrderDTO(Order order) {
            this.orderId = order.Id;
            this.orderNumber = order.OrderNumber;
            this.status = order.Status;
            this.startDate = order.EffectiveDate;
            this.amount = order.TotalAmount;
            this.lastInvoiceId = order.CombinedAttachments.isEmpty() ? null : order.CombinedAttachments[0].Id;
            this.lastStatusChanged = order.LastStatusChanged__c;
        }
    }

    public class OrderUpdateResponse {
        @AuraEnabled public String status;
        @AuraEnabled public String message;

        public OrderUpdateResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
}