public with sharing class AccountOrdersController {
    
    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        if(String.isBlank(accountId)) {
            throw new AuraHandledException(Constants.INVALID_ACCOUNT_ID_MESSAGE);
        }
        try {
            List<Order> accountRelatedOrders = OrderSelector.getOrdersWithAttachmentsByAccountId(accountId);
            return populateOrderDTOs(accountRelatedOrders);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    @AuraEnabled
    public static OrderDMLSummaryResponse activateOrder(Id orderId) {
        if(String.isBlank(orderId)) {
            throw new AuraHandledException(Constants.INVALID_ORDER_ID_MESSAGE);
        }
        try {
            Order order = OrderSelector.getOrderById(orderId);
            return handleOrderStatus(order, Constants.ORDER_STATUS_DRAFT, Constants.ORDER_STATUS_ACTIVATED);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    @AuraEnabled
    public static OrderDMLSummaryResponse markOrderAsShipped(Id orderId) {
        if(String.isBlank(orderId)) {
            throw new AuraHandledException(Constants.INVALID_ORDER_ID_MESSAGE);
        }
        try {
            Order order = OrderSelector.getOrderById(orderId);
            return handleOrderStatus(order, Constants.ORDER_STATUS_ACTIVATED, Constants.ORDER_STATUS_SHIPPED);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    private static OrderDMLSummaryResponse handleOrderStatus(Order order, String statusToCompare, String statusToSet) {
        if(order?.Status != statusToCompare) {
            return new OrderDMLSummaryResponse(Constants.ORDER_DML_RESPONSE_STATUS_ERROR, Constants.ORDER_DML_RESPONSE_ERROR_MESSAGE + order?.Id);
        }
        order.Status = statusToSet;
        try {
            update order;
            return new OrderDMLSummaryResponse(Constants.ORDER_DML_RESPONSE_STATUS_SUCCESS, 
                String.format(Constants.ORDER_DML_RESPONSE_SUCCESS_MESSAGE, new List<Object>{
                    order.Status, order.Id}));
        } catch(DmlException e) {
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

    public class OrderDMLSummaryResponse {
        @AuraEnabled
        public String responseStatus;

        @AuraEnabled
        public String responseMessage;

        public OrderDMLSummaryResponse(String responseStatus, String responseMessage) {
            this.responseStatus = responseStatus;
            this.responseMessage = responseMessage;
        }
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