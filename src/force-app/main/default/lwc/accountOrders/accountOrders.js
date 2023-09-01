import { LightningElement, api, wire, track } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountOrders extends NavigationMixin(LightningElement) {
    @api recordId;
    @track orders;

    columns = [
        { label: 'Number', fieldName: 'OrderURL', type: 'url', typeAttributes: { label: { fieldName: 'OrderNumber' }, target: '_blank' } },
        { label: 'Start Date', fieldName: 'EffectiveDate', type: 'date' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Amount', fieldName: 'TotalAmount', type: 'currency' },
        { label: 'Invoice', name: 'download_button', fieldName: 'ContentDocumentId', type: 'button-icon', 
            typeAttributes: { 
                iconName: 'utility:download', disabled: {fieldName: 'isInvoiceDisabled'}
            } 
        },
        { type: 'action', typeAttributes: { rowActions: this.rowActions } }
    ];

    get rowActions() {
        return (record, doneCallback) => {
            const actions = [];
            if (record.Status === 'Draft') {
                actions.push({ label: 'Activate', name: 'activate' });
            }
            if (record.Status === 'Activated') {
                actions.push({ label: 'Mark as Shipped', name: 'mark_as_shipped' });
            }
            if (!record.isInvoiceDisabled) {
                actions.push({ label: 'Preview Invoice', name: 'preview_invoice' });
                actions.push({ label: 'Download Invoice', name: 'download_invoice' });
            }
            setTimeout(() => {
                doneCallback(actions);
            }, 0);
        };
    }

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

    activateOrder(row) {
        activateOrder({ orderId: row.Id })
            .then(result => {
                this.showToast(result.status, result.ErrorMessage);
            })
            .catch(() => {
                this.showToast('ERROR', 'An unexpected error occurred.');
            });
    }

    markAsShipped(row) {
        markOrderAsShipped({ orderId: row.Id })
            .then(result => {
                this.showToast(result.status, result.ErrorMessage);
            })
            .catch(() => {
                this.showToast('ERROR', 'An unexpected error occurred.');
            });
    }

    showToast(title, message) {
        const variant = title === 'OK' ? 'success' : 'error';
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }

    previewInvoice(row) {
        const fileId = row.ContentDocumentId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                pageName: 'filePreview',
                recordId: fileId,
                actionName: 'view'
            }
        });
    }

    handleInvoiceDownload(row) {
        const downloadUrl = row.InvoiceUrl;
        window.open(downloadUrl);
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
                this.handleInvoiceDownload(row);
                break;
            default:
                this.handleInvoiceDownload(row);
                break;
        }
    }
}


