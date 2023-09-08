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

    //Testing support.
    @TestVisible
    private OrderDTO() {}

    public OrderDTO(Order o, Id invoiceId) {
        if (null == o) {
            throw new IllegalArgumentException(Constants.EXCEPTION_ORDER_CANNOT_BE_NULL);
        }
        captureOrderDetails(o);
        if (null != invoiceId) {
            if (ContentVersion.SObjectType != invoiceId.getSobjectType()) {
                throw new IllegalArgumentException(Constants.EXCEPTION_INVOICEID_SHOULD_BE_VALID_CV_ID);
            }
            captureInvoiceDetails(invoiceId);
        }
        initHasInvoiceFlag();
        initCanBeActivatedFlag();
        initCanBeShippedFlag();
        //After all.
        initShowActionsMenuFlag();
    }

    @TestVisible
    private void captureOrderDetails(Order o) {
        this.recordId = o.Id;
        this.recordURL = '/' + o.Id;
        this.orderNumber = o.OrderNumber;
        this.startDate = o.EffectiveDate;
        this.status = o.Status;
        this.lastStatusChanged = o.LastStatusChanged__c;
        this.amount = o.TotalAmount;
    }

    @TestVisible
    private void captureInvoiceDetails(Id invoiceId) {
        if (null == invoiceId) {
            return;
        }
        this.invoicePreviewURL
            = Constants.CONTENT_DOCUMENT_VERSION_PREVIEW_LINK_TEMPLATE
            + invoiceId;
        this.invoiceDownloadURL
            = Constants.CONTENT_DOCUMENT_VERSION_DOWNLOAD_LINK_TEMPLATE
            + invoiceId;
    }

    @TestVisible
    private void initHasInvoiceFlag() {
        this.hasInvoice = String.isNotBlank(this.invoicePreviewURL) || String.isNotBlank(this.invoiceDownloadURL);
    }

    @TestVisible
    private void initCanBeActivatedFlag() {
        this.canBeActivated = Constants.ORDER_STATUS_DRAFT.equalsIgnoreCase(this.Status);
    }

    @TestVisible
    private void initCanBeShippedFlag() {
        this.canBeShipped = Constants.ORDER_STATUS_ACTIVATED.equalsIgnoreCase(this.Status);
    }

    @TestVisible
    private void initShowActionsMenuFlag() {
        this.showActionsMenu = true == this.canBeActivated || true == this.canBeShipped || true == this.hasInvoice;
    }
}