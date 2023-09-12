Savepoint sp = Database.setSavepoint();
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

} catch (Exception e) {
    Database.rollback(sp);
    System.debug('EXCEPTION: ' + e.getMessage());
}