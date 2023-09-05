public with sharing class AccountOrdersController {

    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    
    private static final String ERROR_INVALID_ACCOUNT_ID = 'Account Id cannot be null';
    private static final String ERROR_INVALID_AMOUNT_OF_RECORDS = 'Amount of records should be in range from 1 to 100';
    private static final String ERROR_INVALID_PAGE = 'Page cannot be negative or blank';
    private static final String ERROR_ORDER_INVALID_OPERATION = 'Invalid Operation for Order #';
    private static final String ERROR_EMPTY_INPUT = 'Please verify your input';
    private static final String ERROR_CANT_SAVE_SETTINGS = 'Exception fired when tried to save settings: ';
    private static final String STATUS_OK = 'OK';
    private static final String STATUS_ERROR = 'ERROR';

    public class PageSettingsDTO {
        @AuraEnabled
        public Integer amountOfRecordsOnPage ;

        public PageSettingsDTO(PaginationSettings__c settings) {
            if(settings.RecordsAmountOnPage__c == null) {
                this.amountOfRecordsOnPage = 10;
                return;
            }
            this.amountOfRecordsOnPage = (Integer) settings.RecordsAmountOnPage__c;
        }
    }
    
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
        @AuraEnabled
        public Id invoiceId;
        @AuraEnabled
        public String invoiceName;
        @AuraEnabled
        public Id contentDocumentId;
        @AuraEnabled
        public Datetime lastStatusChanged;
        
        
        public OrderDTO(Order ord) {
            this.orderId = ord.Id;
            this.orderNumber = ord.OrderNumber;
            this.startDate = ord.EffectiveDate; // Assuming this is the start date
            this.status = ord.Status;
            this.amount = ord.TotalAmount; // This might be a custom field. Adjust accordingly
            this.lastStatusChanged = ord.LastStatusChanged__c;
            
            if(!ord.AttachedContentDocuments.isEmpty()) {
                this.invoiceId = ord.AttachedContentDocuments[0].Id;
                this.invoiceName = ord.AttachedContentDocuments[0].Title;
                this.contentDocumentId = ord.AttachedContentDocuments[0].ContentDocumentId;
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId, Integer recordsAmount, Integer currentPage) {
        if (String.isBlank(accountId)) {
            throw new AuraHandledException(ERROR_INVALID_ACCOUNT_ID);
        }

        if (recordsAmount == null || recordsAmount < 1 || recordsAmount > 100) {
            throw new AuraHandledException(ERROR_INVALID_AMOUNT_OF_RECORDS);
        }

        if (currentPage == null || currentPage < 0) {
            throw new AuraHandledException(ERROR_INVALID_PAGE);
        }

        try {

            List<Order> orderList = OrderSelector.getOrdersByAccountId(accountId, recordsAmount, recordsAmount * currentPage);
            List<OrderDTO> orderDTOList = new List<OrderDTO>();
            for(Order o : orderList) {
                orderDTOList.add(new OrderDTO(o));
            }

            return orderDTOList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> activateOrders(List<Id> orderIds) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            validateAndUpdateOrdersByStatus(orderIds, ORDER_STATUS_DRAFT, ORDER_STATUS_ACTIVATED);
            response.put('status', STATUS_OK);
        } catch(Exception e) {
            response.put('status', STATUS_ERROR);
            response.put('errorMessage', e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static Map<String, Object> markOrdersAsShipped(List<Id> orderIds) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            validateAndUpdateOrdersByStatus(orderIds, ORDER_STATUS_ACTIVATED, ORDER_STATUS_SHIPPED);
            response.put('status', STATUS_OK);
        } catch(Exception e) {
            response.put('status', STATUS_ERROR);
            response.put('errorMessage', e.getMessage());
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static PageSettingsDTO getAmountOfRecords() {
        Id userId = UserInfo.getUserId();
        PaginationSettings__c pageSettings = PaginationSettings__c.getInstance(userId);
        return new PageSettingsDTO(pageSettings);
    }

    @AuraEnabled
    public static void savePageSettings(Integer recordsAmountPerPage) {
        if (recordsAmountPerPage == null || recordsAmountPerPage < 1 || recordsAmountPerPage > 100) {
            throw new AuraHandledException(ERROR_INVALID_AMOUNT_OF_RECORDS);
        }
        try {
            Id userId = UserInfo.getUserId();
            PaginationSettings__c pageSettings = PaginationSettings__c.getInstance(userId);
            pageSettings.RecordsAmountOnPage__c = recordsAmountPerPage;
            upsert pageSettings;
        } catch (Exception e) {
            throw new AuraHandledException(ERROR_CANT_SAVE_SETTINGS + e.getMessage());
        }
    } 

    private static void validateAndUpdateOrdersByStatus(List<Id> orderIds, String statusFrom, String newStatus) {
        if (orderIds.isEmpty()) {
            throw new OrderInvalidOperationException(ERROR_EMPTY_INPUT);
        }
        List<Order> orders = OrderSelector.getOrdersForUpdate(orderIds);
        for(Order ord: orders) {
            if(ord.Status != statusFrom) {
                throw new OrderInvalidOperationException(ERROR_ORDER_INVALID_OPERATION + ord.OrderNumber);
            }
            ord.Status = newStatus;
        }
        update orders;
    }
}
