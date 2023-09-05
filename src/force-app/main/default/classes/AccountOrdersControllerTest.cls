@isTest
public class AccountOrdersControllerTest {
    public static final Integer DEFAULT_PAGE_SIZE = 10;

    @testSetup
    static void makeData() {
        Account acc = new Account(Name = 'testAccount');
        insert acc;        

        List<Product2> products = new List<Product2>{
            new Product2(Name = 'testProduct#1', IsActive = true),
            new Product2(Name = 'testProduct#2', IsActive = true)
        };
        insert products;

        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> standartPricebook = new List<PricebookEntry>();
        for (Product2 prod : products) {
            standartPricebook.add(new PricebookEntry(
                Product2Id = prod.Id,
                Pricebook2Id = standardPricebookId,
                UnitPrice = 1000.00,
                IsActive = true
            ));
        }
        insert standartPricebook;

        Contract contract = new Contract(
            AccountId = acc.Id,
            StartDate = System.today(),
            ContractTerm = 10,
            Pricebook2Id = standardPricebookId,
            Status = 'Draft'
        );
        insert contract;

        contract.Status = 'Activated';
        update contract;

        List<Order> orders = new List<Order> {
            new Order(AccountId = acc.Id, Status = 'Draft', Pricebook2Id = standardPricebookId, ContractId = contract.Id, EffectiveDate = System.today()),
            new Order(AccountId = acc.Id, Status = 'Draft', Pricebook2Id = standardPricebookId, ContractId = contract.Id, EffectiveDate = System.today()),
            new Order(AccountId = acc.Id, Status = 'Draft', Pricebook2Id = standardPricebookId, ContractId = contract.Id, EffectiveDate = System.today()),
            new Order(AccountId = acc.Id, Status = 'Draft', Pricebook2Id = standardPricebookId, ContractId = contract.Id, EffectiveDate = System.today())
        };
        insert orders;
        
        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : orders) {
            for (PricebookEntry pbe : standartPricebook) {
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

        OrderListPaginationPageSize__c settings = new OrderListPaginationPageSize__c();     
        settings.Page_Size__c = DEFAULT_PAGE_SIZE;
        insert settings;
    }

    @isTest
    static void testGetOrdersSuccess() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        List<AccountOrdersController.OrderDTO> result = AccountOrdersController.getOrders(acc.Id, 0, 0);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected not null result.');

        List<Order> orders = [SELECT ID FROM Order WHERE accountId =: acc.Id];
        Assert.areEqual(orders.size(), result.size(), 'The size of the result does not match the size of the orders.');
    }

