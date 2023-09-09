//Constants.
final List<String> PRODUCT_NAMES = new List<String> {
    'HP ZBook', 'Mac Book Pro', 'Dell Inspiron', 'SFDC Apex Development', 'LWC Development'
};
final Integer PRODUCTS_COUNT = PRODUCT_NAMES.size();
final String ACCOUNT_NAME = 'SoftServe, Inc.';
final String INVOICE_ATTACHMENT_NAME = 'Invoice.pdf';
final String NONINVOICE_ATTACHMENT_NAME = 'test.pdf';
final String ORDER_STATUS_DRAFT = 'Draft';
final String ORDER_STATUS_ACTIVATED = 'Activated';
final String ORDER_STATUS_SHIPPED = 'Shipped';
final String ORDER_STATUS_DELIVERED = 'Delivered';
final String CONTRACT_STATUS_DRAFT = 'Draft';
final String CONTRACT_STATUS_ACTIVATED = 'Activated';
final Integer ORDERS_TO_SEED = 400;
final Id DEFAULT_PRICEBOOK_ID = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
final Integer UNIT_PRICE = 5000;
final Integer QUANTITY = 5000;
final Date TODAY = Date.today();
final Datetime NOW = Datetime.now();
final Integer CONTRACT_TERM_DEFAULT = 12;
final Id USER_ID = UserInfo.getUserId();
final String CONTENT_LOCATION_SALESFORCE = 'S';
final String CONTENT_ORIGIN_CHATTER = 'H';
final Blob ATTACHMENT_BODY = Blob.valueOf('Test file, please ignore.');
final String SHARE_TYPE_INFERRED = 'I';
final String VISIBILITY_ALL_USERS = 'AllUsers';
//Ensure that enabler settings exists.
upsert FeaturesEnabler__c.getInstance();
//Seed account.
Account acc = new Account(
    Name = ACCOUNT_NAME
);
insert acc;
//Seed products.
List<Product2> products = new List<Product2>();
for (String productName : PRODUCT_NAMES) {
    products.add(new Product2(
        Name = productName,
        IsActive = true
    ));
}
insert products;
//Seed price book entries.
List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
for (Product2 product : products) {
    pricebookEntries.add(new PricebookEntry(
        IsActive = true,
        Pricebook2Id = DEFAULT_PRICEBOOK_ID,
        Product2Id = product.Id,
        UnitPrice = UNIT_PRICE
    ));
}
insert pricebookEntries;
//Seed contract.
Contract contrct = new Contract(
    AccountId = acc.Id,
    Status = CONTRACT_STATUS_DRAFT,
    ContractTerm = CONTRACT_TERM_DEFAULT,
    StartDate = TODAY
);
insert contrct;
contrct.Status = CONTRACT_STATUS_ACTIVATED;
update contrct;
//Seed orders.
List<Order> orders = new List<Order>();
for (Integer i = 0; i < ORDERS_TO_SEED; i++) {
    orders.add(new Order(
        ContractId = contrct.Id,
        AccountId = acc.Id,
        EffectiveDate = TODAY,
        Status = ORDER_STATUS_DRAFT,
        Pricebook2Id = DEFAULT_PRICEBOOK_ID,
        LastStatusChanged__c = Datetime.now()
    ));
}
insert orders;
//Seed Order Items.
List<OrderItem> orderItems = new List<OrderItem>();
for (Order ordr : orders) {
    for (Product2 product : products) {
        orderItems.add(new OrderItem(
            OrderId = ordr.Id,
            Product2Id = product.Id,
            Quantity = QUANTITY,
            UnitPrice = UNIT_PRICE,
            PricebookEntryId = pricebookEntries[Math.abs((Math.random() * PRODUCTS_COUNT).intValue())].Id //Link to random Pricebook Entry
        ));
    }
}
insert orderItems;
//Progress Orders with validations bypassed.
FeaturesEnabler__c enabler = FeaturesEnabler__c.getInstance();
Boolean oldValidateActivation = enabler.Order_ValidateActivation__c;
Boolean oldValidateShipment = enabler.Order_ValidateShipment__c;
enabler.Order_ValidateActivation__c = false;
enabler.Order_ValidateShipment__c = false;
update enabler;
for (Integer i = 100; i < ORDERS_TO_SEED; i++) {
    if (i >= 100 && i < 200) {
        orders[i].Status = ORDER_STATUS_ACTIVATED;
    }
    if (i >= 200 && i < 300) {
        orders[i].Status = ORDER_STATUS_SHIPPED;
    }
    if (i >= 300) {
        orders[i].Status = ORDER_STATUS_DELIVERED;
    }
    orders[i].LastStatusChanged__c = Datetime.now();
}
update orders;
enabler.Order_ValidateActivation__c = oldValidateActivation;
enabler.Order_ValidateShipment__c = oldValidateShipment;
update enabler;
//Seed attachments.
ContentVersion invoice = buildAttachment(INVOICE_ATTACHMENT_NAME);
ContentVersion nonInvoice = buildAttachment(NONINVOICE_ATTACHMENT_NAME);
insert new List<ContentVersion> { invoice, nonInvoice };
invoice = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :invoice.Id LIMIT 1];
nonInvoice = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :nonInvoice.Id LIMIT 1];
//Restore features state.
//Link attachments.
List<ContentDocumentLink> attachmentToOrder = new List<ContentDocumentLink>();
for (Integer i = 0; i < ORDERS_TO_SEED; i++) {
    //Figure out Ids of Orders to have related Invoices.
    if (
        (i >= 25 && i < 75) //Link 50 invoices to 50 Orders in "Draft" state.
        || (i >= 125 && i < 175) //Link 50 invoices to 50 Orders in "Activated" state.
        || (i >= 225 && i < 275) //Link 50 invoices to 50 Orders in "Shipped" state.
        || (i >= 325 && i < 375) //Link 50 invoices to 50 Orders in "Delivered" state.
    ) {
        attachmentToOrder.add(buildOrderToAttachmentLink(orders[i].Id, invoice.ContentDocumentId));
    }
    //Figure out Ids of Orders to have related non-Invoices
    //Overlap with above so 25 Orders in each status have both attachment types.
    if (
        (i >= 50 && i < 100) //Link 50 non-invoices to 50 Orders in "Draft" state.
        || (i >= 150 && i < 200) //Link 50 non-invoices to 50 Orders in "Activated" state.
        || (i >= 250 && i < 300) //Link 50 non-invoices to 50 Orders in "Shipped" state.
        || (i >= 350 && i < 400) //Link 50 non-invoices to 50 Orders in "Delivered" state.
    ) {
        attachmentToOrder.add(buildOrderToAttachmentLink(orders[i].Id, nonInvoice.ContentDocumentId));
    }
}
insert attachmentToOrder;
//Helper methods.
ContentVersion buildAttachment(String name) {
    return new ContentVersion(
        ContentLocation = CONTENT_LOCATION_SALESFORCE,
        Origin = CONTENT_ORIGIN_CHATTER,
        OwnerId = USER_ID,
        VersionData = ATTACHMENT_BODY,
        PathOnClient = name,
        Title = name
    );
}
ContentDocumentLink buildOrderToAttachmentLink(Id orderId, Id contentDocumentId) {
    return new ContentDocumentLink(
        ContentDocumentId = contentDocumentId,
        LinkedEntityId = orderId,
        ShareType = SHARE_TYPE_INFERRED,
        Visibility = VISIBILITY_ALL_USERS
    );
}