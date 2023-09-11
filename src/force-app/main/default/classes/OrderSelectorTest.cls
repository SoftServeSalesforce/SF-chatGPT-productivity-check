@isTest
private class OrderSelectorTest {

    @isTest static void testGetOrdersByAccountId() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Order testOrder = new Order(AccountId = testAcc.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert testOrder;

        ContentVersion cv = new ContentVersion(
            Title = 'invoice_test',
            PathOnClient = 'invoice_test.txt',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT Id FROM ContentDocument WHERE Title = 'invoice_test' LIMIT 1].Id,
            LinkedEntityId = testOrder.Id,
            ShareType = 'V'
        );
        insert cdl;

        OrderSelector selector = new OrderSelector();
        List<Order> orders = selector.getOrdersByAccountId(testAcc.Id);

        System.assertEquals(1, orders.size());
        System.assertEquals(1, orders[0].ContentDocumentLinks.size());
    }

    @isTest static void testGetOrdersByIds() {
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Order testOrder1 = new Order(AccountId = testAcc.Id, Status = 'Draft', EffectiveDate = Date.today());
        Order testOrder2 = new Order(AccountId = testAcc.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert new List<Order>{testOrder1, testOrder2};

        ContentVersion cv1 = new ContentVersion(
            Title = 'invoice_test1',
            PathOnClient = 'invoice_test1.txt',
            VersionData = Blob.valueOf('Test Content 1')
        );
        insert cv1;

        ContentDocumentLink cdl1 = new ContentDocumentLink(
            ContentDocumentId = [SELECT Id FROM ContentDocument WHERE Title = 'invoice_test1' LIMIT 1].Id,
            LinkedEntityId = testOrder1.Id,
            ShareType = 'V'
        );
        insert cdl1;

        OrderSelector selector = new OrderSelector();
        List<Order> orders = selector.getOrdersByIds(new Set<Id>{testOrder1.Id, testOrder2.Id});

        System.assertEquals(2, orders.size());
        System.assertEquals(1, orders[0].ContentDocumentLinks.size());
    }
}
