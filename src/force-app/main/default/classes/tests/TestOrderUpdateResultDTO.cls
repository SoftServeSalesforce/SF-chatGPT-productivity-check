@IsTest
public with sharing class TestOrderUpdateResultDTO {
    @IsTest
    private static void publicConstructorTest() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_OK, dto.status);
        System.assertNotEquals(null, dto.errorMessages);
        System.assert(dto.errorMessages.isEmpty());
    }

    @IsTest
    private static void captureErrorsFromSaveResultsTest_hasErrors() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        Order o = new Order(
            Id = fflib_IDGenerator.generate(Order.SobjectType)
        );
        Map<Id, Order> ordersById = new Map<Id, Order> { o.Id => o };
        Database.SaveResult dsr = (Database.SaveResult)JSON.deserialize(
            Constants.DSR_WITH_ERROR_TEMPLATE
                .replace('{0}', o.Id)
                .replace('{1}', Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE),
            Database.SaveResult.class
        );
        List<Database.SaveResult> dsrs = new List<Database.SaveResult> { dsr };
        dto.captureErrorsFromSaveResults(ordersById, dsrs);
        System.assert(!dto.errorMessages.isEmpty());
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_ERROR, dto.status);
        System.assert(dto.errorMessages.contains(
            String.format(
                Constants.EXCEPTION_TEMPLATE_ORDER_CANNOT_BE_UPDATED_BECAUSE,
                new List<String> {
                    o.OrderNumber,
                    Constants.EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE
                }
            )
        ));
    }

    @IsTest
    private static void captureErrorsFromSaveResultsTest_noErrors() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        Order o = new Order(
            Id = fflib_IDGenerator.generate(Order.SobjectType)
        );
        Map<Id, Order> ordersById = new Map<Id, Order> { o.Id => o };
        Database.SaveResult dsr = (Database.SaveResult)JSON.deserialize(
            Constants.DSR_WITH_NO_ERROR_TEMPLATE.replace('{0}', o.Id),
            Database.SaveResult.class
        );
        List<Database.SaveResult> dsrs = new List<Database.SaveResult> { dsr };
        dto.captureErrorsFromSaveResults(ordersById, dsrs);
        System.assert(dto.errorMessages.isEmpty());
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_OK, dto.status);
    }

    @IsTest
    private static void captureErrorsFromSaveResultsTest_saveResultIsEmpty() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        dto.captureErrorsFromSaveResults(
            new Map<Id, Order> { null => new Order() },
            new List<Database.SaveResult>()
        );
        System.assert(dto.errorMessages.isEmpty());
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_OK, dto.status);
    }

    @IsTest
    private static void captureErrorsFromSaveResultsTest_saveResultIsNull() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        dto.captureErrorsFromSaveResults(new Map<Id, Order> { null => new Order() }, null);
        System.assert(dto.errorMessages.isEmpty());
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_OK, dto.status);
    }

    @IsTest
    private static void captureErrorsFromSaveResultsTest_ordersByIdIsEmpty() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        dto.captureErrorsFromSaveResults(new Map<Id, Order>(), null);
        System.assert(dto.errorMessages.isEmpty());
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_OK, dto.status);
    }

    @IsTest
    private static void captureErrorsFromSaveResultsTest_ordersByIdIsNull() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        dto.captureErrorsFromSaveResults(null, null);
        System.assert(dto.errorMessages.isEmpty());
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_OK, dto.status);
    }

    @IsTest
    private static void captureExceptionTest_exceptionIsNotNull() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        Exception e = new IllegalArgumentException('Test');
        dto.captureException(e);
        System.assert(!dto.errorMessages.isEmpty());
        System.assert(dto.errorMessages.contains(e.getMessage()));
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_ERROR, dto.status);
    }

    @IsTest
    private static void captureExceptionTest_exceptionIsNull() {
        OrderUpdateResultDTO dto = new OrderUpdateResultDTO();
        dto.captureException(null);
        System.assert(dto.errorMessages.isEmpty());
        System.assertEquals(Constants.ORDER_UPDATE_STATUS_OK, dto.status);
    }
}