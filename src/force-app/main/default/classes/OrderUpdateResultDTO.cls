
/**
 * @description OrderUpdateResultDTO: DTO used to pass details
 * about Order update in UI-friendly format.
 */
public with sharing class OrderUpdateResultDTO {
    @AuraEnabled
    public String status;
    @AuraEnabled
    public List<String> errorMessages;

    public OrderUpdateResultDTO() {
        this.status = Constants.ORDER_UPDATE_STATUS_OK;
        this.errorMessages = new List<String>();
    }

    public void captureErrorsFromSaveResults(Map<Id, Order> ordersById, List<Database.SaveResult> saveResults) {
        for (Database.SaveResult saveResult : saveResults) {
            if (saveResult.isSuccess()) {
                continue;
            }
            String errors = '';
            for (Database.Error e : saveResult.getErrors()) {
                errors += Constants.SEMICOLON + e.getMessage();
            }
            errors = errors.removeStart(Constants.SEMICOLON);
            this.errorMessages.add(
                String.format(
                    Constants.EXCEPTION_TEMPLATE_ORDER_CANNOT_BE_UPDATED_BECAUSE,
                    new List<String> { String.valueOf(ordersById.get(saveResult.getId()).OrderNumber), String.valueOf(errors) }
                )
            );
            this.status = Constants.ORDER_UPDATE_STATUS_ERROR;
        }
    }

    public void captureException(Exception e) {
        this.status = Constants.ORDER_UPDATE_STATUS_ERROR;
        this.errorMessages.add(e.getMessage());
    }
}