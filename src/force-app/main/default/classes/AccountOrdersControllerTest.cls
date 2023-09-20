@isTest
private class AccountOrdersControllerTest {
    
    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    
        Contract con = new Contract(
            AccountId = acc.Id,
            StartDate = Date.today().addDays(10),
            ContractTerm = 3,
            Status = 'Draft'
        );
        insert con;
        con.Status = 'Activated';
        update con;
    
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPbId, 
            Product2Id = prod.Id, 
            UnitPrice = 100.00, 
            IsActive = true);
        insert pbe;
    
        List<Order> testOrders = new List<Order>();
        for (Integer i = 0; i < 15; i++) {
            Order ord = new Order(
                AccountId = acc.Id,
                ContractId = con.Id,
                Status = 'Draft',
                EffectiveDate = Date.today().addDays(15),
                Pricebook2Id = standardPbId
            );
            testOrders.add(ord);
        }
        insert testOrders;
    
        List<OrderItem> orderItems = new List<OrderItem>();
        for(Order ord : testOrders) {
            OrderItem oi = new OrderItem(
                OrderId = ord.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 2,
                UnitPrice = 100.00
            );
            orderItems.add(oi);
        }
        insert orderItems;
    }

    @isTest
    static void testGetOrders() {
        Test.startTest();
        List<AccountOrdersController.OrderDTO> orderDTOs = AccountOrdersController.getOrders([SELECT Id FROM Account LIMIT 1][0].Id, 1, 10);
        Test.stopTest();

        System.assertEquals(10, orderDTOs.size(), 'Expected 10 orders in the result');
    }

    @isTest
    static void testGetOrdersCount() {
        Test.startTest();
        Integer ordersCount = AccountOrdersController.getOrdersCount([SELECT Id FROM Account LIMIT 1][0].Id);
        Test.stopTest();

        System.assertEquals(15, ordersCount, 'Expected 15 orders in total');
    }

    @isTest
    static void testGetUserPageSize() {
        Test.startTest();
        Integer pageSize = AccountOrdersController.getUserPageSize();
        Test.stopTest();

        System.assertEquals(10, pageSize, 'Expected default page size to be 10');
    }

    @isTest
    static void testSaveUserPageSize() {
        Test.startTest();
        AccountOrdersController.saveUserPageSize(20);
        Test.stopTest();

        OrderPageSize__c userSetting = OrderPageSize__c.getInstance(UserInfo.getUserId());
        System.assertEquals(20, userSetting.Page_Size__c, 'Expected page size to be saved as 20');
    }

    @isTest
    static void testActivateOrder() {
        List<Order> orders = [SELECT Id FROM Order WHERE Status = 'Draft'];
        List<OrderItem> items = [SELECT Id, OrderId FROM OrderItem];
        
        List<Id> draftOrderIds = new List<Id>();
        for (Order ord : orders) {
            draftOrderIds.add(ord.Id);
        } 
        Test.startTest();
        Map<String, String> response = AccountOrdersController.activateOrder(draftOrderIds);
        Test.stopTest();

        System.assertEquals('OK', response.get('status'), 'Expected successful activation of orders');
    }

    @isTest
    static void testActivateOrder_InvalidOrder() {
        Id fakeOrderId = 'a0Q3h000004zXYZ';
        Test.startTest();
        Map<String, String> result = AccountOrdersController.activateOrder(new List<Id>{fakeOrderId});
        Test.stopTest();
        System.assertEquals('ERROR', result.get('status'));
        System.assert(result.get('ErrorMessage').contains('Invalid operation'), result.get('ErrorMessage'));
    }

    @isTest
    static void testActivateOrder_Null() {
 
        Test.startTest();
        Map<String, String> result = AccountOrdersController.activateOrder(null);
        Test.stopTest();
        System.assertEquals('ERROR', result.get('status'));
        System.assert(result.get('ErrorMessage').contains('Invalid operation'), 'Error message ' + result.get('ErrorMessage') + ' does not contain `Invalid Operation` text literal');
    }

    @isTest
    static void testMarkOrderAsShipped_Null() {
 
        Test.startTest();
        Map<String, String> result = AccountOrdersController.markOrderAsShipped(null);
        Test.stopTest();
        System.assertEquals('ERROR', result.get('status'));
        System.assert(result.get('ErrorMessage').contains('Invalid operation'), 'Error message ' + result.get('ErrorMessage') + ' does not contain `Invalid Operation` text literal');
    }

    @isTest
    static void testMarkOrderAsShipped() {
        List<Order> orders = [SELECT Id FROM Order WHERE Status = 'Draft'];
        List<Id> activeOrderIds = new List<Id>();
        for (Order ord : orders) {
            activeOrderIds.add(ord.Id);
        }
        AccountOrdersController.activateOrder(activeOrderIds);
        Test.startTest();
        Map<String, String> response = AccountOrdersController.markOrderAsShipped(activeOrderIds);
        Test.stopTest();

        System.assertEquals('OK', response.get('status'), 'Expected successful marking of orders as shipped');
    }

    @isTest
    static void testMarkOrderAsShipped_NotActivated() {
        List<Order> testOrders = [SELECT Id FROM Order WHERE Status != 'Activated' LIMIT 1];
        Test.startTest();
        Map<String, String> result = AccountOrdersController.markOrderAsShipped(new List<Id>{testOrders[0].Id});
        Test.stopTest();
        System.assertEquals('ERROR', result.get('status'));
        System.assert(result.get('ErrorMessage').contains('Invalid operation'), result.get('ErrorMessage'));
    }
}
