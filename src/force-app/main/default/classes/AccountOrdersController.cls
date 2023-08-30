public with sharing class AccountOrdersController {
    public class OrderDTO {
        public Id Id { get; set; }
        public String Name { get; set; }
        public String Status { get; set; }
        
        public OrderDTO(Order ord) {
            this.Id = ord.Id;
            this.Name = ord.Name;
            this.Status = ord.Status;
        }
    }
    
    public List<OrderDTO> getOrders(Id accountId) {
        OrderSelector orderSelector = OrderSelector.newInstance();
        
        List<Order> orders = orderSelector.selectOrdersByAccountId(accountId);
        
        List<OrderDTO> orderDTOs = new List<OrderDTO>();
        for(Order ord : orders) {
            orderDTOs.add(new OrderDTO(ord));
        }
        
        return orderDTOs;
    }
}
