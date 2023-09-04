public with sharing class AccountOrdersController {   
    
    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId, Integer pageSize, Integer currentPage) {        
        if(String.isBlank(accountId)) {
            throw new AuraHandledException(Constants.INVALID_ACCOUNT_ID_MESSAGE);
        }
        if(pageSize == null || pageSize <=0) {
            pageSize = getPageSize();
        }
        if(currentPage == null || currentPage <=0) {
            currentPage = 1;
        }
        Integer offsetSize = (currentPage - 1) * pageSize;
        try {            
            List<Order> accountRelatedOrders = OrderSelector.getOrdersWithAttachmentsByAccountId(accountId, pageSize, offsetSize);
            return populateOrderDTOs(accountRelatedOrders);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalOrdersCount(Id accountId) {        
        if(String.isBlank(accountId)) {
            throw new AuraHandledException(Constants.INVALID_ACCOUNT_ID_MESSAGE);
        }
        try {            
            return OrderSelector.getOrderCountByAccountId(accountId);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Integer getPageSize() {
        PaginationPageSize__c settings = PaginationPageSize__c.getInstance(UserInfo.getUserId());
        if(settings == null || settings?.Page_Size__c <= 0) {
            throw new AuraHandledException('Please setup default page size in custom settings');
        }
        return (Integer) settings.Page_Size__c;
    }

    @AuraEnabled
    public static OrderDMLSummaryResponse setPageSize(Integer pageSize) {
        if(pageSize <= 0) {
            throw new AuraHandledException('Invalid page size');
        }

        PaginationPageSize__c settings = PaginationPageSize__c.getInstance(UserInfo.getUserId());    
        if (settings == null) {
            settings = new PaginationPageSize__c();
            settings.SetupOwnerId = UserInfo.getUserId();
        }
        
        settings.Page_Size__c = pageSize; 

        try{
            Database.UpsertResult upsertResult = Database.upsert(settings);
            return new OrderDMLSummaryResponse(Constants.ORDER_DML_RESPONSE_STATUS_SUCCESS, 'Default page size has been updated');
        } catch(DmlException e) {
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

    @AuraEnabled
    public static OrderDMLSummaryResponse activateOrders(List<Id> orderIds) {
        List<Order> orders = OrderSelector.getOrdersByIds(orderIds);
        return handleBulkOrderStatus(orders, Constants.ORDER_STATUS_DRAFT, Constants.ORDER_STATUS_ACTIVATED);
    }

    @AuraEnabled
    public static OrderDMLSummaryResponse markOrdersAsShipped(List<Id> orderIds) {
        List<Order> orders = OrderSelector.getOrdersByIds(orderIds);
        return handleBulkOrderStatus(orders, Constants.ORDER_STATUS_ACTIVATED, Constants.ORDER_STATUS_SHIPPED);
    }

    private static OrderDMLSummaryResponse handleBulkOrderStatus(List<Order> orders, String statusToCompare, String statusToSet) {
        List<Id> invalidOrders = new List<Id>();

        for(Order order : orders) {
            if(order.Status != statusToCompare) {
                invalidOrders.add(order.Id);
            } else {
                order.Status = statusToSet;
            }                
        }

        if(!invalidOrders.isEmpty()) {
            return new OrderDMLSummaryResponse(Constants.ORDER_DML_RESPONSE_STATUS_ERROR,
                 String.format(Constants.ORDER_DML_RESPONSE_BULK_ERROR_MESSAGE, invalidOrders));
        } else {
            try {
                update orders;
                return new OrderDMLSummaryResponse(Constants.ORDER_DML_RESPONSE_STATUS_SUCCESS,
                     String.format(Constants.ORDER_DML_RESPONSE_BULK_SUCCESS_MESSAGE, new List<String>{statusToSet}));
            } catch(DmlException e) {
                throw new AuraHandledException(e.getMessage());
            }    
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

    public class GetOrdersRequest {
        @AuraEnabled
        public Id accountId;
    
        @AuraEnabled
        public Integer pageNumber;
    
        @AuraEnabled
        public Integer pageSize; 
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
        
        @AuraEnabled
        public Datetime lastStatusChanged; 
        
        @AuraEnabled
        public Id attachmentId;

        @AuraEnabled
        public Id contentDocumentId;
        
        public OrderDTO(Order order) {
            this.orderId = order.Id;
            this.orderStatus = order.Status;
            this.orderNumber = order.OrderNumber;
            this.amount = order.TotalAmount;
            this.startDate = order.EffectiveDate;
            this.lastStatusChanged = order.LastStatusChanged__c;
            if(!order.AttachedContentDocuments.isEmpty()) {
                this.attachmentId = order.AttachedContentDocuments[0].Id;
                this.contentDocumentId = order.AttachedContentDocuments[0].ContentDocumentId; 
            }                   
        }
    }
}