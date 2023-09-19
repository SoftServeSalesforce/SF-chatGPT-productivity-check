@isTest
private class TestAccountOrdersController {
    static Account testAccount;
    static List<Order> testOrders;

    static void setupData() {
        testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Id standardPricebookId = Test.getStandardPricebookId();

        testOrders = new List<Order>{
            new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = standardPricebookId),
            new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.today())
        };
        insert testOrders;

        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;
        
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id =  testProduct.Id,
            UnitPrice = 100, 
            IsActive = true
        );
        insert testPricebookEntry;

        OrderItem item = new OrderItem(
            OrderId = testOrders[0].Id,
            UnitPrice = 10,
            PricebookEntryId = testPricebookEntry.Id,
            Product2id = testProduct.Id,
            Quantity = 2
        );
        insert item;
    }

    static void setupPageSizeSetting(Integer pageSize) {
        OredsListPageSettings__c settings = new OredsListPageSettings__c();
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.PageSize__c = pageSize;
        upsert settings;
    }

    @isTest static void testGetAllOrders() {
        setupData();
    
        Test.startTest();
        List<AccountOrdersController.OrderDTO> orderDTOs = AccountOrdersController.getOrders(testAccount.Id, 2, 0);
        Test.stopTest();
    
        System.assertEquals(2, orderDTOs.size(), 'Expected 2 orders to be returned.');
    }

    @isTest static void testGetHalfOrders() {
        setupData();
    
        Test.startTest();
        List<AccountOrdersController.OrderDTO> orderDTOs = AccountOrdersController.getOrders(testAccount.Id, 2, 1);
        Test.stopTest();
    
        System.assertEquals(1, orderDTOs.size(), 'Expected 1 order to be returned.');
    }

    @isTest static void testGetOrdersNumber() {
        setupData();
    
        Test.startTest();
        Integer orderCount = AccountOrdersController.getOrdersNumber(testAccount.Id);
        Test.stopTest();
    
        System.assertEquals(2, orderCount, 'Expected 2 orders for the account.');
    }
    
    @isTest static void testMarkOrderAsShipped() {
        setupData();
        testOrders[0].Status = 'Activated';
        update testOrders[0];
    
        Test.startTest();
        Map<String, String> result = AccountOrdersController.markOrderAsShipped(new List<Id>{testOrders[0].Id});
        Test.stopTest();
    
        System.assertEquals('', result.get('message'));
        System.assertEquals('OK', result.get('status'), 'Expected status to be OK.');
        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :testOrders[0].Id LIMIT 1];
        System.assertEquals('Shipped', updatedOrder.Status, 'Expected order status to be Shipped.');
    }

    @isTest static void testMarkInvalidOrderAsShipped() {
        setupData();
    
        Test.startTest();
        Map<String, String> result = AccountOrdersController.markOrderAsShipped(new List<Id>{testOrders[1].Id});
        Test.stopTest();
    
        System.assertEquals('ERROR', result.get('status'), 'Expected status to be ERROR.');
        System.assertEquals('Invalid Operation for Order #' + testOrders[1].Id, result.get('message'));
    }

    @isTest static void testActivateOrder() {
        setupData();
    
        Test.startTest();
        Map<String, String> result = AccountOrdersController.activateOrder(new List<Id>{testOrders[0].Id});
        Test.stopTest();
        
        System.assertEquals('', result.get('message'));
        System.assertEquals('OK', result.get('status'), 'Expected status to be OK.');
        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :testOrders[0].Id LIMIT 1];
        System.assertEquals('Activated', updatedOrder.Status, 'Expected order status to be Activated.');
    }

    @isTest static void testActivateInvalidOrder() {
        setupData();
        testOrders[0].Status = 'Activated';
        update testOrders[0];
    
        Test.startTest();
        Map<String, String> result = AccountOrdersController.activateOrder(new List<Id>{testOrders[0].Id});
        Test.stopTest();
        System.assertEquals('Invalid Operation for Order #' + testOrders[0].Id, result.get('message'));
        System.assertEquals('ERROR', result.get('status'), 'Expected status to be error.');
    }
    
    @isTest static void testGetPageSize() {
        Integer expectedPageSize = 5;
        setupPageSizeSetting(expectedPageSize);
    
        Test.startTest();
        Integer pageSize = AccountOrdersController.getPageSize();
        Test.stopTest();
    
        System.assertEquals(expectedPageSize, pageSize, 'Expected the retrieved page size to match the set value.');
    }
    
    @isTest static void testSetPageSize() {
        Integer newPageSize = 10;
    
        Test.startTest();
        AccountOrdersController.setPageSize(newPageSize);
        Test.stopTest();
    
        OredsListPageSettings__c settings = OredsListPageSettings__c.getInstance(UserInfo.getUserId());
        System.assertEquals(newPageSize, (Integer) settings.PageSize__c, 'Expected the page size to be updated in custom settings.');
    }
    @isTest static void testInvalidPageSize() {
        Integer invalidPageSize = -5;
        Exception error;
        
        Test.startTest();
        try {
            AccountOrdersController.setPageSize(invalidPageSize);
        } catch (AuraHandledException e) {
            error = e;
        }
        Test.stopTest();
    
        System.assertNotEquals(null, error, 'Expected an exception to be thrown for an invalid page size.');
    }
    
    
}
