Savepoint sp = Database.setSavepoint();
try {
    // Fetch the Account, Contract, and PricebookEntry IDs from the previous script
    Account acc = [SELECT Id FROM Account WHERE Name = 'SoftServe Inc.' LIMIT 1];
    Contract contract = [SELECT Id FROM Contract WHERE AccountId = :acc.Id LIMIT 1];
    List<PricebookEntry> pbEntries = [SELECT Id, UnitPrice, Pricebook2Id FROM PricebookEntry WHERE Product2.Name IN ('HP ZBook', 'Mac Book Pro', 'Dell Inspiron', 'SFDC Apex Development', 'LWC Development')];

    // Create Orders with 'Draft' status
    List<Order> orders = new List<Order>();
    for (Integer i = 0; i < 400; i++) {
        orders.add(new Order(AccountId = acc.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = pbEntries[0].Pricebook2Id, ContractId = contract.Id));
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

} catch (Exception e) {
    Database.rollback(sp);
    System.debug('EXCEPTION: ' + e.getMessage());
}
