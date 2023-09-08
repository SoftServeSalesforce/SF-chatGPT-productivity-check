@IsTest
public with sharing class TestOrderDTO {
    @IsTest
    private static void publicConstructorTest_validOrderAndInvoice() {
        String expected;
        String actual;
        OrderDTO result;
        try {
            result = new OrderDTO(
                new Order(),
                fflib_IDGenerator.generate(ContentVersion.SObjectType)
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertNotEquals(null, result);
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void publicConstructorTest_invalidInvoiceId() {
        String expected = Constants.EXCEPTION_INVOICEID_SHOULD_BE_VALID_CV_ID;
        String actual;
        try {
            new OrderDTO(
                new Order(),
                fflib_IDGenerator.generate(ContentDocument.SObjectType)
            );
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void publicConstructorTest_orderIsNull() {
        String expected = Constants.EXCEPTION_ORDER_CANNOT_BE_NULL;
        String actual;
        try {
            new OrderDTO(null, null);
        } catch (Exception e) {
            actual = e.getMessage();
        }
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void captureOrderDetailsTest() {
        OrderDTO dto = new OrderDTO();
        Order o = new Order(
            Id = fflib_IDGenerator.generate(Order.SObjectType),
            EffectiveDate = Date.today(),
            Status = Constants.ORDER_STATUS_DRAFT,
            LastStatusChanged__c = Datetime.now()
        );
        dto.captureOrderDetails(o);
        System.assertEquals(o.Id, dto.recordId);
        System.assert(dto.recordId.containsIgnoreCase(o.Id));
        System.assertEquals(o.EffectiveDate, dto.startDate);
        System.assertEquals(o.Status, dto.status);
        System.assertEquals(o.LastStatusChanged__c, dto.lastStatusChanged);
    }

    @IsTest
    private static void captureInvoiceDetailsTest_invoiceIdIsNotNull() {
        OrderDTO dto = new OrderDTO();
        Id cvId = fflib_IDGenerator.generate(ContentVersion.SObjectType);
        dto.captureInvoiceDetails(cvId);
        System.assert(String.isNotBlank(dto.invoicePreviewURL));
        System.assertEquals(Constants.CONTENT_DOCUMENT_VERSION_PREVIEW_LINK_TEMPLATE + cvId, dto.invoicePreviewURL);
        System.assert(String.isNotBlank(dto.invoiceDownloadURL));
        System.assertEquals(Constants.CONTENT_DOCUMENT_VERSION_DOWNLOAD_LINK_TEMPLATE + cvId, dto.invoiceDownloadURL);
    }

    @IsTest
    private static void captureInvoiceDetailsTest_invoiceIdIsNull() {
        OrderDTO dto = new OrderDTO();
        dto.captureInvoiceDetails(null);
        System.assert(String.isBlank(dto.invoicePreviewURL));
        System.assert(String.isBlank(dto.invoiceDownloadURL));
    }

    @IsTest
    private static void initHasInvoiceFlagTest_urlsNotSet() {
        OrderDTO dto = new OrderDTO();
        dto.initHasInvoiceFlag();
        System.assert(!dto.hasInvoice);
    }

    @IsTest
    private static void initHasInvoiceFlagTest_invoiceDownloadURLIsSet() {
        OrderDTO dto = new OrderDTO();
        Id cvId = fflib_IDGenerator.generate(ContentVersion.SObjectType);
        dto.invoiceDownloadURL = Constants.CONTENT_DOCUMENT_VERSION_DOWNLOAD_LINK_TEMPLATE + cvId;
        dto.initHasInvoiceFlag();
        System.assert(dto.hasInvoice);
    }

    @IsTest
    private static void initHasInvoiceFlagTest_invoicePreviewURLIsSet() {
        OrderDTO dto = new OrderDTO();
        Id cvId = fflib_IDGenerator.generate(ContentVersion.SObjectType);
        dto.invoicePreviewURL = Constants.CONTENT_DOCUMENT_VERSION_PREVIEW_LINK_TEMPLATE + cvId;
        dto.initHasInvoiceFlag();
        System.assert(dto.hasInvoice);
    }

    @IsTest
    private static void initCanBeActivatedFlagTest_statusIsNotDraft() {
        OrderDTO dto = new OrderDTO();
        dto.status = Constants.ORDER_STATUS_ACTIVATED;
        dto.initCanBeActivatedFlag();
        System.assert(!dto.canBeActivated);
    }

    @IsTest
    private static void initCanBeActivatedFlagTest_statusIsDraft() {
        OrderDTO dto = new OrderDTO();
        dto.status = Constants.ORDER_STATUS_DRAFT;
        dto.initCanBeActivatedFlag();
        System.assert(dto.canBeActivated);
    }

    @IsTest
    private static void initCanBeShippedFlagTest_statusIsNotActivated() {
        OrderDTO dto = new OrderDTO();
        dto.status = Constants.ORDER_STATUS_DRAFT;
        dto.initCanBeShippedFlag();
        System.assert(!dto.canBeShipped);
    }

    @IsTest
    private static void initCanBeShippedFlagTest_statusIsActivated() {
        OrderDTO dto = new OrderDTO();
        dto.status = Constants.ORDER_STATUS_ACTIVATED;
        dto.initCanBeShippedFlag();
        System.assert(dto.canBeShipped);
    }

    @IsTest
    private static void initShowActionsMenuFlagTest_hasInvoice() {
        OrderDTO dto = new OrderDTO();
        dto.hasInvoice = true;
        dto.initShowActionsMenuFlag();
        System.assert(dto.showActionsMenu);
    }

    @IsTest
    private static void initShowActionsMenuFlagTest_canBeShipped() {
        OrderDTO dto = new OrderDTO();
        dto.canBeShipped = true;
        dto.initShowActionsMenuFlag();
        System.assert(dto.showActionsMenu);
    }

    @IsTest
    private static void initShowActionsMenuFlagTest_canBeActivated() {
        OrderDTO dto = new OrderDTO();
        dto.canBeActivated = true;
        dto.initShowActionsMenuFlag();
        System.assert(dto.showActionsMenu);
    }
}