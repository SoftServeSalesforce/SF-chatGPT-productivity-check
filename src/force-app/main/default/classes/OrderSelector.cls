public with sharing class OrderSelector {
    public static List<Order> getOrdersByAccountId(Id accountId) {
        return [SELECT Id, Name, OrderNumber, TotalAmount,EffectiveDate,LastStatusChanged__c, Status
                FROM Order
                WHERE AccountId = :accountId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC];
    }



    public static Map<Id, Boolean> getOrdersWithInvoice(List<Order> orderRecords ) {

        Map<Id, Boolean> hasInvoiceFilesMap = new Map<Id, Boolean>();    

        for (ContentDocumentLink link : queryContentDocument(orderRecords)) {
            hasInvoiceFilesMap.put(link.LinkedEntityId, true);
        }

        return hasInvoiceFilesMap;

    }


    public static Map<Id, Id> getOrdersContentDocumentId(List<Order> orderRecords ) {        

        Map<Id, Id> hasContentDocumentIdMap = new Map<Id, Id>();    

        for (ContentDocumentLink contentdoc : queryContentDocument(orderRecords)) {
            hasContentDocumentIdMap.put(contentdoc.LinkedEntityId, contentdoc.ContentDocumentId);
        }

        return hasContentDocumentIdMap;

    }


    public static List<ContentDocumentLink> queryContentDocument(List<Order> orderRecords ) {

        Set<Id> ordersId= new  Set<Id> ();
        for(Order order: orderRecords){
            ordersId.add(order.Id);
        }

        List<ContentDocumentLink> contentDocumentList=[SELECT Id, LinkedEntityId, ContentDocumentId,Visibility, IsDeleted, ShareType,ContentDocument.Title,ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId IN :ordersId AND ContentDocument.Title LIKE 'Invoice%' WITH SECURITY_ENFORCED ORDER BY SystemModstamp DESC LIMIT 1];

        return contentDocumentList;
    }



    public static String calculateTimeSinceLastStatusChange(DateTime lastStatusChanged) {
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



    public static Map<String, Object> updateOrderStatus(Id orderId, String newStatus) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {          
            Order orderToUpdate = [SELECT Id, Status FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED FOR UPDATE];
            
            
            if (newStatus == 'Activated' || newStatus == 'Shipped') {    
                orderToUpdate.Status = newStatus;          
                update orderToUpdate;          
                
                response.put('status', 'OK');
                response.put('ErrorMessage', null);
            } else {
                response.put('status', 'ERROR');
                response.put('ErrorMessage', 'Invalid Operation for Order ' + orderToUpdate.OrderNumber);
            }
        } catch (Exception e) {
            response.put('status', 'ERROR');
            response.put('ErrorMessage', 'An error occurred while updating the order status.');
        }
        
        return response;
    }



}
