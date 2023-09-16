public with sharing class OrderSelector {
    public class OrderStatusException extends Exception {}

    public static List<Order> getOrdersbyAccountId(Id accountId){
        return [SELECT Id, OrderNumber, AccountId, EffectiveDate, Status, TotalAmount, (SELECT Id, Title, ContentDocumentId 
        FROM AttachedContentDocuments 
        WHERE Title LIKE 'Invoice%') FROM Order WHERE AccountId = :accountId WITH SECURITY_ENFORCED];
    }

    public static String updateOrder (Id orderId, String status) {
        if (String.isBlank(status)) {
            OrderStatusException e = new OrderStatusException('ERROR');
            e.setMessage('Invalid Operation for Order ' + orderId);
            throw e;
        }
        try {
            Order recordToUpdate = [SELECT Id, Status FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED FOR UPDATE];
            recordToUpdate.Status = status;
            update recordToUpdate;
            return 'status: OK';
        } catch (Exception e) {
            OrderStatusException ex = new OrderStatusException('ERROR', e);
            throw ex;
        }
    }
    
}