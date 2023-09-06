Integer amountOfOrders = 400;
Pricebook2 pb = [SELECT Id from Pricebook2 WHERE IsStandard = true limit 1];
Account dataAccount = new Account();
dataAccount.Name = 'SoftServe Inc.';
insert dataAccount;

Contract contr = new Contract();
contr.AccountId = dataAccount.Id;
contr.Status = 'Draft';
contr.StartDate = Date.today().addDays(-1);
contr.ContractTerm = 1;
insert contr;
contr.Status = 'Activated';
update contr;

List<String> productNames = new List<String> {'HP ZBook', 'Mac Book Pro', 'Dell Inspiron', 'SFDC Apex Development', 'LWC Development'};
List<Product2> products = new List<Product2>();

for (String productName : productNames) {
    Product2 product = new Product2();
    product.Name = productName;
    product.Family = 'GEN';
    products.add(product);
}
insert products;
List<PricebookEntry> entries = new List<PricebookEntry>();
for (Product2 product: products) {
    PricebookEntry pe = new PricebookEntry();
    pe.Pricebook2Id = pb.Id;
    pe.Product2Id = product.Id;
    pe.UnitPrice = 155;
    pe.IsActive = true;
    entries.add(pe);
}
insert entries;
List<Order> orders = new List<Order>();
for(Integer i = 0; i < amountOfOrders; i++) {
    Order ord = new Order();
    ord.AccountId = dataAccount.Id;
    ord.ContractId = contr.Id;
    ord.EffectiveDate = Date.today().addDays(-1);
    ord.Status = 'Draft';
    ord.Pricebook2Id = pb.Id;
    orders.add(ord);
}
insert orders;

List<OrderItem> orderItems = new List<OrderItem>();
// 2000 order items to be created
for (Order ord : orders) { // Cycle for 400
    for(PricebookEntry entry: entries) { // Cycle for 5 times
        OrderItem item = new OrderItem();
        item.OrderId = ord.Id;
        item.PricebookEntryId = entry.Id;
        item.Quantity = 1;
        item.UnitPrice = 155;
        orderItems.add(item);
    }
}
insert orderItems;

Integer orderDistributionAmount = 100;
List<Order> draftOrders = new List<Order>();
List<Order> activatedOrders = new List<Order>();
List<Order> shippedOrders = new List<Order>();
List<Order> deliveredOrders = new List<Order>();
for(Integer i = 0; i < orders.size(); i++) {
    Order current = orders.get(i);
    switch on Math.mod(i, 4) {
        when 1 {
            current.Status = 'Activated';
            activatedOrders.add(current);
        }
        when 2 {
            current.Status = 'Shipped';
            shippedOrders.add(current);
        }
        when 3 {
            current.Status = 'Delivered';
            deliveredOrders.add(current);
        }
        when else {
            draftOrders.add(current);
        }
    }
}
update orders;
Assert.areEqual(orderDistributionAmount, draftOrders.size(), 'Unexpected amount of draft orders');
Assert.areEqual(orderDistributionAmount, activatedOrders.size(), 'Unexpected activated of draft orders');
Assert.areEqual(orderDistributionAmount, shippedOrders.size(), 'Unexpected shipped of draft orders');
Assert.areEqual(orderDistributionAmount, deliveredOrders.size(), 'Unexpected delivered of draft orders');

List<ContentVersion> versions = new List<ContentVersion>();
List<ContentVersion> invoiceVersions = new List<ContentVersion>();
for (Integer i = 1; i <= 25; i++) {
    invoiceVersions.add(createContentVersion('Invoice-' + i));
}
List<ContentVersion> testVersions = new List<ContentVersion>();
for (Integer i = 1; i <= 25; i++) {
    testVersions.add(createContentVersion('test-' + i));
}
versions.addAll(invoiceVersions);
versions.addAll(testVersions);
List<ContentDocumentLink> links = new List<ContentDocumentLink>();


insert versions;

Set<Id> invoiceIds = (new Map<Id, ContentVersion>(invoiceVersions)).keySet();
Set<Id> testIds = (new Map<Id, ContentVersion>(testVersions)).keySet();
invoiceVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: invoiceIds];
testVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: testIds];

// Skip 25 without any
for (Integer i = 0; i < orderDistributionAmount-25; i++) {
    switch on Math.mod(i, 3) {
        // 25 With invoice
        when 1 {
            Id invoiceDocId = invoiceVersions.get(Math.mod(i, 25)).ContentDocumentId;
            createLinkPerOrderType(i, invoiceDocId);
        }
        // 25 With test
        when 2 {
            Id testDocID = testVersions.get(Math.mod(i, 25)).ContentDocumentId;
            createLinkPerOrderType(i, testDocId);
        }
        // 25 With both
        when else {
            Id invoiceDocId = invoiceVersions.get(Math.mod(i, 25)).ContentDocumentId;
            Id testDocID = testVersions.get(Math.mod(i, 25)).ContentDocumentId;
            createLinkPerOrderType(i, invoiceDocId);
            createLinkPerOrderType(i, testDocId);
        }
    }
}

insert links;

ContentDocumentLink createLink(Id contentDocumentId, Id orderId) {
    ContentDocumentLink link = new ContentDocumentLink();
    link.ContentDocumentId = contentDocumentId;
    link.LinkedEntityId = orderId;
    link.ShareType = 'V';
    return link;
}

ContentVersion createContentVersion(String name) {
    ContentVersion version = new ContentVersion();
    version.ContentLocation = 'S';
    version.PathOnClient = name + '.pdf';
    version.Title = name;
    version.VersionData = Blob.toPdf(name + ' content');
    return version;
}

void createLinkPerOrderType(Integer index, Id contentDocumentId) {
    links.add(createLink(contentDocumentId, draftOrders.get(index).Id));
    links.add(createLink(contentDocumentId, activatedOrders.get(index).Id));
    links.add(createLink(contentDocumentId, shippedOrders.get(index).Id));
    links.add(createLink(contentDocumentId, deliveredOrders.get(index).Id));
}