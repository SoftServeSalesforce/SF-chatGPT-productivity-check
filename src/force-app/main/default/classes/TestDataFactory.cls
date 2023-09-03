@IsTest
public class TestDataFactory {
    public static Account createAccount(Boolean toInsert) {
        Account acc = new Account();
        acc.Name = 'Test Account';
        if (toInsert) {
            insert acc;
        }
        return acc;
    }

    public static Product2 createProduct(Boolean toInsert) {
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'TST';
        p.isActive = true;
        if (toInsert) {
            insert p;
        }
        return p;
    }

    public static PricebookEntry createPricebookEntry(Product2 p, Boolean toInsert) {
        PricebookEntry pe = new PricebookEntry();
        pe.Pricebook2Id = Test.getStandardPricebookId();
        pe.Product2Id = p.Id;
        pe.UnitPrice = 1;
        pe.IsActive = true;
        pe.UseStandardPrice = false;
        if (toInsert) {
            insert pe;
        }
        return pe;
    }

    public static Order createOrder(Account acc, Boolean toInsert) {
        Order o = new Order();
        o.AccountId = acc.Id;
        o.Pricebook2Id =  Test.getStandardPricebookId();
        o.Status = 'Draft';
        o.EffectiveDate = Date.today();
        if (toInsert) {
            insert o;
        }
        return o;
    }

    public static OrderItem createOrderItem(Order o, PricebookEntry pe, Boolean toInsert) {
        OrderItem oi = new OrderItem();
        oi.OrderId = o.id;
        oi.Quantity = 1;
        oi.UnitPrice = 1;
        oi.Product2Id = pe.Product2Id;
        oi.PricebookEntryId = pe.id;
        if (toInsert) {
            insert oi;
        }
        return oi;
    }
}