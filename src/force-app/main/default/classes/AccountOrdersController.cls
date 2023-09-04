/**
 * @description AccountOrdersController: Apex Class used as a controller for 'AccountOrders' LWC.
 * //TODO: Cover with Apex Tests.
 */
public with sharing class AccountOrdersController {

    private static Set<SobjectField> ORDER_FIELDS = new Set<SObjectField> {
        Order.OrderNumber,
        Order.EffectiveDate,
        Order.Status,
        Order.TotalAmount
    };

    /**
     * @description getOrders: Methdo used to get "Order" SObject records with
     * given "accountId" value specified as "AccountId" Lookup Field value
     * in UI-friendly format.
     * @param accountId: Account Id used for "Order" SObject records filtering.
     */
    @AuraEnabled(cacheable=true)
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
            List<Order> orders = OrderSelector.getInstance().getOrdersByParentAccountId(ORDER_FIELDS, accountId);
            //Safety block. Ensures that there is anything to convert.
            for (Order o : orders) {
                OrderDTO odto = new OrderDTO();
                odto.addOrderDetails(o);
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
            OrderService service = OrderService.getInstance();
            List<Order> orders = service.buildOrders(new Set<Id>(orderIds));
            service.setOrdersStatusToActived(orders);
            update orders;
            our.status = Constants.ORDER_UPDATE_STATUS_OK;
        } catch (Exception e) {
            our.status = Constants.ORDER_UPDATE_STATUS_OK;
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
            OrderService service = OrderService.getInstance();
            List<Order> orders = service.buildOrders(new Set<Id>(orderIds));
            service.setOrdersStatusToShipped(orders);
            update orders;
            our.status = Constants.ORDER_UPDATE_STATUS_OK;
        } catch (Exception e) {
            our.status = Constants.ORDER_UPDATE_STATUS_OK;
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

        public void addOrderDetails(Order o) {
            OrderService service = OrderService.getInstance();
            this.recordId = o.Id;
            this.recordURL = '/' + o.Id;
            this.orderNumber = o.OrderNumber;
            this.startDate = o.EffectiveDate;
            this.status = o.Status;
            this.amount = o.TotalAmount;
            this.canBeActivated = service.canBeActivated(o);
            this.canBeShipped = service.canBeShipped(o);
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