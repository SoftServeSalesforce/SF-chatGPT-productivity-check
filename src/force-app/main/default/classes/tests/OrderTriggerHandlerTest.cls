@IsTest
public with sharing class OrderTriggerHandlerTest {
    private static final String CONTRACT_ACTIVATED_STATUS = 'Activated';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';

    @TestSetup
    static void makeData(){
        Account acct = TestDataFactory.createAccount('Test');
        Contract contr = TestDataFactory.createContract(acct.Id);
        Order ord = TestDataFactory.createOrder(acct.iD, contr.Id);
        Product2 product = TestDataFactory.createProduct('Test');
        PricebookEntry pe = TestDataFactory.createPricebookEntry(product.Id);
        TestDataFactory.createOrderItem(ord.Id, pe.Id);
        activateContract(contr);
    }

    @IsTest
    static void testOrderLastStatusChangeUpdated() {
        Order ord = fetchOrder();
        Test.startTest();
        ord.LastStatusChanged__c = Datetime.newInstance(2020, 1, 1);
        ord.Status = ORDER_STATUS_SHIPPED;
        update ord;
        Order testOrder = fetchOrder();
        Assert.areNotEqual(ord.LastStatusChanged__c, testOrder.LastStatusChanged__c, 'Should update LastStatusChanged__c field');
        Test.stopTest();
    } 

    private static Order fetchOrder() {
        return [SELECT Id, LastStatusChanged__c, Status FROM Order LIMIT 1];
    }

    private static void activateContract(Contract contr) {
        contr.Status = CONTRACT_ACTIVATED_STATUS;
        update contr;
    }
}