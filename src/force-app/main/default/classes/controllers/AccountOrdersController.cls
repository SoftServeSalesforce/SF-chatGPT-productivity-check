/**
 * @description AccountOrdersController: Apex Class used as a controller for 'AccountOrders' LWC.
 */
public with sharing class AccountOrdersController {

    /**
     * @description getPageSizeFromLWCPaginationSetting: Method used to get last selected Page Size
     * or Default value for current User.
     * @return: Last selected Page Size or Default value.
     */
    @AuraEnabled(cacheable=false)
    public static Integer getPageSizeFromLWCPaginationSetting() {
        Integer result = (Integer) CustomSettingsSelector.getInstance().getLWCPaginationSettings().PageSize__c;
        if (null == result || result <= 0) {
            result = Constants.LWC_PAGINATION_PAGE_SIZE_DEFAULT;
        }
        return result;
    }

    /**
     * @description updatePageSizeForLWCPaginationSetting: Method used to memorize last Page Size,
     * selected by User.
     * @param pageSize: New page size.
     */
    @AuraEnabled(cacheable=false)
    public static void updatePageSizeForLWCPaginationSetting(Integer pageSize) {
        //Validate given arguments.
        if (null == pageSize) {
            throw new IllegalArgumentException(Constants.EXCEPTION_PAGESIZE_CANNOT_BE_NULL);
        }
        if (0 >= pageSize) {
            throw new IllegalArgumentException(Constants.EXCEPTION_PAGESIZE_CANNOT_BE_EQUAL_TO_OR_LESS_THAN_ZERO);
        }
        CustomSettingsService.getInstance().capturePreferredLWCPaginationPageSize(pageSize);
    }

    /**
     * @description getOrders: Methdo used to get "Order" SObject records with
     * given "accountId" value specified as "AccountId" Lookup Field value
     * in UI-friendly format.
     * @param accountId: Account Id used for "Order" SObject records filtering.
     * @param pageNumber: Used to determine offset, starts from 0.
     * @param pageSize: Used to determine offset.
     */
    @AuraEnabled(cacheable=false)
    public static PageWithOrdersDTO getOrders(Id accountId, Integer pageNumber, Integer pageSize) {
        //Validate given arguments.
        validateGetOrdersRequest(accountId, pageNumber, pageSize);
        PageWithOrdersDTO result = new PageWithOrdersDTO();
        Database.QueryLocator ql = OrderSelector.getInstance().getQueryLocatorToOrdersByParentAccountId(accountId);
        //Pagination happens here.
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(ql);
        ssc.setPageSize(pageSize);
        ssc.setPageNumber(pageNumber);
        result.addPageDetails(ssc);
        Map<Id, Order> ordersById = new Map<Id,Order>((List<Order>)ssc.getRecords());
        Map<Id, Id> invoicesByOrderId = ContentDocumentLinkService.getInstance().getTheMostRecentInvoicesIdsByParentId(ordersById.keySet());
        for (Id oId : ordersById.keySet()) {
            result.orders.add(
                new OrderDTO(ordersById.get(oId), invoicesByOrderId.get(oId))
            );
        }
        return result;
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
            Map<Id,Order> ordersById = new Map<Id,Order>(OrderSelector.getInstance().getOrdersById(new Set<Id>(orderIds)));
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
            Map<Id,Order> ordersById = new Map<Id,Order>(OrderSelector.getInstance().getOrdersById(new Set<Id>(orderIds)));
            List<Database.SaveResult> saveResults = OrderService.getInstance().setOrdersStatusToShipped(ordersById.values());
            our.captureErrorsFromSaveResults(ordersById, saveResults);
        } catch (Exception e) {
            our.captureException(e);
        }
        return our;
    }

    @TestVisible
    private static void validateGetOrdersRequest(Id accountId, Integer pageNumber, Integer pageSize) {
        if (String.isBlank(accountId)) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ACCOUNTID_CANNOT_BE_BLANK);
        }
        if (Account.SObjectType != accountId.getSObjectType()) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ACCOUNTID_IS_NOT_VALID);
        }
        if (null == pageNumber) {
            throw new IllegalArgumentException(Constants.EXCEPTION_PAGENUMBER_CANNOT_BE_NULL);
        }
        if (0 >= pageNumber) {
            throw new IllegalArgumentException(Constants.EXCEPTION_PAGENUMBER_BE_EQUAL_TO_OR_LESS_THAN_ZERO);
        }
        if (null == pageSize) {
            throw new IllegalArgumentException(Constants.EXCEPTION_PAGESIZE_CANNOT_BE_NULL);
        }
        if (0 >= pageSize) {
            throw new IllegalArgumentException(Constants.EXCEPTION_PAGESIZE_CANNOT_BE_EQUAL_TO_OR_LESS_THAN_ZERO);
        }
    }

    @TestVisible
    private static void validateStatusChangeRequest(List<Id> orderIds) {
        if (null == orderIds) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ORDERIDS_CANNOT_BE_NULL);
        }
        if (orderIds.isEmpty()) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ORDERIDS_CANNOT_BE_EMPTY);
        }
        for (Id oId : orderIds) {
            if (null == oId || Order.SObjectType != oId.getSobjectType()) {
                throw new IllegalArgumentException(Constants.EXCEPTION_ORDERIDS_SHOULD_CONTAIN_ONLY_VALID_ORDER_IDS);
            }
        }
    }
}