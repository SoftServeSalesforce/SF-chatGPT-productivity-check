public with sharing class OrderSelector {
    public static List<Order> getOrdersByAccountId(Id accountId) {
        return [SELECT Id, Name FROM Order WHERE AccountId = :accountId];
    }
}