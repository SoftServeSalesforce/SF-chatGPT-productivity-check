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
            List<Order> orderInfos = OrderSelector.getInstance().getOrdersByParentAccountId(ORDER_FIELDS, accountId);
            //Safety block. Ensures that there is anything to convert.
            if (!orderInfos.isEmpty()) {
                result.addAll(convertOrderInfosToOrderDTOs(orderInfos));
            }
            //Return UI-friendly data.
            System.debug('result: ' + result);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description convertOrderInfosToOrderDTOs: Helper method needed to convert list of
     * "Order" SObject records to list of "OrderDTO" ones.
     * @param orderInfos: Records to convert.
     * @return: "Order" records converted to "OrderDTO" ones.
     */
    private static List<OrderDTO> convertOrderInfosToOrderDTOs(List<Order> orderInfos) {
        List<OrderDTO> result = new List<OrderDTO>();
        for (Order orderInfo : orderInfos) {
            result.add(new OrderDTO(orderInfo));
        }
        return result;
    }

    /**
     * @description OrderDTO: DTO Used to pass orders in UI-friendly format.
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

        /**
         * @description OrderDTO description
         * @param o: Order to be wrapped
         * @return: OrderDTO instance.
         */
        public OrderDTO(Order o) {
            this.recordId = o.Id;
            this.recordURL = '/' + o.Id;
            this.orderNumber = o.OrderNumber;
            this.startDate = o.EffectiveDate;
            this.status = o.Status;
            this.amount = o.TotalAmount;
        }
    }
}