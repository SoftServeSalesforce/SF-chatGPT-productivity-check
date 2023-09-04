/**
 * @description Constants: Apex Class to store constants.
 */
public with sharing class Constants {
    //TODO: Migrate exceptions to Custom Labels so it is possible to translate them if needed.
    public static final String EXCEPTION_ACCOUNTID_CANNOT_BE_BLANK = 'accountId cannot be blank!';
    public static final String EXCEPTION_ACCOUNTID_IS_NOT_VALID = 'accountId is not valid!';
    public static final String EXCEPTION_AT_LEAST_ONE_FIELD_SHOULD_BE_INCLUDED_INTO_QUERY = 'At least one field should be included into SOQL query!';
    public static final String EXCEPTION_SOBJECT_FIELD_CANNOT_BE_NULL = 'SObject Field cannot be null!';
    public static final String EXCEPTION_TEMPLATE_FIELD_DOES_NOT_EXIST = '"{0}" field does not exist on the "{1}"!';
    //SOQL-related constants.
    public static final String SOQL_WHERE_KEYWORD = ' WHERE ';
    public static final String SOQL_FIELDS_DELIMITER = ', ';

    public static final String ORDER_STATUS_DRAFT = 'Draft';
    public static final String ORDER_STATUS_ACTIVATED = 'Activated';
    public static final String ORDER_STATUS_SHIPPED = 'Shipped';

    public static final String ORDER_UPDATE_STATUS_OK = 'ok';
    public static final String ORDER_UPDATE_STATUS_ERROR = 'error';
}