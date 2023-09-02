/**
 * @description AccountOrdersController: Apex Class used as a controller for 'AccountOrders' LWC.
 * @note: 'AccountOrders' LWC does not exist yet; Apex tests needs to be added.
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
            List<Order> relatedOrders = OrderSelector.getInstance().getOrdersByParentAccountId(ORDER_FIELDS, accountId);
            //Convert to UI-friendly format.
            for (Order relatedOrder : relatedOrders) {
                result.add(new OrderDTO(relatedOrder));
            }
            //Return UI-friendly data.
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description OrderDTO: DTO Used to pass orders in UI-friendly format.
     * @note: Not certain what for it is needed as we can use fields we have available.
     * To be updated/deleted later.
     */
    public class OrderDTO {
        Order record;
        public OrderDTO(Order o) {
            this.record = o;
        }
    }
}