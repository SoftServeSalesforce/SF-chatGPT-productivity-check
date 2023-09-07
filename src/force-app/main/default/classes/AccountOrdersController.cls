/**
 * @description AccountOrdersController: Apex Class used as a controller for 'AccountOrders' LWC.
 */
public with sharing class AccountOrdersController {

    /**
     * @description getOrders: Methdo used to get "Order" SObject records with
     * given "accountId" value specified as "AccountId" Lookup Field value
     * in UI-friendly format.
     * @param accountId: Account Id used for "Order" SObject records filtering.
     */
    @AuraEnabled(cacheable=false)
    public static List<OrderDTO> getOrders(Id accountId) {
        try {
            //Safety block. Ensures that 'accountId' in not blank (white space, empty (''), or null).
            if (String.isBlank(accountId)) {
                throw new IllegalArgumentException(Constants.EXCEPTION_ACCOUNTID_CANNOT_BE_BLANK);
            }
            //Safety block. Ensures that 'accountId' is a valid Account Id.
            if (Account.SObjectType != accountId.getSObjectType()) {
                throw new IllegalArgumentException(Constants.EXCEPTION_ACCOUNTID_IS_NOT_VALID);
            }
            //Get data.
            List<OrderDTO> result = new List<OrderDTO>();
            Map<Id, Order> ordersById = new Map<Id, Order>(OrderSelector.getInstance().getOrdersByParentAccountId(accountId));
            Map<Id, ContentDocumentLink> invoicesByOrderId = ContentDocumentLinkService.getInstance().getTheMostRecentInvoicesByParentId(ordersById.keySet());
            for (Id oId : ordersById.keySet()) {
                OrderDTO odto = new OrderDTO();
                odto.addOrderDetails(ordersById.get(oId));
                odto.addInvoice(invoicesByOrderId.get(oId));
                result.add(odto);
            }
            //Return UI-friendly data.
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description markOrdersAsActive: Updates status of Orders in scope to "Activated".
     * @param orderIds: Scope.
     * @return: OrderUpdateResultDTO instance. 
     */
    @AuraEnabled
    public static OrderUpdateResultDTO moveOrdersToActivatedStatus(List<Id> orderIds) {
        OrderUpdateResultDTO our = new OrderUpdateResultDTO();
        try {
            validateStatusChangeRequest(orderIds);
            Map<Id, Order> ordersById = new Map<Id, Order>(OrderSelector.getInstance().getOrdersById(new Set<Id>(orderIds)));
            List<Database.SaveResult> saveResults = OrderService.getInstance().setOrdersStatusToActived(ordersById.values());
            our.captureErrorsFromSaveResults(ordersById, saveResults);
        } catch (Exception e) {
            our.captureException(e);
        }
        return our;
    }

    /**
     * @description markOrdersAsShipped: Updates status of Orders in scope to "Shipped".
     * @param orderIds: Scope.
     * @return: OrderUpdateResultDTO instance. 
     */
    @AuraEnabled
    public static OrderUpdateResultDTO moveOrdersToShippedStatus(List<Id> orderIds) {
        OrderUpdateResultDTO our = new OrderUpdateResultDTO();
        try {
            validateStatusChangeRequest(orderIds);
            Map<Id, Order> ordersById = new Map<Id, Order>(OrderSelector.getInstance().getOrdersById(new Set<Id>(orderIds)));
            List<Database.SaveResult> saveResults = OrderService.getInstance().setOrdersStatusToShipped(ordersById.values());
            our.captureErrorsFromSaveResults(ordersById, saveResults);
        } catch (Exception e) {
            our.captureException(e);
        }
        return our;
    }

    /**
     * @description validateStatusChangeRequest: Helper method to ensure that only valid
     * data is passed on Order Status Change request.
     * @param orderIds: Scope.
     */
    private static void validateStatusChangeRequest(List<Id> orderIds) {
        if (null == orderIds) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ACCOUNTID_CANNOT_BE_BLANK);
        }
        if (orderIds.isEmpty()) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ORDERID_CANNOT_BE_EMPTY);
        }
        for (Id oId : orderIds) {
            if (null == oId || Order.SObjectType != oId.getSobjectType()) {
                throw new IllegalArgumentException(Constants.EXCEPTION_ORDERID_SHOULD_CONTAIN_ONLY_VALID_ORDER_IDS);
            }
        }
    }
}