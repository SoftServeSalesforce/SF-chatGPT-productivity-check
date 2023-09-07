/**
 * @description OrderDTO: DTO used to pass Order details
 * in UI-friendly format.
 */
public with sharing class OrderDTO {
    @AuraEnabled
    public String recordId;
    @AuraEnabled
    public String recordURL;
    @AuraEnabled
    public String orderNumber;
    @AuraEnabled
    public Date startDate;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Datetime lastStatusChanged;
    @AuraEnabled
    public Decimal amount;
    @AuraEnabled
    public Boolean canBeActivated;
    @AuraEnabled
    public Boolean canBeShipped;
    @AuraEnabled
    public String invoicePreviewURL;
    @AuraEnabled
    public String invoiceDownloadURL;
    @AuraEnabled
    public Boolean hasInvoice;
    @AuraEnabled
    public Boolean showActionsMenu;

    public void addOrderDetails(Order o) {
        //Safety block to avoid NLPE.
        if (null == o) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ORDER_CANNOT_BE_NULL);
        }
        this.recordId = o.Id;
        this.recordURL = '/' + o.Id;
        this.orderNumber = o.OrderNumber;
        this.startDate = o.EffectiveDate;
        this.status = o.Status;
        this.lastStatusChanged = o.LastStatusChanged__c;
        this.amount = o.TotalAmount;
        this.initCanBeActivatedFlag();
        this.initCanBeShippedFlag();
        this.initShowActionsMenuFlag();
    }

    public void addInvoice(ContentDocumentLink cdl) {
        //Safety block to avoid NLPE.
        if (null == cdl) {
            return;
        }
        this.hasInvoice = true;
        this.invoicePreviewURL
            = Constants.CONTENT_DOCUMENT_VERSION_PREVIEW_LINK_TEMPLATE
            + cdl.ContentDocument.LatestPublishedVersionId;
        this.invoiceDownloadURL
            = Constants.CONTENT_DOCUMENT_VERSION_DOWNLOAD_LINK_TEMPLATE
            + cdl.ContentDocument.LatestPublishedVersionId;
        this.initShowActionsMenuFlag();
    }

    private void initCanBeActivatedFlag() {
        this.canBeActivated = Constants.ORDER_STATUS_DRAFT.equalsIgnoreCase(this.Status);
    }

    private void initCanBeShippedFlag() {
        this.canBeShipped = Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(this.Status);
    }

    private void initShowActionsMenuFlag() {
        this.showActionsMenu = true == this.canBeActivated || true == this.canBeShipped || true == this.hasInvoice;
    }
}