@IsTest
public with sharing class TestPageWithOrdersDTO {
    @IsTest
    private static void publicConstructorTest() {
        PageWithOrdersDTO dto = new PageWithOrdersDTO();
        System.assertNotEquals(null, dto.orders);
        System.assert(dto.orders.isEmpty());
    }

    @IsTest
    private static void addPageDetailsTest_sccIsNotNull() {
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT Id FROM Order]);
        PageWithOrdersDTO dto = new PageWithOrdersDTO();
        dto.addPageDetails(ssc);
        System.assertEquals(ssc.getPageNumber(), dto.pageNumber);
        System.assertEquals(ssc.getPageSize(), dto.pageSize);
        System.assertEquals(ssc.getHasPrevious(), dto.hasPreviousPage);
        System.assertEquals(ssc.getHasNext(), dto.hasNextPage);
        System.assertEquals(ssc.getResultSize(), dto.totalOrders);
        System.assertEquals((dto.totalOrders / (Decimal) dto.pageSize).round(System.RoundingMode.CEILING).intValue(), dto.totalPages);
    }

    @IsTest
    private static void addPageDetailsTest_sccIsNull() {
        String expected = Constants.EXCEPTION_SSC_CANNOT_BE_NULL;
        String actual;
        try {
            PageWithOrdersDTO dto = new PageWithOrdersDTO();
            dto.addPageDetails(null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }
}