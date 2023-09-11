public with sharing class AccountOrdersController {
    public class OrderDTO {
        
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String OrderNumber { get; set; }
        @AuraEnabled public Date EffectiveDate { get; set; }
        @AuraEnabled public Decimal TotalAmount { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public Boolean hasInvoiceFiles { get; set; }
        @AuraEnabled public Id FileId { get; set; }
        @AuraEnabled public DateTime LastStatusChanged { get; set; }
        @AuraEnabled public String TimeSinceLastStatusChange { get; set; }



        public OrderDTO(Order order,String timeSinceLastStatusChange) {
            this.Id = order.Id;
            this.Status = order.Status;
            this.OrderNumber = order.OrderNumber;
            this.TotalAmount = order.TotalAmount;
            this.EffectiveDate = order.EffectiveDate;
            this.LastStatusChanged = order.LastStatusChanged__c;
            this.TimeSinceLastStatusChange = timeSinceLastStatusChange;
            if(!order.AttachedContentDocuments.isEmpty()) {
                this.hasInvoiceFiles=true;
                this.FileId = order.AttachedContentDocuments[0].ContentDocumentId; 
            }                   
        }
        

    }

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {

        try {

        if(String.isBlank(accountId)) {
            throw new AuraHandledException(Constants.INVALID_ACCOUNT);
        }

        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        List<Order> orders = OrderSelector.getOrdersByAccountId(accountId);

        
        for (Order order : orders) {
            
            String timeSinceLastStatusChange='';

            if(order.LastStatusChanged__c!=null){
                 timeSinceLastStatusChange = calculateTimeSinceLastStatusChange(order.LastStatusChanged__c) + 'in '+ order.Status;
            }


            orderDTOs.add(new OrderDTO(order,timeSinceLastStatusChange));
            
        }
        
        return orderDTOs;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }


    @AuraEnabled
    public static Map<String, Object> activateOrder(Id orderId) {
        if(String.isBlank(orderId)) {
            throw new AuraHandledException(Constants.INVALID_ORDER_ID);
        }
        return updateOrderStatus(orderId, Constants.STATUS_ACTIVATED);
    }

    @AuraEnabled
    public static Map<String, Object> markOrderAsShipped(Id orderId) {
        if(String.isBlank(orderId)) {
            throw new AuraHandledException(Constants.INVALID_ORDER_ID);
        }
        return updateOrderStatus(orderId, Constants.STATUS_SHIPPED);
    }


        
    @AuraEnabled
    public static Map<String, Object> activateSelectedOrders(List<Id> orderIds) {
       
        Map<String, Object> response = new Map<String, Object>();

        if (orderIds.isEmpty()) {
            throw new IllegalArgumentException(Constants.ORDERID_EMPTY);
        }

        try { 

            List<Order> ordersToUpdate= OrderSelector.activateSelectedOrders(orderIds);

            for (Order order : ordersToUpdate) {
                order.Status =Constants.STATUS_ACTIVATED;
            }

            if (!ordersToUpdate.isEmpty()) {
                try{
                    update ordersToUpdate;
                } catch(DmlException e) {
                    throw new AuraHandledException(e.getMessage());
                }  
                response.put('status', Constants.ORDER_UPDATE_STATUS_OK);
            }
        } catch (DmlException e) {
            
            
            response.put('ErrorMessage', e.getDmlMessage(0));
        }

        return response;
    }

    @AuraEnabled
    public static Map<String, Object> shipSelectedOrders(List<Id> orderIds) {
       
        Map<String, Object> response = new Map<String, Object>();

        if (orderIds.isEmpty()) {
            throw new IllegalArgumentException(Constants.ORDERID_EMPTY);
        }

        try { 
            
            List<Order> ordersToUpdateShipped = OrderSelector.getshipSelectedOrders(orderIds);


            for (Order order : ordersToUpdateShipped) {
                
                order.Status = Constants.STATUS_SHIPPED;
            }

            if (!ordersToUpdateShipped.isEmpty()) {
                try{
                    update ordersToUpdateShipped;
                } catch(DmlException e) {
                    throw new AuraHandledException(e.getMessage());
                }
                response.put('status', Constants.ORDER_UPDATE_STATUS_OK);
                response.put('ErrorMessage', null);
            }
        } catch (DmlException e) {
                  
            response.put('ErrorMessage', e.getDmlMessage(0));
        }

        return response;
    }

    @AuraEnabled
    public static void setPageSizeUSer(Integer pageSize) {

        if (null == pageSize) {
            throw new IllegalArgumentException(Constants.PAGESIZE_NULL);
        }

        PageSizeCS__c cs = PageSizeCS__c.getInstance(userinfo.getuserid());
        
        if (cs == null) {
            cs = new PageSizeCS__c();
            cs.SetupOwnerId = UserInfo.getUserId();
        }
        
        cs.page_size__c = pageSize;
        
        try{
            upsert(cs);
           
        } catch(DmlException e) {
            throw new AuraHandledException(e.getMessage());
        } 

    }


    @AuraEnabled
    public static Integer getPageSizeUser() {
       
        PageSizeCS__c ps = PageSizeCS__c.getInstance(userinfo.getuserid());
        
        if(ps == null) {
            throw new AuraHandledException('No default page size in custom settings');        
        }
        
        return (Integer) ps.page_size__c;
    }


    @TestVisible private static Map<String, Object> updateOrderStatus(Id orderId, String newStatus) {
        Map<String, Object> response = new Map<String, Object>();
        if(String.isBlank(orderId)) {
            throw new AuraHandledException(Constants.NO_ORDER_TO_PROCESS);
        }

        
        try {          
            Order orderToUpdate = OrderSelector.getOrderToUpdate(orderId);
            
            
            if (newStatus == Constants.STATUS_ACTIVATED || newStatus ==  Constants.STATUS_SHIPPED) {    
                orderToUpdate.Status = newStatus;

                try{          
                    update orderToUpdate; 
                } catch(DmlException e) {
                    throw new AuraHandledException(e.getMessage());
                }          
                
                response.put('status', Constants.ORDER_UPDATE_STATUS_OK);
                response.put('ErrorMessage', null);
            } else {
                response.put('status', Constants.ORDER_UPDATE_STATUS_ERROR);
                response.put('ErrorMessage', 'Invalid Operation for Order ' + orderToUpdate.OrderNumber);
            }
        } catch (DmlException e) {
            response.put('status', Constants.ORDER_UPDATE_STATUS_ERROR);
            
            response.put('ErrorMessage', e.getDmlMessage(0));
        }
        
        return response;
    }



    @TestVisible private static String calculateTimeSinceLastStatusChange(DateTime lastStatusChanged) {


        if (null == lastStatusChanged) {
            throw new IllegalArgumentException(Constants.NULL_LAST_STATUS_CHANGED);
        }


        DateTime now = DateTime.now();
        Integer years = now.year() - lastStatusChanged.year();
        Integer months = now.month() - lastStatusChanged.month();
        Integer days = now.day() - lastStatusChanged.day();
        Integer hours = now.hour() - lastStatusChanged.hour();
        Integer minutes = now.minute() - lastStatusChanged.minute();
    
        String timeSinceLastStatusChange = '';
        if (years > 0) {
            timeSinceLastStatusChange += years + ' year' + (years > 1 ? 's' : '') + ' ';
        } else if (months > 0) {
            timeSinceLastStatusChange += months + ' month' + (months > 1 ? 's' : '') + ' ';
        } else if (days > 0) {
            timeSinceLastStatusChange += days + ' day' + (days > 1 ? 's' : '') + ' ';
        } else if (hours > 0) {
            timeSinceLastStatusChange += hours + ' hour' + (hours > 1 ? 's' : '') + ' ';
        } else if (minutes > 0) {
            timeSinceLastStatusChange += minutes + ' minute' + (minutes > 1 ? 's' : '') + ' ';
        }
    
        return timeSinceLastStatusChange;
    }

    


}
