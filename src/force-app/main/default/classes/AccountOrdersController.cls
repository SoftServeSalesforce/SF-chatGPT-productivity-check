/**
 * @description AccountOrdersController: Apex Class used as a controller for 'AccountOrders' LWC.
 * //TODO: Cover with Apex Tests.
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
            OrderService.getInstance().setOrdersStatusToActived(orderIds);
            our.status = Constants.ORDER_UPDATE_STATUS_OK;
        } catch (Exception e) {
            our.status = Constants.ORDER_UPDATE_STATUS_ERROR;
            our.errorMessage = e.getMessage();
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
            OrderService.getInstance().setOrdersStatusToShipped(orderIds);
            our.status = Constants.ORDER_UPDATE_STATUS_OK;
        } catch (Exception e) {
            our.status = Constants.ORDER_UPDATE_STATUS_ERROR;
            our.errorMessage = e.getMessage();
        }
        return our;
    }

    /**
     * @description OrderDTO: DTO used to pass Order details
     * in UI-friendly format.
     */
    public class OrderDTO {
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordURL;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public Boolean canBeActivated;
        @AuraEnabled
        public Boolean canBeShipped;
        @AuraEnabled
        public String invoicePreviewURL;
        @AuraEnabled
        public String invoiceDownloadURL;
        @AuraEnabled
        public Boolean hasInvoice;
        @AuraEnabled
        public Boolean showActionsMenu;

        public void addOrderDetails(Order o) {
            //Safety block to avoid NLPE.
            if (null == o) {
                throw new IllegalArgumentException(Constants.EXCEPTION_ORDER_CANNOT_BE_NULL);
            }
            this.recordId = o.Id;
            this.recordURL = '/' + o.Id;
            this.orderNumber = o.OrderNumber;
            this.startDate = o.EffectiveDate;
            this.status = o.Status;
            this.amount = o.TotalAmount;
            this.initCanBeActivatedFlag();
            this.initCanBeShippedFlag();
            this.initShowActionsMenuFlag();
        }

        public void addInvoice(ContentDocumentLink cdl) {
            //Safety block to avoid NLPE.
            if (null == cdl) {
                return;
            }
            this.hasInvoice = true;
            this.invoicePreviewURL = '/' + cdl.ContentDocumentId;
            this.invoiceDownloadURL
                = Constants.CONTENT_DOCUMENT_VERSION_DOWNLOAD_LINK_TEMPLATE
                + cdl.ContentDocument.LatestPublishedVersionId;
            this.initShowActionsMenuFlag();
        }

        private void initCanBeActivatedFlag() {
            this.canBeActivated = Constants.ORDER_STATUS_DRAFT.equalsIgnoreCase(this.Status);
        }

        private void initCanBeShippedFlag() {
            this.canBeShipped = Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(this.Status);
        }

        private void initShowActionsMenuFlag() {
            this.showActionsMenu = true == this.canBeActivated || true == this.canBeShipped || true == this.hasInvoice;
        }
    }

    /**
     * @description OrderUpdateResultDTO: DTO used to pass details
     * about Order update in UI-friendly format.
     */
    public class OrderUpdateResultDTO {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String errorMessage;
    }
}