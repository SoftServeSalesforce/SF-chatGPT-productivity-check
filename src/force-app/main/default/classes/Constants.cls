public with sharing class Constants {
    public static final String EXCEPTION_UNSUPPORTED_TRIGGER_OPERATION_TYPE = 'Unsupported trigger operation type!';
    
    public static final String CASE_ORIGIN_WEB = 'Web';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String ERROR_PLEASE_CLAIM_CASE_BEFORE_CHANGING_ITS_STATUS = 'Please claim case before changing its status!';

    @TestVisible
    private static final String ERROR_INSTANCE_SHOULD_BE_NULL = 'Instance should be null.';
    @TestVisible
    private static final String ERROR_INSTANCE_SHOULD_NOT_BE_NULL = 'Instance should not be null.';
    @TestVisible
    private static final String ERROR_RECORD_SHOULD_BE_ERRORED = 'Record should be errored.';
    @TestVisible
    private static final String ERROR_RECORD_HAS_UNEXPECTED_ERROR = 'Record has unexpected error.';
    @TestVisible
    private static final String ERROR_RECORD_SHOULDNT_BE_ERRORED = 'Record shouldnt be errored.';
}