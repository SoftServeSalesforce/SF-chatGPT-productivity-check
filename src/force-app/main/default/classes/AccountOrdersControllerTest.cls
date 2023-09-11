@IsTest
public class AccountOrdersControllerTest {

    public static String NO_ORDERS_PASSED = 'No orders Passed';


    @testSetup
    static void setupData() {

        //Custom settings
        PageSizeCS__c pageSizeCS = new PageSizeCS__c();    
		pageSizeCS.Name = 'page size '+userinfo.getuserid();
        pageSizeCS.page_size__c = 10;
		pageSizeCS.SetupOwnerId = userinfo.getuserid();
		
        insert pageSizeCS;

        //  Account
        Account accountTest = new Account();
            accountTest.Name='Account Test AI';
            accountTest.AccountNumber='12345';
        database.insert (accountTest);        

        //  Product 1
        Product2 product1 = new Product2(
            Name = 'Product 1',
            ProductCode = 'P1',
            IsActive = true
        );
       

        //  Product 2
        Product2 product2 = new Product2(
            Name = 'Product 2',
            ProductCode = 'P2',
            IsActive = true
        );
       

        List<Product2> products = new List<Product2>();
        products.add(product1);
        products.add(product2);
        insert products;

        // standard Pricebook Entries
        Id standardPricebook = Test.getStandardPricebookId();
        
        List<PricebookEntry> stdPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            stdPricebookEntries.add(new PricebookEntry(
                Product2Id = prod.Id,
                Pricebook2Id = standardPricebook,
                UnitPrice = 75.00,
                IsActive = true
            ));
        }
        insert stdPricebookEntries;

