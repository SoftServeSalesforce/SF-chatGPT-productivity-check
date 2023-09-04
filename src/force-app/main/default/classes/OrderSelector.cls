/**
 * @description OrderSelector: Apex Class used to access "Order" SObject records.
 * //TODO: Cover with Apex Tests.
 */
public with sharing class OrderSelector {

    public static final String SOQL_SELECT_TEMPLATE_FOR_ORDER = 'SELECT {0} FROM Order';

    @TestVisible
    private static OrderSelector instance;

    /**
     * @description getInstance: Public access to the Class.
     * @return: Selector instance.
     */
    public static OrderSelector getInstance() {
        if (instance == null) {
            instance = new OrderSelector();
        }
        return instance;
    }

    /**
     * @description getOrdersByAccountId: Method used to query records 
     * of the "Order" SObject with given value specified for "AccountId" lookup.
     * @param fieldsToInclude: Fields of the "Order" SObject to be included into SOQL query.
     * @param accountId: Id of a parent "Account" record.
     * @return: List of the "Order" records which match filter criteria OR empty list.
     */
    public List<Order> getOrdersByParentAccountId(Set<SObjectField> fieldsToInclude, Id accountId) {
        //Validate arguments.
        validateFieldsToInclude(fieldsToInclude);
        //Build query.
        String fieldsToIncludeNames = getSObjectFieldNames(fieldsToInclude);
        String query = String.format(SOQL_SELECT_TEMPLATE_FOR_ORDER, new List<String> { fieldsToIncludeNames });
        query += Constants.SOQL_WHERE_KEYWORD + Order.AccountId.getDescribe().getName() + ' = :accountId';
        //Execute query and return results.
        return Database.query(query);
    }

    /**
     * @description validateFieldsToInclude: Helper method used to ensure that no junk data is passed into
     * SOQL query.
     * @param: Fields to be included into SOQL query. 
     */
    private void validateFieldsToInclude(Set<SObjectField> fields) {
        if (null == fields || fields.isEmpty()) {
            throw new IllegalArgumentException(Constants.EXCEPTION_AT_LEAST_ONE_FIELD_SHOULD_BE_INCLUDED_INTO_QUERY);
        }
        for (SObjectField field : fields) {
            if (null == field) {
                throw new IllegalArgumentException(Constants.EXCEPTION_SOBJECT_FIELD_CANNOT_BE_NULL);
            }
            if (Order.SObjectType != field.getDescribe().getSObjectType()) {
                throw new IllegalArgumentException(
                    String.format(
                        Constants.EXCEPTION_TEMPLATE_FIELD_DOES_NOT_EXIST,
                        new List<String> { String.valueOf(field), String.valueOf(Order.SObjectType) }
                    )
                );
            }
        }
    }

    /**
     * @description getSObjectFieldNames: Helper method used to convert
     * List with SObjectField entries to String with Names of those entries
     * so it is possible to use it inside SOQL query string.
     * @param fields: SObjectFields entries to convert.
     * @return: String with Names of given "fields" entries.
     */
    private String getSObjectFieldNames(Set<SObjectField> fields) {
        List<String> fieldNames = new List<String>();
        for (SObjectField field : fields) {
            fieldNames.add(field.getDescribe().getName());
        }
        return String.join(fieldNames, Constants.SOQL_FIELDS_DELIMITER);
    }
}