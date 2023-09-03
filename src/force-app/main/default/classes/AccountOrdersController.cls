public with sharing class AccountOrdersController {

    @AuraEnabled(cacheable=true)
    public static List<OrderSelector.OrderDTO> getOrders(Id accountId) {
        return OrderSelector.getOrdersDTO(accountId);
    }
}