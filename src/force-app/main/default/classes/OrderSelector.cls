public with sharing class OrderSelector {

    private static List<Order> orders;

    public static List<OrderDTO> getOrdersDTO(Id accountId){
        List<Order> orders = getOrdersbyAccountId(accountId);
        return convertOrdersToOrderDTOs(orders);
    }

    private static List<Order> getOrdersbyAccountId(Id accountId) {
        return [SELECT Id, OrderNumber, AccountId, EffectiveDate, Status, TotalAmount FROM Order WHERE AccountId = :accountId WITH SECURITY_ENFORCED];
    }

    private static List<OrderDTO> convertOrdersToOrderDTOs(List<Order> source) {

        List<OrderDTO> result = new List<OrderDTO>();
        for (Order o : source) {
            OrderDTO orderDTO = new OrderDTO();
            orderDTO.orderNumber = o.OrderNumber;
            orderDTO.orderDate = o.EffectiveDate;
            orderDTO.status = o.Status;
            orderDTO.amount = o.TotalAmount;
            result.add(orderDTO);
        }
        return result;
    }

    public class OrderDTO {
        String id{get;set;}
        String accountId{get; set;}
        String orderNumber{get;set;}
        Date orderDate{get;set;}
        String status{get;set;}
        Decimal amount{get;set;}
    }
}