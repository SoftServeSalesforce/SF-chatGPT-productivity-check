Savepoint sp = Database.setSavepoint(); // Set a savepoint
try {
    // Create Products
    List<Product2> products = new List<Product2>{
        new Product2(Name = 'HP ZBook', IsActive = true),
        new Product2(Name = 'Mac Book Pro', IsActive = true),
        new Product2(Name = 'Dell Inspiron', IsActive = true),
        new Product2(Name = 'SFDC Apex Development', IsActive = true),
        new Product2(Name = 'LWC Development', IsActive = true)
    };
    insert products;

    // Create Pricebook Entries for Standard Pricebook
    Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    Id stdPbId = stdPb.Id;

    List<PricebookEntry> pbEntries = new List<PricebookEntry>();
    for (Product2 prod : products) {
        pbEntries.add(new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prod.Id, UnitPrice = Math.random() * 1000, IsActive = true));
    }
    insert pbEntries;

    // Create Account
    Account acc = new Account(Name = 'SoftServe Inc.');
    insert acc;

    // Create Activated Contract
    Contract contract = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
    insert contract;

    // Create Orders with 'Draft' status
    List<Order> orders = new List<Order>();
    for (Integer i = 0; i < 400; i++) {
        orders.add(new Order(AccountId = acc.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = stdPbId, ContractId = contract.Id));
    }
    insert orders;

    // Create Order Line Items
    List<OrderItem> orderItems = new List<OrderItem>();
    for (Order ord : orders) {
        for (PricebookEntry pbe : pbEntries) {
            orderItems.add(new OrderItem(OrderId = ord.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = pbe.UnitPrice));
        }
    }
    insert orderItems;

    // Create Content Files
    List<ContentVersion> allCVs = new List<ContentVersion>();
    for (Integer i = 0; i < 400; i++) {
        Integer modResult = Math.mod(i, 4);
        if (modResult == 1 || modResult == 3) {
            allCVs.add(new ContentVersion(Title = 'Invoice-' + i + '.pdf', PathOnClient = 'Invoice-' + i + '.pdf', VersionData = Blob.valueOf('Test Content')));
        }
        if (modResult == 2 || modResult == 3) {
            allCVs.add(new ContentVersion(Title = 'test-' + i + '.pdf', PathOnClient = 'test-' + i + '.pdf', VersionData = Blob.valueOf('Test Content')));
        }
    }
    insert allCVs;

    // Create ContentDocumentLinks
    List<ContentDocumentLink> allCDLs = new List<ContentDocumentLink>();
    Map<String, Id> titleToContentDocumentId = new Map<String, Id>();
    for (ContentDocument cd : [SELECT Id, Title FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :allCVs)]) {
        titleToContentDocumentId.put(cd.Title, cd.Id);
    }

    for (Integer i = 0; i < 400; i++) {
        String invoiceTitle = 'Invoice-' + i + '.pdf';
        String testTitle = 'test-' + i + '.pdf';
        if (titleToContentDocumentId.containsKey(invoiceTitle)) {
            allCDLs.add(new ContentDocumentLink(ContentDocumentId = titleToContentDocumentId.get(invoiceTitle), LinkedEntityId = orders[i].Id, ShareType = 'V'));
        }
        if (titleToContentDocumentId.containsKey(testTitle)) {
            allCDLs.add(new ContentDocumentLink(ContentDocumentId = titleToContentDocumentId.get(testTitle), LinkedEntityId = orders[i].Id, ShareType = 'V'));
        }
    }
    insert allCDLs;

    // Update the status of orders as needed
    for (Integer i = 0; i < 400; i++) {
        if (i >= 100 && i < 200) orders[i].Status = 'Activated';
        else if (i >= 200 && i < 300) orders[i].Status = 'Shipped';
        else if (i >= 300) orders[i].Status = 'Delivered';
    }
    update orders;
} catch (Exception e) {
    Database.rollback(sp); // Rollback to the savepoint on any exception
    System.debug('EXCEPTION: ' + e.getMessage());
}