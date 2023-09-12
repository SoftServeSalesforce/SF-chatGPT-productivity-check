Savepoint sp = Database.setSavepoint();
try {
    // Fetch the Contract associated with 'SoftServe Inc.' Account
    Contract contract = [SELECT Id, Status FROM Contract WHERE Account.Name = 'SoftServe Inc.' LIMIT 1];

    // Activate the contract
    if (contract.Status == 'Draft') {
        contract.Status = 'Activated';
        update contract;
    }

    // Fetch all 400 Orders created in the previous scripts
    List<Order> orders = [SELECT Id, Status FROM Order WHERE Account.Name = 'SoftServe Inc.'];

    // Update the status of orders as needed
    for (Integer i = 0; i < 400; i++) {
        if (i >= 100 && i < 200) orders[i].Status = 'Activated';
        else if (i >= 200 && i < 300) orders[i].Status = 'Shipped';
        else if (i >= 300) orders[i].Status = 'Delivered';
    }
    update orders;

} catch (Exception e) {
    Database.rollback(sp);
    System.debug('EXCEPTION: ' + e.getMessage());
}