         // Pricebook
         Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Pricebook',
            Description = 'This is a custom Pricebook',
            IsActive = true
        );
        insert customPricebook;

        // Pricebook Entries
        List<PricebookEntry> customPricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            customPricebookEntries.add(new PricebookEntry(
                Product2Id = prod.Id,
                Pricebook2Id = customPricebook.Id,
                UnitPrice = 75.00,
                IsActive = true
            ));
        }
        insert customPricebookEntries;
      

        // Create Contract
        Contract testContract = new Contract(
            AccountId = accountTest.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            Pricebook2Id = customPricebook.Id,
            Status = 'Draft'
        );
        insert testContract;

        testContract.Status = 'Activated';
        update testContract;

       
        List<Order> testOrders = new List<Order>();
        for (Integer i = 0; i < 4; i++) {
            testOrders.add(new Order(
                AccountId = accountTest.Id,
                Status = 'Draft',
                Pricebook2Id = customPricebook.Id,
                ContractId = testContract.Id,
                EffectiveDate = System.today()
                
            ));
        }
        insert testOrders;



        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : testOrders) {
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


        testOrders[0].Status = 'Activated';
        testOrders[1].Status = 'Activated';

        update testOrders;

        ContentVersion cv = new ContentVersion();
        cv.Description  = 'Invoice';
        cv.PathOnClient ='Invoice.txt';
        cv.Title = 'Invoice';
        cv.versiondata=Blob.valueOf('test file body');
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = testOrders[1].Id; 
        cdl.ShareType = 'V';
        insert cdl;

        
       
    }


    @isTest
    static void testActivateOrderSuccess() {
        Order testOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft' LIMIT 1];
        
        Test.startTest();
        AccountOrdersController.activateOrder(testOrder.Id);
        Test.stopTest();
              

        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id LIMIT 1];
        Assert.areEqual('Activated', updatedOrder.Status, 'OK order Activated');
    }

    @isTest
    static void testActivateOrderFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.activateOrder(null);
            System.assert(false, 'No orders to Activate where selected');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');
    }
    
    @isTest
    static void testMarkOrderAsShippedSuccess() {
        Order testOrder = [SELECT Id FROM Order WHERE Status = 'Activated' LIMIT 1];
        Test.startTest();
        AccountOrdersController.markOrderAsShipped(testOrder.Id);
        Test.stopTest();
            

        Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id LIMIT 1];
        Assert.areEqual('Shipped', updatedOrder.Status, 'Order Shipped');
    }

    @isTest
    static void testMarkOrderAsShippedFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.markOrderAsShipped(null);
            System.assert(false, 'No orders to Ship where selected');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');
    }



    @isTest
    static void testactivateSelectedOrdersSuccess() {
        List<Order> testOrders = [SELECT Id FROM Order WHERE Status = 'Draft'];
        List<Id> orderIds = new List<Id>();
        for(Order ord : testOrders) {
            orderIds.add(ord.Id);
        }

        Test.startTest();
            AccountOrdersController.activateSelectedOrders(orderIds);                 
        Test.stopTest();  
        List<Order> updatedOrders = [SELECT Id, Status FROM Order WHERE Id IN: orderIds];
        for(Order order: updatedOrders) {
            Assert.areEqual('Activated', order.Status, 'OK orders Activated');
        }         
    }


    @isTest
    static void testactivateSelectedOrdersFailure() {
        Exception e;
        List<Id> emptyOrderIds= new List<Id>();
        Test.startTest();
        try {
            AccountOrdersController.activateSelectedOrders(emptyOrderIds);
            System.assert(false, NO_ORDERS_PASSED);
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');

    }

    @isTest
    static void testMarkOrdersAsShippedSuccess() {
        List<Order> testOrders = [SELECT Id FROM Order WHERE Status = 'Activated'];
        List<Id> orderIds = new List<Id>();
        for(Order ord : testOrders) {
            orderIds.add(ord.Id);
        }
        
        Test.startTest();
        AccountOrdersController.shipSelectedOrders(orderIds);
        Test.stopTest();
        
        List<Order> updatedOrders = [SELECT Id, Status FROM Order WHERE Id IN :orderIds];
        for(Order order: updatedOrders) {
            Assert.areEqual('Shipped', order.Status, 'Orders Shipped');
        }       
    }


    @isTest
    static void testMarkOrdersAsShippedFailure() {
        List<Id> emptyOrderIds= new List<Id>();
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.shipSelectedOrders(emptyOrderIds);
            System.assert(false, NO_ORDERS_PASSED);
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');

    }

    @isTest
    static void testgetPageSizeUserSuccess() {
        PageSizeCS__c pageSizeCS = [SELECT page_size__c,SetupOwnerId FROM PageSizeCS__c WHERE SetupOwnerId = :userinfo.getuserid() LIMIT 1];
        Test.startTest();
        AccountOrdersController.getPageSizeUser();
        Test.stopTest();

        
        Assert.areEqual(10, pageSizeCS.page_size__c, '10 is page size for current user');
      

    }

     @isTest
    static void getOrdersSuccess() {
        Account accountTest = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
            List<AccountOrdersController.OrderDTO> result = AccountOrdersController.getOrders(accountTest.Id);
        Test.stopTest();        
        Assert.isNotNull(result, 'Result received');
        List<Order> orders = [SELECT ID FROM Order WHERE accountId =: accountTest.Id];
        Assert.areEqual(orders.size(), result.size(), 'Orders retrieved are' + orders.size());
    }

    @isTest
    static void getOrdersFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.getOrders(null);
            System.assert(false, NO_ORDERS_PASSED);
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');

    }

    @isTest
    static void calculateTimeSinceLastStatusChangeFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.calculateTimeSinceLastStatusChange(null);
            System.assert(false, 'No Last Status Date passed');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');

    }


    @isTest
    static void updateOrderStatusFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.updateOrderStatus(null,'');
            System.assert(false, 'Empty Id passed');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');
    }

    @isTest
    static void testsavePageSizeUSerFailure() {
        Exception e;
        Test.startTest();
        try {
            AccountOrdersController.setPageSizeUSer(null);
            System.assert(false, 'Empty page size  passed');
        } catch (Exception ex) {
            e = ex;
        }
        Test.stopTest();
        Assert.isNotNull(e, 'Exception');

    }

    @isTest
    static void testsavePageSizeUSerSuccess() {

        PageSizeCS__c pageSizeCS = [SELECT page_size__c,SetupOwnerId FROM PageSizeCS__c WHERE SetupOwnerId = :userinfo.getuserid() LIMIT 1];
        Test.startTest();
        AccountOrdersController.setPageSizeUSer(10);
        Test.stopTest();

        
        Assert.areEqual(10, pageSizeCS.page_size__c, '10 is page size for current user');

    }


}
