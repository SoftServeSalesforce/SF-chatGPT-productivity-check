import { LightningElement, api, wire, track } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountOrders extends LightningElement {
    @api recordId;
    @track orders;

    columns = [
        { label: 'Number', fieldName: 'OrderURL', type: 'url', typeAttributes: { label: { fieldName: 'OrderNumber' }, target: '_blank' } },
        { label: 'Start Date', fieldName: 'EffectiveDate', type: 'date' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Amount', fieldName: 'TotalAmount', type: 'currency' },
        { label: 'Invoice', fieldName: 'InvoiceFileId', type: 'button-icon', 
            typeAttributes: { 
                iconName: 'utility:download', disabled: {fieldName: 'isInvoiceDisabled'}
            } 
        },
        { type: 'action', typeAttributes: { rowActions: this.rowActions } }
    ];

    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        if (data) {
            this.orders = data.map(row => {
                let rowData = { ...row };
                rowData.OrderURL = `/lightning/r/Order/${rowData.Id}/view`;
                rowData.isInvoiceDisabled = rowData.ContentDocumentId ? false : true;

                return rowData;
            });
            this.error = undefined;
        } else if (error) {
            console.error('Error received: ', error);
        }
    }

    get rowActions() {
        return (record, doneCallback) => {
            const actions = [];
            if (record.Status === 'Draft') {
                actions.push({ label: 'Activate', name: 'activate' });
            }
            if (record.Status === 'Active') {
                actions.push({ label: 'Mark as Shipped', name: 'mark_as_shipped' });
            }
            if (record.InvoiceFileName) {
                actions.push({ label: 'Preview Invoice', name: 'preview_invoice' });
                actions.push({ label: 'Download Invoice', name: 'download_invoice' });
            }
            setTimeout(() => {
                doneCallback(actions);
            }, 0);
        };
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'activate':
                this.activateOrder(row);
                break;
            case 'mark_as_shipped':
                this.markAsShipped(row);
                break;
            case 'preview_invoice':
                this.previewInvoice(row);
                break;
            case 'download_invoice':
                this.downloadInvoice(row);
                break;
            default:
                break;
        }
    }

    activateOrder(row) {
        activateOrder({ orderId: row.Id })
            .then(result => {
                this.handleServerResponse(result);
            })
            .catch(error => {
                this.showToast('Error', 'An unexpected error occurred.', 'error');
            });
    }

    markAsShipped(row) {
        markOrderAsShipped({ orderId: row.Id })
            .then(result => {
                this.handleServerResponse(result);
            })
            .catch(error => {
                this.showToast('Error', 'An unexpected error occurred.', 'error');
            });
    }

    handleServerResponse(result) {
        const status = result.status;
        const errorMessage = result.ErrorMessage;

        if (status === 'OK') {
            this.showToast('Success', 'Operation successful.', 'success');
        } else {
            this.showToast('Error', errorMessage, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }

    previewInvoice(row) {
        const fileId = row.InvoiceFileId;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview',
            },
            state: {
                // assigning ContentDocumentId to show file preview
                selectedRecordId: fileId,
            },
        });
    }

    downloadInvoice(row) {
        const downloadUrl = row.InvoiceFileDownloadUrl;
        window.open(downloadUrl);
    }    
}


