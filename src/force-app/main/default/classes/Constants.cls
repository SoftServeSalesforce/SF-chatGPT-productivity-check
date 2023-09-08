/**
 * @description Constants: Apex Class to store constants.
 */
public with sharing class Constants {
    public static final String EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE = 'Unsupported trigger operation type!';
    public static final String EXCEPTION_ACCOUNTID_CANNOT_BE_BLANK = '"accountId" cannot be blank!';
    public static final String EXCEPTION_ACCOUNTID_IS_NOT_VALID = '"accountId" is not valid!';
    public static final String EXCEPTION_ORDER_CANNOT_BE_NULL = '"order" cannot be null!';
    public static final String EXCEPTION_ORDERIDS_CANNOT_BE_NULL = '"orderIds" cannot be null!';
    public static final String EXCEPTION_ORDERIDS_CANNOT_BE_EMPTY = '"orderIds" cannot be empty!';
    public static final String EXCEPTION_PAGENUMBER_CANNOT_BE_NULL = '"pageNumber" cannot be null!';
    public static final String EXCEPTION_PAGENUMBER_BE_EQUAL_TO_OR_LESS_THAN_ZERO = '"pageNumber" cannot be equal to or less than 0!';
    public static final String EXCEPTION_PAGESIZE_CANNOT_BE_NULL = '"pageSize" cannot be null!';
    public static final String EXCEPTION_SSC_CANNOT_BE_NULL = '"ssc" cannot be null!';
    public static final String EXCEPTION_INVOICEID_SHOULD_BE_VALID_CV_ID = '"invoiceId" should be valid ContentVersion Id!';
    public static final String EXCEPTION_PAGESIZE_CANNOT_BE_EQUAL_TO_OR_LESS_THAN_ZERO = '"pageSize" cannot be equal to or less than 0!';
    public static final String EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_ACTIVATED = 'Order cannot be activated as it is at {0} Status.';
    public static final String EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_SHIPPED = 'Order cannot be shipped as it is at {0} Status.';
    public static final String EXCEPTION_TEMPLATE_ORDER_CANNOT_BE_UPDATED_BECAUSE = 'Order #{0} cannot be updated. Error(s): {1}';
    public static final String EXCEPTION_ORDERIDS_SHOULD_CONTAIN_ONLY_VALID_ORDER_IDS = '"orderIds" should contain only valid Order Ids!';
    public static final String EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_NULL = 'Trigger new list cannot be null!';
    public static final String EXCEPTION_TRIGGER_NEW_LIST_CANNOT_BE_EMPTY = 'Trigger new list cannot be empty!';
    public static final String EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_NULL = 'Trigger old map list cannot be null!';
    public static final String EXCEPTION_TRIGGER_OLD_MAP_CANNOT_BE_EMPTY = 'Trigger old map cannot be empty!';
    //SOQL-related constants.

    public static final String CONTRACT_STATUS_DRAFT = 'Draft';

    public static final String ORDER_STATUS_DRAFT = 'Draft';
    public static final String ORDER_STATUS_ACTIVATED = 'Activated';
    public static final String ORDER_STATUS_SHIPPED = 'Shipped';
    public static final String ORDER_STATUS_DELIVERED = 'Delivered';

    public static final String ORDER_UPDATE_STATUS_OK = 'ok';
    public static final String ORDER_UPDATE_STATUS_ERROR = 'error';
    
    public static final String SEMICOLON = ';';
    public static final String LINE_BRAKE = '\n\r';

    public static final String SOQL_STARTS_WITH_INVOICE = 'Invoice%';

    public static final String CONTENT_DOCUMENT_VERSION_DOWNLOAD_LINK_TEMPLATE
        = Url.getSalesforceBaseUrl().toExternalForm()
        + '/sfc/servlet.shepherd/version/download/';
    public static final String CONTENT_DOCUMENT_VERSION_PREVIEW_LINK_TEMPLATE
        = Url.getSalesforceBaseUrl().toExternalForm()
        + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=';

    public static final Integer LWC_PAGINATION_PAGE_SIZE_DEFAULT = 10;

    public static final String DSR_WITH_NO_ERROR_TEMPLATE = '{"success":true,"id":"{0}"}';
    public static final String DSR_WITH_ERROR_TEMPLATE = '{"success":false,"id":"{0}","errors":[{"message":"{1}"}]}';
    public static final String CLD_WITH_LINKED_ENTITY_CD_AND_CV_TEMPLATE = '{"attributes":{"type":"ContentDocumentLink","url":'
        + '"/services/data/v58.0/sobjects/ContentDocumentLink/{0}"},"Id":"{0}","LinkedEntityId":"{1}","ContentDocumentId":"{2}",'
        + '"ContentDocument":{"attributes":{"type":"ContentDocument","url":"/services/data/v58.0/sobjects/ContentDocument/{2}"},'
        + '"Id":"{2}","LatestPublishedVersionId":"{3}"}}';
}