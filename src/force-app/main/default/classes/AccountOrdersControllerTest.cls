@IsTest
public class AccountOrdersControllerTest {

    public static final Integer DEFAULT_PAGE_SIZE = 10;

    @testSetup
    static void setupData() {
        // Create an Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;        

        // Create Products
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Product A', IsActive = true),
            new Product2(Name = 'Product B', IsActive = true)
        };
        insert products;

        // Create standard Pricebook Entries
        Id standardPricebook = Test.getStandardPricebookId();
        
        List<PricebookEntry> stdPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            stdPricebookEntries.add(new PricebookEntry(
                Product2Id = prod.Id,
                Pricebook2Id = standardPricebook,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        insert stdPricebookEntries;

        // Create a Custom Pricebook
        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Pricebook', IsActive = true);
        insert customPricebook;

        // Create custom Pricebook Entries
        List<PricebookEntry> customPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            customPricebookEntries.add(new PricebookEntry(
                Product2Id = prod.Id,
                Pricebook2Id = customPricebook.Id,
                UnitPrice = 200.00,
                IsActive = true
            ));
        }
        insert customPricebookEntries;

        // Create Contract
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            Pricebook2Id = customPricebook.Id,
            Status = 'Draft'
        );
        insert testContract;

        testContract.Status = 'Activated';
        update testContract;
        // Create Orders
        List<Order> orders = new List<Order>{
            new Order(AccountId = testAccount.Id, Status = 'Draft', Pricebook2Id = customPricebook.Id, ContractId = testContract.Id, EffectiveDate = System.today()),
            new Order(AccountId = testAccount.Id, Status = 'Draft', Pricebook2Id = customPricebook.Id, ContractId = testContract.Id, EffectiveDate = System.today()),
            new Order(AccountId = testAccount.Id, Status = 'Draft', Pricebook2Id = customPricebook.Id, ContractId = testContract.Id, EffectiveDate = System.today()),
            new Order(AccountId = testAccount.Id, Status = 'Draft', Pricebook2Id = customPricebook.Id, ContractId = testContract.Id, EffectiveDate = System.today())
        };
        insert orders;

        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : orders) {
            for (PricebookEntry pbe : customPricebookEntries) {
                orderItems.add(new OrderItem(
                    OrderId = ord.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    UnitPrice = pbe.UnitPrice
                ));
            }
        }
        insert orderItems;

        orders[0].Status = 'Activated';
        orders[1].Status = 'Activated';

        update orders;

        PaginationPageSize__c settings = new PaginationPageSize__c();     
        settings.Page_Size__c = DEFAULT_PAGE_SIZE;
        insert settings;
    }
    
    @isTest
    static void testGetOrdersSuccess() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
            List<AccountOrdersController.OrderDTO> result = AccountOrdersController.getOrders(testAccount.Id, 0, 0);
        Test.stopTest();        
        Assert.isNotNull(result, 'Result expected');
        List<Order> orders = [SELECT ID FROM Order WHERE accountId =: testAccount.Id];
        Assert.areEqual(orders.size(), result.size(), 'Retrieved order size expected to be ' + orders.size());
    }

    @isTest
    static void testGetOrdersFailure() {
        Test.startTest();
            Exception e;
            try {
                AccountOrdersController.getOrders(null, 10, 1);
                System.assert(false, 'Expected an exception to be thrown');
            } catch (Exception ex) {
                e = ex;            
            }
        Assert.isNotNull(e, 'Exception expected');
        Test.stopTest();
    }
    
    @isTest
    static void testGetTotalOrdersCountSuccess() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
            Integer result = AccountOrdersController.getTotalOrdersCount(testAccount.Id);
        Test.stopTest();
        Integer totalOrdersCount = [SELECT COUNT() FROM Order WHERE accountId =: testAccount.Id];
        Assert.isNotNull(result, 'Result expected');
        Assert.areEqual(totalOrdersCount, result, 'Total orders count expected ' + totalOrdersCount);
    }

    @isTest
    static void testGetTotalOrdersCountFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.getTotalOrdersCount(null);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception expected');
    }

    @isTest
    static void testGetPageSizeSuccess() {        
        Test.startTest();
            Integer result = AccountOrdersController.getPageSize();
        Test.stopTest();        
        Assert.areNotEqual(null, result);
        Assert.areEqual(DEFAULT_PAGE_SIZE, result);
    }

    @isTest
    static void testSetPageSizeSuccess() {
        Test.startTest();
            AccountOrdersController.OrderDMLSummaryResponse result = AccountOrdersController.setPageSize(20);
        Test.stopTest();        
        Assert.areNotEqual(null, result);
        Assert.areEqual('Default page size has been updated', result.responseMessage);
    }

    @isTest
    static void testSetPageSizeFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.setPageSize(0);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception expected');
    }

    @isTest
    static void testActivateOrderSuccess() {
        Order testOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        
        Test.startTest();
            AccountOrdersController.OrderDMLSummaryResponse result = AccountOrdersController.activateOrder(testOrder.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result expected');
        Assert.areEqual('Success', result.responseStatus, 'Expected success response');        

        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id LIMIT 1];
        Assert.areEqual('Activated', updatedOrder.Status, 'Expected orders to be updated to Activated status');
    }

    @isTest
    static void testActivateOrderFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.activateOrder(null);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception expected');
    }
    
    @isTest
    static void testMarkOrderAsShippedSuccess() {
        Order testOrder = [SELECT Id FROM Order WHERE Status = 'Activated' LIMIT 1];
        Test.startTest();
            AccountOrdersController.OrderDMLSummaryResponse result = AccountOrdersController.markOrderAsShipped(testOrder.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result expected');
        Assert.areEqual('Success', result.responseStatus, 'Success result expected');        

        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id LIMIT 1];
        Assert.areEqual('Shipped', updatedOrder.Status, 'Expected order to have updated status to Shipped');
    }

    @isTest
    static void testMarkOrderAsShippedFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.markOrderAsShipped(null);
            System.assert(false, 'Expected an exception to be thrown');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception expected');
    }

    @isTest
    static void testActivateOrdersSuccess() {
        List<Order> testOrders = [SELECT Id FROM Order WHERE Status = 'Draft'];
        List<Id> orderIds = new List<Id>();
        for(Order ord : testOrders) {
            orderIds.add(ord.Id);
        }

        Test.startTest();
            AccountOrdersController.OrderDMLSummaryResponse result = AccountOrdersController.activateOrders(orderIds);
            Assert.isNotNull(result, 'Result expected');
            Assert.areEqual('Success', result.responseStatus);                     
        Test.stopTest();  
        List<Order> updatedOrders = [SELECT Id, Status FROM Order WHERE Id IN: orderIds];
        for(Order order: updatedOrders) {
            Assert.areEqual('Activated', order.Status, 'Expected orders to be updated to Activated status');
        }         
    }

    @isTest
    static void testMarkOrdersAsShippedSuccess() {
        List<Order> testOrders = [SELECT Id FROM Order WHERE Status = 'Activated'];
        List<Id> orderIds = new List<Id>();
        for(Order ord : testOrders) {
            orderIds.add(ord.Id);
        }
        
        Test.startTest();
        AccountOrdersController.OrderDMLSummaryResponse result = AccountOrdersController.markOrdersAsShipped(orderIds);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result expected');
        Assert.areEqual('Success', result.responseStatus);   
        
        List<Order> updatedOrders = [SELECT Id, Status FROM Order WHERE Id IN :orderIds];
        for(Order order: updatedOrders) {
            Assert.areEqual('Shipped', order.Status, 'Expected order to have updated status to Shipped');
        }       
    }
}