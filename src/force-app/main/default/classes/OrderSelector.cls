public with sharing class OrderSelector {
    
     public static List<Order> getOrdersByAccountId(Id accountId) {
         return [SELECT Id, EffectiveDate, OrderNumber, Status, TotalAmount, LastStatusChanged__c,        
                 (SELECT Id, ContentDocumentId FROM AttachedContentDocuments 
                 WHERE Title LIKE 'Invoice%' ORDER BY CreatedDate DESC) 
                 FROM Order WHERE AccountId = :accountId];
 
     }
  
     public static List<Order> getshipSelectedOrders(List<Id> orderIds) {
         return [SELECT Id, Status
         FROM Order
         WHERE Id IN :orderIds
         AND Status = :Constants.STATUS_ACTIVATED];
     }
 
     public static List<Order> activateSelectedOrders(List<Id> orderIds) {
         return [SELECT Id, Status
         FROM Order
         WHERE Id IN :orderIds
         AND Status = :Constants.STATUS_DRAFT];
     }
 
    
     public static Order getOrderToUpdate(Id orderId) {
         return [SELECT Id, Status FROM Order WHERE Id = :orderId WITH SECURITY_ENFORCED FOR UPDATE];
     }
 
 
 }
