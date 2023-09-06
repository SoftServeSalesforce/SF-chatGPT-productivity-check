@IsTest
public with sharing class TestDataFactory {
    
    private static final Id STANDART_PRICE_BOOK_ID = Test.getStandardPricebookId();

    private static final String CONTRACT_DRAFT = 'Draft';
    private static final String ORDER_DRAFT = 'Draft';
    private static final String PRODUCT_FAMILY = 'TEST';

    public static Account makeAccount(String name) {
        Account acc = new Account();
        acc.Name = name;
        return acc;
    }

    public static Contract makeContract(Id accountId) {
        Contract contr = new Contract();
        contr.AccountId = accountId;
        contr.Status = CONTRACT_DRAFT;
        contr.StartDate = Date.today().addDays(-1);
        contr.ContractTerm = 1;
        return contr;
    }

    public static Product2 makeProduct(String name) {
        Product2 product = new Product2();
        product.Name = name;
        product.Family = PRODUCT_FAMILY;
        return product;
    }

    public static PricebookEntry makePriceBookEntry(Id productId) {
        PricebookEntry pe = new PricebookEntry();
        pe.Pricebook2Id = STANDART_PRICE_BOOK_ID;
        pe.Product2Id = productId;
        pe.UnitPrice = 1;
        pe.IsActive = true;
        return pe;
    }

    public static Order makeOrder(Id accountId, Id contractId) {
        Order ord = new Order();
        ord.AccountId = accountId;
        ord.ContractId = contractId;
        ord.EffectiveDate = Date.today().addDays(-1);
        ord.Status = ORDER_DRAFT;
        ord.Pricebook2Id = STANDART_PRICE_BOOK_ID;
        return ord;
    }

    public static OrderItem makeOrderItem(Id orderId, Id pricebookEntryId) {
        OrderItem item = new OrderItem();
        item.OrderId = orderId;
        item.PricebookEntryId = pricebookEntryId;
        item.Quantity = 1;
        item.UnitPrice = 1;
        return item;
    }

    public static Account createAccount(String name) {
        Account acc = makeAccount(name);
        insert acc;
        return acc;
    }

    public static Contract createContract(Id accountId) {
        Contract contr = makeContract(accountId);
        insert contr;
        return contr;
    }

    public static Product2 createProduct(String name) {
        Product2 product = makeProduct(name);
        insert product;
        return product;
    }

    public static PricebookEntry createPricebookEntry(Id productId) {
        PricebookEntry pe = makePriceBookEntry(productId);
        insert pe;
        return pe;
    }

    public static Order createOrder(Id accountId, Id contractId) {
        Order ord = makeOrder(accountId, contractId);
        insert ord;
        return ord;
    }

    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId) {
        OrderItem item = makeOrderItem(orderId, pricebookEntryId);
        insert item;
        return item;
    }

    public static List<Order> createOrders(Id accountId, Id contractId, Integer amount) {
        List<Order> orders = new List<Order>();
        for(Integer i = 0; i < amount; i++) {
            orders.add(makeOrder(accountId, contractId));
        }
        insert orders;
        return orders;
    }

    public static List<OrderItem> createOrderItems(List<Order> orders, Id pricebookEntryId) {
        List<OrderItem> orderItems = new List<OrderItem> ();
        for (Order ord : orders) {
            orderItems.add(makeOrderItem(ord.Id, pricebookEntryId));
        }
        insert orderItems;
        return orderItems;
    }
}