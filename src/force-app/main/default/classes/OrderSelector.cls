public with sharing class OrderSelector {

    // Factory method to create an instance of OrderSelector
    public static OrderSelector create() {
        return new OrderSelector();
    }

    // Method to retrieve orders for a specified account
    public List<Order> getOrdersForAccount(Id accountId) {
        return [SELECT Id, Name, OrderNumber, Status
                FROM Order
                WHERE AccountId = :accountId
                ORDER BY CreatedDate DESC];
    }
}
