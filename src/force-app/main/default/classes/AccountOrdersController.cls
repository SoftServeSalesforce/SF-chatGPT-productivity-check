public with sharing class AccountOrdersController {
    private static final String ERROR_INVALID_ACCOUNT_ID = 'Invalid Accounts IDs provided.';
    private static final String ERROR_INVALID_ORDER_ID = 'Invalid Order ID provided.';
    private static final String ERROR_INVALID_ORDERS_IDS = 'Invalid Orders IDs provided.';
    private static final String ERROR_INVALID_OPERATION_FOR_ORDER = 'Invalid Operation for Order #';
    private static final String ERROR_INVALID_PAGE_SIZE = 'Invalid page size. Page size must be a positive integer greater than zero.';
    private static final String ERROR_INVALID_PAGE_NUMBER = 'Invalid page number. Page number must be a positive integer greater than zero.';
    private static final String ERROR_INVALID_PAGINATION_SETTINGS = 'No default page size in custom settings found.';
    private static final String STATUS_OK = 'OK';
    private static final String STATUS_ERROR = 'ERROR';
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final Integer DEFAULT_PAGE_SIZE = 10;

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId, Integer pageSize, Integer pageNumber) {
        if(accountId == null || String.isBlank(accountId)) {
            throw new IllegalArgumentException(ERROR_INVALID_ACCOUNT_ID);
        }
        if (pageSize == null || pageSize <= 0) {
            pageSize = getPageSize();
        }
        if (pageNumber == null || pageNumber <= 0) {
            pageNumber = 1;
        }

        Integer offsetSize = (pageNumber - 1) * pageSize;
        
        List<Order> orders = OrderSelector.getOrdersWithInvoiceInfo(accountId, pageSize, offsetSize);
        List<OrderDTO> orderDTOList = new List<OrderDTO>();
        
        for(Order o : orders) {
            orderDTOList.add(new OrderDTO(o));
        }
   
        return orderDTOList;
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getTotalOrderCount(Id accountId) {
        if(accountId == null || String.isBlank(accountId)) {
            throw new IllegalArgumentException(ERROR_INVALID_ACCOUNT_ID);
        }

        Integer totalRecordsCount = OrderSelector.getOrderCountByAccountId(accountId);

        return totalRecordsCount;
    }

    @AuraEnabled
    public static Integer getPageSize() {
        OrderListPaginationPageSize__c paginationSettings = OrderListPaginationPageSize__c.getInstance(UserInfo.getUserId());

        if (paginationSettings == null || paginationSettings?.Page_Size__c <= 0) {
            setPageSize(DEFAULT_PAGE_SIZE);
        }
        
        return (Integer) paginationSettings.Page_Size__c;
    }

    @AuraEnabled
    public static Map<String, Object> setPageSize(Integer pageSize) {
        if (pageSize <= 0) {
            throw new AuraHandledException(ERROR_INVALID_PAGE_SIZE);
        }

        Map<String, Object> response = new Map<String, Object>();

        OrderListPaginationPageSize__c paginationSettings = OrderListPaginationPageSize__c.getInstance(UserInfo.getUserId()); 
          
        if (paginationSettings == null) {
            paginationSettings = new OrderListPaginationPageSize__c();
            paginationSettings.SetupOwnerId = UserInfo.getUserId();
        }
        
        paginationSettings.Page_Size__c = pageSize; 
    
        try {
            upsert paginationSettings;
            response.put('status', STATUS_OK);
            return response;
        } catch (DmlException e) {
            response.put('status', STATUS_ERROR);
            response.put('ErrorMessage', ERROR_INVALID_PAGE_SIZE + pageSize);
            return response;
        }
    } 

    @AuraEnabled
    public static Map<String, Object> activateOrder(Id orderId) {
        if(orderId == null || String.isBlank(orderId)) {
            throw new IllegalArgumentException(ERROR_INVALID_ORDER_ID);
        }

        Map<String, Object> response = new Map<String, Object>();

        Order ord = OrderSelector.getOrderStatusById(orderId);
        if (ord.Status != ORDER_STATUS_DRAFT) {
            response.put('status', STATUS_ERROR);
            response.put('ErrorMessage', ERROR_INVALID_OPERATION_FOR_ORDER + orderId);
            return response;
        }

        ord.Status = ORDER_STATUS_ACTIVATED;
        update ord;

        response.put('status', STATUS_OK);
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> markOrderAsShipped(Id orderId) {
        if(orderId == null || String.isBlank(orderId)) {
            throw new IllegalArgumentException(ERROR_INVALID_ORDER_ID);
        }

        Map<String, Object> response = new Map<String, Object>();

        Order ord = OrderSelector.getOrderStatusById(orderId);
        if(ord.Status != ORDER_STATUS_ACTIVATED) {
            response.put('status', STATUS_ERROR);
            response.put('ErrorMessage', ERROR_INVALID_OPERATION_FOR_ORDER + orderId);
            return response;
        }

        ord.Status = ORDER_STATUS_SHIPPED;
        update ord;

        response.put('status', STATUS_OK);
        return response;
    }

    @AuraEnabled
    public static List<Map<String, Object>> bulkActivateOrders(List<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            throw new IllegalArgumentException(ERROR_INVALID_ORDERS_IDS);
        }

        List<Map<String, Object>> responses = new List<Map<String, Object>>();

        List<Order> ordersToUpdate = OrderSelector.getOrdersByIds(orderIds);

        for (Order ord : ordersToUpdate) {
            if (ord.Status != ORDER_STATUS_DRAFT) {
                Map<String, Object> response = new Map<String, Object>();
                response.put('OrderId', ord.Id);
                response.put('status', STATUS_ERROR);
                response.put('ErrorMessage', ERROR_INVALID_OPERATION_FOR_ORDER + ord.Id);
                responses.add(response);
            } 
            else {
                ord.Status = ORDER_STATUS_ACTIVATED;
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }

        for (Order ord : ordersToUpdate) {
            if (ord.Status == ORDER_STATUS_ACTIVATED) {
                Map<String, Object> response = new Map<String, Object>();
                response.put('OrderId', ord.Id);
                response.put('status', STATUS_OK);
                responses.add(response);
            }
        }

        return responses;
    }

    @AuraEnabled
    public static List<Map<String, Object>> bulkMarkOrdersAsShipped(List<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            throw new IllegalArgumentException(ERROR_INVALID_ORDERS_IDS);
        }
    
        List<Map<String, Object>> responses = new List<Map<String, Object>>();

        List<Order> ordersToUpdate = OrderSelector.getOrdersByIds(orderIds);

        for (Order ord : ordersToUpdate) {
            if (ord.Status != ORDER_STATUS_ACTIVATED) {
                Map<String, Object> response = new Map<String, Object>();
                response.put('OrderId', ord.Id);
                response.put('status', STATUS_ERROR);
                response.put('ErrorMessage', ERROR_INVALID_OPERATION_FOR_ORDER + ord.Id);
                responses.add(response);
            } 
            else {
                ord.Status = ORDER_STATUS_SHIPPED;
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }

        for (Order ord : ordersToUpdate) {
            if (ord.Status == ORDER_STATUS_SHIPPED) {
                Map<String, Object> response = new Map<String, Object>();
                response.put('OrderId', ord.Id);
                response.put('status', STATUS_OK);
                responses.add(response);
            }
        }
    
        return responses;
    }

    public class OrderDTO {
        @AuraEnabled
        public Id orderId;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public Id invoiceId;
        @AuraEnabled
        public String invoiceName;
        @AuraEnabled
        public Id contentDocumentId;
        @AuraEnabled
        public Datetime lastStatusChanged;

        public OrderDTO(Order o) {
            this.orderId = o.Id;
            this.orderNumber = o.OrderNumber;
            this.status = o.Status;
            this.startDate = o.EffectiveDate;
            this.amount = o.TotalAmount;

            if (o.LastStatusChanged__c != null) {
                this.lastStatusChanged = o.LastStatusChanged__c;
            }
            else {
                this.lastStatusChanged = o.CreatedDate;
            }

            if(o.AttachedContentDocuments != null && !o.AttachedContentDocuments.isEmpty()) {
                this.invoiceId = o.AttachedContentDocuments[0].Id;
                this.invoiceName = o.AttachedContentDocuments[0].Title;
                this.contentDocumentId = o.AttachedContentDocuments[0].ContentDocumentId;
            }
        }
    }
}