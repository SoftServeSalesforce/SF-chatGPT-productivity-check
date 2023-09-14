List<Product2> products = new List<Product2> {
    new Product2(Name = 'HP ZBook', IsActive = true),
    new Product2(Name = 'Mac Book Pro', IsActive = true),
    new Product2(Name = 'Dell Inspiron', IsActive = true),
    new Product2(Name = 'SFDC Apex Development', IsActive = true),
    new Product2(Name = 'LWC Development', IsActive = true)
};
insert products;

Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

List<PricebookEntry> pbEntries = new List<PricebookEntry>();

for(Product2 prod : products) {
    pbEntries.add(new PricebookEntry(
        Pricebook2Id = stdPb.Id, 
        Product2Id = prod.Id, 
        UnitPrice = 123, 
        IsActive = true));
}
insert pbEntries;

Account acc = new Account(Name = 'SoftServe Inc.');
insert acc;

Contract contract = new Contract(
    AccountId = acc.Id, 
    Status = 'Draft', 
    StartDate = Date.today(), 
    ContractTerm = 12);
insert contract;
contract.status = 'Activated';
update contract;

List<Order> orders = new List<Order>();
for(Integer i = 0; i < 400; i++) {
    orders.add(new Order(
        AccountId = acc.Id, 
        ContractId = contract.Id, 
        Status = 'Draft', 
        Pricebook2Id = stdPb.Id,
        EffectiveDate = Date.today()));
}
insert orders;

List<OrderItem> orderItems = new List<OrderItem>();
for(Order ord : orders) {
    for(PricebookEntry pbEntry : pbEntries) {
        orderItems.add(new OrderItem(
            OrderId = ord.Id, 
            PricebookEntryId = pbEntry.Id, 
            Quantity = 1, 
            UnitPrice = pbEntry.UnitPrice));
    }
}
insert orderItems;

for(Integer i = 0; i < 400; i++) {
    if (Math.mod(i, 4) == 0) {
        continue;
    } else if (Math.mod(i, 4) == 1) {
        orders[i].Status = 'Activated';
    } else if (Math.mod(i, 4) == 2) {
        orders[i].Status = 'Shipped';
    } else if (Math.mod(i, 4) == 3) {
        orders[i].Status = 'Delivered';
    }
}
update orders;

List<ContentVersion> invoicePdfs = new List<ContentVersion>();
List<ContentVersion> testPdfs = new List<ContentVersion>();
for (Integer i = 0; i < 25; i++) {
    invoicePdfs.add(new ContentVersion(
        Title = 'Invoice-' + i + '.pdf', 
        PathOnClient = 'Invoice-' + i + '.pdf', 
        VersionData = Blob.valueOf('Test Data'), 
        IsMajorVersion = true));
    testPdfs.add(new ContentVersion(
        Title = 'test-' + i + '.pdf', 
        PathOnClient = 'test-' + i + '.pdf', 
        VersionData = Blob.valueOf('Test Data'), 
        IsMajorVersion = true));
}
insert invoicePdfs;
insert testPdfs;

List<Order> draftOrders = [SELECT Id FROM Order WHERE Status = 'Draft'];
List<Order> activeOrders = [SELECT Id FROM Order WHERE Status = 'Activated'];
List<Order> shippedOrders = [SELECT Id FROM Order WHERE Status = 'Shipped'];
List<Order> deliveredOrders = [SELECT Id FROM Order WHERE Status = 'Delivered'];
List<ContentVersion> invoices = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'Invoice%'];
List<ContentVersion> tests = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'test%'];

List<ContentDocumentLink> links = new List<ContentDocumentLink>();
for (Integer i = 0; i < 25; i++) {
    links.add(new ContentDocumentLink(
        LinkedEntityId = draftOrders[i].Id,
        ContentDocumentId = invoices[i].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = activeOrders[i].Id,
        ContentDocumentId = invoices[i].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = shippedOrders[i].Id,
        ContentDocumentId = invoices[i].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = deliveredOrders[i].Id,
        ContentDocumentId = invoices[i].ContentDocumentId,
        ShareType = 'V'
    ));
}
for (Integer i = 25; i < 50; i++) {
    links.add(new ContentDocumentLink(
        LinkedEntityId = draftOrders[i].Id,
        ContentDocumentId = tests[i - 25].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = activeOrders[i].Id,
        ContentDocumentId = tests[i - 25].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = shippedOrders[i].Id,
        ContentDocumentId = tests[i - 25].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = deliveredOrders[i].Id,
        ContentDocumentId = tests[i - 25].ContentDocumentId,
        ShareType = 'V'
    ));
}
for (Integer i = 50; i < 75; i++) {
    links.add(new ContentDocumentLink(
        LinkedEntityId = draftOrders[i].Id,
        ContentDocumentId = invoices[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = activeOrders[i].Id,
        ContentDocumentId = invoices[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = shippedOrders[i].Id,
        ContentDocumentId = invoices[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = deliveredOrders[i].Id,
        ContentDocumentId = invoices[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = draftOrders[i].Id,
        ContentDocumentId = tests[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = activeOrders[i].Id,
        ContentDocumentId = tests[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = shippedOrders[i].Id,
        ContentDocumentId = tests[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
    links.add(new ContentDocumentLink(
        LinkedEntityId = deliveredOrders[i].Id,
        ContentDocumentId = tests[i - 50].ContentDocumentId,
        ShareType = 'V'
    ));
}
insert links;
