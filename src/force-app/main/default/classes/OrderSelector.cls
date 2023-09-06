public with sharing class OrderSelector {

    // Factory method to create an instance of OrderSelector
    public static OrderSelector create() {
        return new OrderSelector();
    }

    // Method to retrieve orders for a specified account
    public List<Order> getOrdersForAccount(Id accountId) {
        return [SELECT Id, OrderNumber, EffectiveDate, Status, TotalAmount
                FROM Order
                WHERE AccountId = :accountId
                ORDER BY CreatedDate DESC];
    }

    public Order getOrderByNumber(String orderNumber) {
        return [SELECT OrderNumber, EffectiveDate, Status, TotalAmount
        FROM Order
        WHERE OrderNumber = :orderNumber
        LIMIT 1];
    }

     // Method to retrieve the latest 'Invoice' file for an order
     public ContentDocument getLatestInvoiceFile(String orderNumber) {
        Order order = getOrderByNumber(orderNumber);
        if(order == null) {
            return null;
        }
        ContentDocumentLink cdl = [SELECT ContentDocumentId
                                   FROM ContentDocumentLink
                                   WHERE LinkedEntityId = :order.Id
                                   LIMIT 1];

        ContentDocument invoiceFile = [SELECT Id, Title
                                   FROM ContentDocument
                                   WHERE Title LIKE 'Invoice%'
                                         AND Id = : cdl.ContentDocumentId
                                   ORDER BY CreatedDate DESC
                                   LIMIT 1];
        return null;
    }

    public String getUrlForInvoice(Id cdI) {
        return [SELECT DistributionPublicUrl FROM ContentDistribution where ContentDocumentId=:cdI LIMIT 1].DistributionPublicUrl;
    }
}
