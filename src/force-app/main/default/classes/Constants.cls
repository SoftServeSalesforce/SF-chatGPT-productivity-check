public with sharing class Constants {
    public static final String EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE = 'Unsupported trigger operation type!';
    // Case constants    
    public static final String CASE_ORIGIN_WEB = 'Web';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_CREATE_DEFAULT_ORIGIN = 'Web';
    public static final String ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS = 'Please claim case before changing its status!';
    // Account constants
    public static final String ACCOUNT_ACTIVE_PICKLIST_YES = 'Yes';
    public static final String ACCOUNT_ACTIVE_PICKLIST_NO = 'No';
    public static final String ACCOUNT_ALLOW_REACTIVATE_PERMISSION = 'Account_AllowReactivate';
    public static final String ERROR_CANT_UPDATE_INACTIVE_ACCOUNT = 'Can\'t update inactive account!';
    // Create Actions constants
    public static final String ERROR_UNSUPPORTED_OBJECT_TYPE = 'Error unsupported object type: ';
    @TestVisible
    private static final String ERROR_INSTANCE_SHOULD_BE_NULL = 'Instance should be null.';
    @TestVisible
    private static final String ERROR_INSTANCE_SHOULD_NOT_BE_NULL = 'Instance should not be null.';
    @TestVisible
    private static final String ERROR_RECORD_SHOULD_BE_ERRORED = 'Record should be errored.';
    @TestVisible
    private static final String ERROR_RECORD_SHOULD_NOT_BE_ERRORED = 'Record should not be errored.';
    @TestVisible
    private static final String ERROR_RECORD_HAS_UNEXPECTED_ERROR = 'Record has unexpected error.';
    @TestVisible
    private static final String ERROR_UNEXPECTED_TRIGGER_HANDLER_OPERATION_MESSAGE = 'Unexpected trigger handler error message.';
}