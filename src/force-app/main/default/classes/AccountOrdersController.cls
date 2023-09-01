public with sharing class AccountOrdersController {
    public class OrderDTO {
        
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String OrderNumber { get; set; }
        @AuraEnabled public Date EffectiveDate { get; set; }
        @AuraEnabled public Decimal TotalAmount { get; set; }
        @AuraEnabled public String Status { get; set; }
        @AuraEnabled public Boolean hasInvoiceFiles { get; set; }
        @AuraEnabled public Id FileId { get; set; }
        @AuraEnabled public DateTime LastStatusChanged { get; set; }
        @AuraEnabled public String TimeSinceLastStatusChange { get; set; }

        public OrderDTO(Id orderId, String orderName,String orderNumber, String orderStatus,Date orderEffectiveDate,Decimal orderTotalAmount, Boolean invoiceFiles,Id contentDocumentId,DateTime lastStatusChanged,String timeSinceLastStatusChange) {
            this.Id = orderId;
            this.Name = orderName;
            this.Status = orderStatus;
            this.OrderNumber=orderNumber;
            this.EffectiveDate=orderEffectiveDate;
            this.TotalAmount=orderTotalAmount;
            this.hasInvoiceFiles = invoiceFiles;
            this.FileId = contentDocumentId;
            this.LastStatusChanged = lastStatusChanged;
            this.TimeSinceLastStatusChange = timeSinceLastStatusChange;
        }

        public OrderDTO(Id orderId, String orderName,String orderNumber, String orderStatus,Date orderEffectiveDate,Decimal orderTotalAmount, Boolean invoiceFiles,DateTime lastStatusChanged,String timeSinceLastStatusChange) {
            this.Id = orderId;
            this.Name = orderName;
            this.Status = orderStatus;
            this.OrderNumber=orderNumber;
            this.EffectiveDate=orderEffectiveDate;
            this.TotalAmount=orderTotalAmount;
            this.hasInvoiceFiles = invoiceFiles;
            this.LastStatusChanged = lastStatusChanged;
            this.TimeSinceLastStatusChange = timeSinceLastStatusChange;
        }


    }

    @AuraEnabled(cacheable=true)
    public static List<OrderDTO> getOrders(Id accountId) {
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        List<Order> orders = OrderSelector.getOrdersByAccountId(accountId);

        Map<Id, Boolean> hasInvoiceFilesMap = OrderSelector.getOrdersWithInvoice(orders);
        Map<Id, Id> ordersContentDocumenMap = OrderSelector.getOrdersContentDocumentId(orders);


        for (Order order : orders) {
            Boolean hasInvoiceFiles = hasInvoiceFilesMap.containsKey(order.Id) && hasInvoiceFilesMap.get(order.Id);
            String timeSinceLastStatusChange='';

            if(order.LastStatusChanged__c!=null){
                 timeSinceLastStatusChange = OrderSelector.calculateTimeSinceLastStatusChange(order.LastStatusChanged__c) + 'in '+ order.Status;
            }
            
            
            if(ordersContentDocumenMap.containsKey(order.Id)){
                orderDTOs.add(new OrderDTO(order.id,order.Name,order.orderNumber,order.Status,order.EffectiveDate,order.TotalAmount,hasInvoiceFiles,ordersContentDocumenMap.get(order.Id),order.LastStatusChanged__c,timeSinceLastStatusChange));
            }else{
                orderDTOs.add(new OrderDTO(order.id,order.Name,order.orderNumber,order.Status,order.EffectiveDate,order.TotalAmount,hasInvoiceFiles,order.LastStatusChanged__c,timeSinceLastStatusChange));
            }
            
        }
        
        return orderDTOs;
    }


    @AuraEnabled
    public static Map<String, Object> activateOrder(Id orderId) {
        return OrderSelector.updateOrderStatus(orderId, 'Activated');
    }

    @AuraEnabled
    public static Map<String, Object> markOrderAsShipped(Id orderId) {
        return OrderSelector.updateOrderStatus(orderId, 'Shipped');
    }       


}