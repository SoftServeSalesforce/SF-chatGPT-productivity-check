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
            OrderDTO dto = new OrderDTO();
            dto.recordId = orderInfo.Id;
            dto.recordURL = '/' + orderInfo.Id;
            dto.startDate = orderInfo.EffectiveDate;
            dto.status = orderInfo.Status;
            dto.amount = orderInfo.TotalAmount;
            result.add(dto);
        }
        return result;
    }

    /**
     * @description OrderDTO: DTO Used to pass orders in UI-friendly format.
     */
    public class OrderDTO {
        public String recordId;
        public String recordURL;
        public Date startDate;
        public String status;
        public Decimal amount;
    }
}