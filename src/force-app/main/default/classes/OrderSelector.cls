public with sharing class OrderSelector {

    public static List<Order> getOrdersbyAccountId(Id accountId){
        return [SELECT Id, OrderNumber, AccountId, EffectiveDate, Status, TotalAmount FROM Order WHERE AccountId = :accountId WITH SECURITY_ENFORCED];
    }
    
}