    @isTest
    static void testGetOrdersFailure() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.getOrders(null, 10, 1);
            System.assert(false, 'Expected an invalid account id exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Expected an invalid account id exception.');
    }

    @isTest
    static void testGetPageSizeSuccess() {        
        Test.startTest();
        Integer result = AccountOrdersController.getPageSize();
        Test.stopTest();

        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual(DEFAULT_PAGE_SIZE, result, 'Expected default page size.');
    }

    // @isTest
    // static void testGetPageSizeFailure() {        
    //     Test.startTest();
    //     Integer result = AccountOrdersController.getPageSize();
    //     Test.stopTest();

    //     // Assert.areNotEqual(null, result);
    //     // Assert.areEqual(DEFAULT_PAGE_SIZE, result);
    // }

    @isTest
    static void testSetPageSizeSuccess() {
        Test.startTest();
        Map<String, Object> result = AccountOrdersController.setPageSize(25);
        Test.stopTest();

        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('OK', result.get('status'), 'Expected OK satus.');
    }

    @isTest
    static void testSetPageSizeFailure() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.setPageSize(0);
            System.assert(false, 'Expected an invalid page size exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Expected an invalid page size exception.');
    }

    @isTest
    static void testSetPageSizeErrorResponse() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.setPageSize(0);
            System.assert(false, 'Expected an invalid page size exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Expected an invalid page size exception.');
    }

    @isTest
    static void testActivateOrderSuccess() {
        Order draftOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = AccountOrdersController.activateOrder(draftOrder.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('OK', result.get('status'), 'Expected OK status.');       

        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :draftOrder.Id LIMIT 1];
        Assert.areEqual('Activated', updatedOrder.Status, 'Expected order to be Activated status.');
    }

    @isTest
    static void testActivateOrderFailure() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.activateOrder(null);
            System.assert(false, 'Expected an invalid order id exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Expected an invalid order id exception.');
    }

    @isTest
    static void testActivateOrderErrorResponse() {
        Exception testException;
        Order activatedOrder = [SELECT Id, Status FROM Order WHERE Status = 'Activated' LIMIT 1];

        Test.startTest();
        Map<String, Object> result = AccountOrdersController.activateOrder(activatedOrder.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('ERROR', result.get('status'), 'Expected error response.');
    }

    
    @isTest
    static void testMarkOrderAsShippedSuccess() {
        Order activatedOrder = [SELECT Id FROM Order WHERE Status = 'Activated' LIMIT 1];

        Test.startTest();
        Map<String,Object> result = AccountOrdersController.markOrderAsShipped(activatedOrder.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('OK', result.get('status'), 'Expected OK result status.');        

        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :activatedOrder.Id LIMIT 1];

        Assert.areEqual('Shipped', updatedOrder.Status, 'Expected order to have Shipped status.');
    }

    @isTest
    static void testMarkOrderAsShippedFailure() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.markOrderAsShipped(null);
            System.assert(false, 'Expected an invalid order id exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Expected an invalid order id exception.');
    }

    @isTest
    static void testMarkOrderAsShippedErrorResponse() {
        Exception testException;
        Order draftOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];

        Test.startTest();
        Map<String, Object> result = AccountOrdersController.markOrderAsShipped(draftOrder.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('ERROR', result.get('status'), 'Expected error response.');
    }

    @isTest
    static void testGetTotalOrderCountSuccess() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Integer result = AccountOrdersController.getTotalOrderCount(acc.Id);
        Test.stopTest();

        Integer totalOrderCount = [SELECT COUNT() FROM Order WHERE accountId =: acc.Id];

        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual(totalOrderCount, result, 'Total order count does not match.');
    }

    @isTest
    static void testGetTotalOrderCountFailure() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.getTotalOrderCount(null);
            System.assert(false, 'Expected an invalid account id exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Exception expected.');
    }

    @isTest
    static void testBulkActivateOrdersSuccess() {
        List<Order> draftOrders = [SELECT Id FROM Order WHERE Status = 'Draft'];
        List<Id> ordersIds = new List<Id>();
        for(Order o : draftOrders) {
            ordersIds.add(o.Id);
        }

        Test.startTest();
        List<Map<String,Object>> result = AccountOrdersController.bulkActivateOrders(ordersIds);
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('OK', result[0].get('status'), 'Expected OK result status.');           
        Assert.areEqual('OK', result[1].get('status'), 'Expected OK result status.');          
        Test.stopTest();  

        List<Order> updatedOrders = [SELECT Id, Status FROM Order WHERE Id IN: ordersIds];
        for(Order o : updatedOrders) {
            Assert.areEqual('Activated', o.Status, 'Expected orders to be Activated status.');
        }
    }

    @isTest
    static void testBulkActivateOrdersFailure() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.bulkActivateOrders(null);
            System.assert(false, 'Expected an invalid orders ids exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Exception expected.');
    }

    @isTest
    static void testBulkActivateOrdersErrorResponse() {
        Exception testException;
        List<Order> activatedOrders = [SELECT Id FROM Order WHERE Status = 'Activated'];
        List<Id> ordersIds = new List<Id>();
        for(Order o : activatedOrders) {
            ordersIds.add(o.Id);
        }

        Test.startTest();
        List<Map<String, Object>> result = AccountOrdersController.bulkActivateOrders(ordersIds);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('ERROR', result[0].get('status'), 'Expected error response.');
        Assert.areEqual('ERROR', result[1].get('status'), 'Expected error response.');
    }

    @isTest
    static void testBulkMarkOrdersAsShippedSuccess() {
        List<Order> activatedOrders = [SELECT Id FROM Order WHERE Status = 'Activated'];
        List<Id> ordersIds = new List<Id>();
        for(Order o : activatedOrders) {
            ordersIds.add(o.Id);
        }
        
        Test.startTest();
        List<Map<String,Object>> result = AccountOrdersController.bulkMarkOrdersAsShipped(ordersIds);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('OK', result[0].get('status'), 'Expected OK result status.');   
        
        List<Order> updatedOrders = [SELECT Id, Status FROM Order WHERE Id IN :ordersIds];
        for(Order o : updatedOrders) {
            Assert.areEqual('Shipped', o.Status, 'Expected order to have Shipped status.');
        }       
    }

    @isTest
    static void testBulkMarkOrdersAsShippedFailure() {
        Exception testException;

        Test.startTest();
        try {
            AccountOrdersController.bulkMarkOrdersAsShipped(null);
            System.assert(false, 'Expected an invalid orders ids exception.');
        } catch (Exception e) {
            testException = e;
        }
        Test.stopTest();

        Assert.isNotNull(testException, 'Exception expected.');
    }

    @isTest
    static void testBulkMarkOrdersAsShippedErrorResponse() {
        Exception testException;
        List<Order> draftOrders = [SELECT Id FROM Order WHERE Status = 'Draft'];
        List<Id> ordersIds = new List<Id>();
        for(Order o : draftOrders) {
            ordersIds.add(o.Id);
        }

        Test.startTest();
        List<Map<String, Object>> result = AccountOrdersController.bulkMarkOrdersAsShipped(ordersIds);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected result.');
        Assert.areEqual('ERROR', result[0].get('status'), 'Expected error response.');
        Assert.areEqual('ERROR', result[1].get('status'), 'Expected error response.');
    }
}