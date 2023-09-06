List<Product2> products = new List<Product2>();
products.add(new Product2(Name = 'HP ZBook', ProductCode = 'HPZ', IsActive = true));
products.add(new Product2(Name = 'Mac Book Pro', ProductCode = 'MBP', IsActive = true));
products.add(new Product2(Name = 'Dell Inspiron', ProductCode = 'DI', IsActive = true));
products.add(new Product2(Name = 'SFDC Apex Development', ProductCode = 'SFA', IsActive = true));
products.add(new Product2(Name = 'LWC Development', ProductCode = 'LWC', IsActive = true));
insert products;

List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
Id standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true].Id;
Decimal unitPrice = 100.00;
for (Product2 product : products) {
    pricebookEntries.add(new PricebookEntry(
        Pricebook2Id = standardPricebookId,
        Product2Id = product.Id,
        UnitPrice = unitPrice,
        IsActive = true
    ));
}
insert pricebookEntries;

Account account = new Account(Name='SoftServe Inc.');
insert account;

Contract contract = new Contract(
    AccountId = account.Id,
    StartDate = Date.today(),
    ContractTerm = 10,
    Status = 'Draft'
);
insert contract;

contract.Status = 'Activated';
update contract;

List<Order> orders = new List<Order>();
for(Integer i = 0; i < 400; i++) {
    Order order = new Order(
        AccountId = account.Id,
        ContractId = contract.Id,
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Pricebook2Id = standardPricebookId
    );
    orders.add(order);
}
insert orders;

List<OrderItem> orderItems = new List<OrderItem>();
for (Order order : orders) {
    for(PricebookEntry entry : pricebookEntries) {
        OrderItem item = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = entry.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        
        orderItems.add(item);
    }
}
insert orderItems;

for (Integer i = 0; i < 300; i++) {            
    if (i < 100) {
        orders[i].Status = 'Activated';
    }
    else if (i < 200) {
        orders[i].Status = 'Shipped';
    }
    else {
        orders[i].Status = 'Delivered';
    }
}
update orders;

List<ContentVersion> versions = new List<ContentVersion>();
for (Integer i = 0; i < 25; i++) {
    ContentVersion invoiceVersion = new ContentVersion(
        PathOnClient = 'Invoice-' + i + '.pdf',
        Title = 'Invoice-' + i + '.pdf',
        VersionData = Blob.toPdf('TestData')
    );
    ContentVersion testVersion = new ContentVersion(
        PathOnClient = 'test-' + i + '.pdf',
        Title = 'test-' + i + '.pdf',
        VersionData = Blob.toPdf('TestData')
    );

    versions.add(invoiceVersion);
    versions.add(testVersion);

}
insert versions;

List<ContentVersion> invoiceVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'Invoice%'];
List<ContentVersion> testVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'test%'];
List<Order> draftOrders = [SELECT Id, Status FROM Order WHERE Status = 'Draft'];
List<Order> activatedOrders = [SELECT Id, Status FROM Order WHERE Status = 'Activated'];
List<Order> shippedOrders = [SELECT Id, Status FROM Order WHERE Status = 'Shipped'];
List<Order> deliveredOrders = [SELECT Id, Status FROM Order WHERE Status = 'Delivered'];

List<ContentDocumentLink> contDocLinks = new List<ContentDocumentLink>();
for (Integer i = 0; i < 75; i++) {
    switch on Math.mod(i, 3) {
        when 1 {
            Id invoiceContDocId = invoiceVersions.get(Math.mod(i, 25)).ContentDocumentId;

            createContDocLinks(i, invoiceContDocId);
        }
        when 2 {
            Id testContDocId = testVersions.get(Math.mod(i, 25)).ContentDocumentId;

            createContDocLinks(i, testContDocId);
        }
        when else {
            Id invoiceContDocId = invoiceVersions.get(Math.mod(i, 25)).ContentDocumentId;
            Id testContDocId = testVersions.get(Math.mod(i, 25)).ContentDocumentId;

            createContDocLinks(i, invoiceContDocId);
            createContDocLinks(i, testContDocId);
        }
    }
}

ContentDocumentLink createDocLink(Id contentDocumentId, Id orderId) {
    ContentDocumentLink docLink = new ContentDocumentLink(
        ContentDocumentId = contentDocumentId,
        LinkedEntityId = orderId
    );

    return docLink;
}

void createContDocLinks(Integer index, Id contentDocumentId) {
    contDocLinks.add(createDocLink(contentDocumentId, draftOrders.get(index).Id));
    contDocLinks.add(createDocLink(contentDocumentId, activatedOrders.get(index).Id));
    contDocLinks.add(createDocLink(contentDocumentId, shippedOrders.get(index).Id));
    contDocLinks.add(createDocLink(contentDocumentId, deliveredOrders.get(index).Id));
}

insert contDocLinks;
