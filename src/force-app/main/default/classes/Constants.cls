/**
 * @description Constants: Apex Class to store constants.
 */
public with sharing class Constants {
    public static final String EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE = 'Unsupported trigger operation type!';
    public static final String EXCEPTION_ACCOUNTID_CANNOT_BE_BLANK = '"accountId" cannot be blank!';
    public static final String EXCEPTION_ACCOUNTID_IS_NOT_VALID = '"accountId" is not valid!';
    public static final String EXCEPTION_ORDER_CANNOT_BE_NULL = '"order" cannot be null!';
    public static final String EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_ACTIVATED = 'Order #{0} cannot be activated as it is at {1} Status.';
    public static final String EXCEPTION_TEMPLATE_ORDER_STATUS_CANNOT_BE_CHANGED_TO_SHIPPED = 'Order #{0} cannot be shipped as it is at {1} Status.';
    //SOQL-related constants.

    public static final String ORDER_STATUS_DRAFT = 'Draft';
    public static final String ORDER_STATUS_ACTIVATED = 'Activated';
    public static final String ORDER_STATUS_SHIPPED = 'Shipped';

    public static final String ORDER_UPDATE_STATUS_OK = 'ok';
    public static final String ORDER_UPDATE_STATUS_ERROR = 'error';

    public static final String SOQL_STARTS_WITH_INVOICE = 'Invoice%';

    public static final String CONTENT_DOCUMENT_VERSION_DOWNLOAD_LINK_TEMPLATE = Url.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/';
}