@IsTest
public with sharing class AccountOrdersControllerTest {

    private static final Integer RECORDS_AMOUNT = 10;
    private static final String CONTRACT_ACTIVATED_STATUS = 'Activated';

    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount('Test');
        Contract contr = TestDataFactory.createContract(acc.Id);
        List<Order> orders = TestDataFactory.createOrders(acc.Id, contr.Id, RECORDS_AMOUNT);
        Product2 product = TestDataFactory.createProduct('Test');
        PricebookEntry pe = TestDataFactory.createPricebookEntry(product.Id);
        TestDataFactory.createOrderItems(orders, pe.Id);
        activateContract(contr);
    }

    @IsTest
    static void testGetOrdersExceptionOnNullAccountId() {
        Test.startTest();
        Boolean isExceptionFired = false;
        try {
            AccountOrdersController.getOrders(null, RECORDS_AMOUNT, 0);
        } catch (AuraHandledException ex) {
            isExceptionFired = true;
        }
        Assert.isTrue(isExceptionFired, 'Should fire exception on null AccountId');
        Test.stopTest();
    }

    @IsTest
    static void testGetOrdersExceptionOnInvalidRecordsAmount() {
        Account acct = fetchAccount();
        Test.startTest();
        Boolean isExceptionFired = false;
        try {
            AccountOrdersController.getOrders(acct.Id, null, 0);
        } catch (AuraHandledException ex) {
            isExceptionFired = true;
        }
        Assert.isTrue(isExceptionFired, 'Should fire exception on invalid records amount');
        Test.stopTest();
    }

    @IsTest
    static void testGetOrdersExceptionOnInvalidPage() {
        Account acct = fetchAccount();
        Test.startTest();
        Boolean isExceptionFired = false;
        try {
            AccountOrdersController.getOrders(acct.Id, RECORDS_AMOUNT, null);
        } catch (AuraHandledException ex) {
            isExceptionFired = true;
        }
        Assert.isTrue(isExceptionFired, 'Should fire exception on invalid page');
        Test.stopTest();
    }

    @IsTest
    static void testGetOrdersReturnsDto() {
        Account acct = fetchAccount();
        Test.startTest();
        List<AccountOrdersController.OrderDTO> dtos = AccountOrdersController.getOrders(acct.Id, RECORDS_AMOUNT, 0);
        Assert.areEqual(RECORDS_AMOUNT, dtos.size(), 'Unexpected amount of DTOs returned');
        Test.stopTest();
    }

    @IsTest
    static void testActivateOrdersReturnsSuccess() {
        List<Id> orderIds = getSObjectIds(fetchOrders());
        Test.startTest();
        Map<String, Object> response = AccountOrdersController.activateOrders(orderIds);
        List<Order> testOrders = fetchOrdersWithStatus(AccountOrdersController.ORDER_STATUS_ACTIVATED);
        Assert.areEqual(RECORDS_AMOUNT, testOrders.size(), 'Unexpected amount of activated orders');
        Assert.areEqual(AccountOrdersController.STATUS_OK, 
            (String) response.get('status'), 
            'Activate orders should return success response');
        Test.stopTest();
    }

    @IsTest
    static void testActivateOrdersReturnsError() {
        List<Order> orders = fetchOrders();
        List<Id> orderIds = getSObjectIds(orders);
        updateOrdersStatus(orders, AccountOrdersController.ORDER_STATUS_SHIPPED);

        Test.startTest();
        Map<String, Object> response = AccountOrdersController.activateOrders(orderIds);
        Assert.areEqual(AccountOrdersController.STATUS_ERROR, 
            (String) response.get('status'), 
            'Activate orders should return error status response');
        String errorMessage = (String) response.get('errorMessage');
        Assert.isTrue(errorMessage.contains(AccountOrdersController.ERROR_ORDER_INVALID_OPERATION), 
            'Activate orders should return invalid operation error');

        Test.stopTest();
    }

    @IsTest
    static void testMarkOrdersAsShippedReturnsSuccess() {
        List<Order> orders = fetchOrders();
        List<Id> orderIds = getSObjectIds(orders);
        updateOrdersStatus(orders, AccountOrdersController.ORDER_STATUS_ACTIVATED);
        Test.startTest();
        Map<String, Object> response = AccountOrdersController.markOrdersAsShipped(orderIds);
        List<Order> testOrders = fetchOrdersWithStatus(AccountOrdersController.ORDER_STATUS_SHIPPED);
        Assert.areEqual(RECORDS_AMOUNT, testOrders.size(), 'Unexpected amount of shipped orders');
        Assert.areEqual(AccountOrdersController.STATUS_OK, 
            (String) response.get('status'), 
            'Mark orders as shipped should return success response');
       
        Test.stopTest();
    }

    @IsTest
    static void testMarkOrdersAsShippedReturnsError() {
        List<Order> orders = fetchOrders();
        List<Id> orderIds = getSObjectIds(orders);
        updateOrdersStatus(orders, AccountOrdersController.ORDER_STATUS_SHIPPED);

        Test.startTest();
        Map<String, Object> response = AccountOrdersController.markOrdersAsShipped(orderIds);
        Assert.areEqual(AccountOrdersController.STATUS_ERROR, 
            (String) response.get('status'), 
            'Mark orders as shipped should return error status in response');
        String errorMessage = (String) response.get('errorMessage');
        Assert.isTrue(errorMessage.contains(AccountOrdersController.ERROR_ORDER_INVALID_OPERATION),
            'Mark orders as shipped expected invalid operation error');
        Test.stopTest();
    }

    @IsTest
    static void testGetAmountOfRecordsReturnsDto() {
        Test.startTest();
        AccountOrdersController.PageSettingsDTO settings = AccountOrdersController.getAmountOfRecords();
        Assert.areEqual(AccountOrdersController.DEFAULT_RECORDS_AMOUNT_ON_PAGE, 
            settings.amountOfRecordsOnPage, 
            'Should return default amount of records');
        Test.stopTest();
    }

    @IsTest
    static void testSavePageSettingsSuccess() {
        Test.startTest();
        Integer testAmountRecordsOnPage = 5;
        AccountOrdersController.savePageSettings(testAmountRecordsOnPage);
        PaginationSettings__c settings = fetchPaginationSettings();
        Assert.areEqual(testAmountRecordsOnPage, 
            settings.RecordsAmountOnPage__c, 
            'Unexpected value for page settings');
        Test.stopTest();
    }
    
    @IsTest
    static void testSavedPageSettingsReturned() {
        Test.startTest();
        Integer testAmountRecordsOnPage = 5;
        AccountOrdersController.savePageSettings(testAmountRecordsOnPage);
        AccountOrdersController.PageSettingsDTO settings = AccountOrdersController.getAmountOfRecords();
        Assert.areEqual(testAmountRecordsOnPage,
            settings.amountOfRecordsOnPage, 
            'DTO Should return updated value');
        Test.stopTest();
    }

    @IsTest
    static void testSavePageSettingsException() {
        Test.startTest();
        Integer testAmountRecordsOnPage = 0;
        Boolean isExceptionFired = false;
        try {
            AccountOrdersController.savePageSettings(testAmountRecordsOnPage);
        } catch(Exception e) {
            isExceptionFired = true;
        }
        Assert.isTrue(isExceptionFired, 'Expected error to be thrown');
        Test.stopTest();
    }

    @IsTest
    static void testValidateAndUpdateOrdersByStatusException1() {
        Boolean isExceptionFired = false;
        Test.startTest();
        List<Id> orderIds = new List<Id>();
        AccountOrdersController.validateAndUpdateOrdersByStatus(null, 
            AccountOrdersController.ORDER_STATUS_DRAFT, 
            AccountOrdersController.ORDER_STATUS_ACTIVATED
        );
        Test.stopTest();
    }

    @IsTest
    static void testValidateAndUpdateOrdersByStatusException() {
        Boolean isExceptionFired = false;
        Test.startTest();
        List<Id> orderIds = new List<Id>();
        try {
            AccountOrdersController.validateAndUpdateOrdersByStatus(null, 
                AccountOrdersController.ORDER_STATUS_DRAFT, 
                AccountOrdersController.ORDER_STATUS_ACTIVATED
            );
        } catch (Exception e) {
            Assert.isInstanceOfType(e, OrderInvalidOperationException.class, 'Unexpected exception type');
            isExceptionFired = true;
        }
        Assert.isTrue(isExceptionFired, 'Should throw exception on empty ids list');
        Test.stopTest();
    }

    @IsTest
    static void testValidateAndUpdateOrdersByStatusSuccess() {
        Test.startTest();
        List<Id> orderIds = getSObjectIds(fetchOrders());
        AccountOrdersController.validateAndUpdateOrdersByStatus(orderIds, 
                AccountOrdersController.ORDER_STATUS_DRAFT, 
                AccountOrdersController.ORDER_STATUS_ACTIVATED
            );
        List<Order> activatedOrders = fetchOrdersWithStatus(AccountOrdersController.ORDER_STATUS_ACTIVATED);
        Assert.areEqual(RECORDS_AMOUNT, 
            activatedOrders.size(), 
            'Should update all orders to new status');
        Test.stopTest();
    }

    private static Account fetchAccount() {
        return [SELECT Id FROM Account LIMIT 1];
    }

    private static List<Order> fetchOrders() {
        return [SELECT Id, Status FROM Order LIMIT: RECORDS_AMOUNT];
    }

    private static List<Order> fetchOrdersWithStatus(String status) {
        return [SELECT Id, Status FROM Order WHERE Status =: status LIMIT: RECORDS_AMOUNT];
    }

    private static List<Id> getSObjectIds(List<SObject> records) {
        return new List<Id>((new Map<Id, SObject> (records)).keySet());
    }

    private static void updateOrdersStatus(List<Order> orders, String status) {
        for (Order ord : orders) {
            ord.Status = status;
        }
        update orders;
    }

    private static void activateContract(Contract contr) {
        contr.Status = CONTRACT_ACTIVATED_STATUS;
        update contr;
    }

    private static PaginationSettings__c fetchPaginationSettings() {
        return [SELECT Id, RecordsAmountOnPage__c FROM PaginationSettings__c LIMIT 1];
    }

}