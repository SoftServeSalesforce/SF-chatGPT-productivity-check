public with sharing class OrderSelector {

    public Order[] getOrdersByAccountId(Id accountId) {
        if (null == accountId){
            return new Order[]{};
        }
        return [
                SELECT OrderNumber, EffectiveDate, Status, TotalAmount
                FROM Order
                WHERE AccountId = :accountId
        ];
    }

}