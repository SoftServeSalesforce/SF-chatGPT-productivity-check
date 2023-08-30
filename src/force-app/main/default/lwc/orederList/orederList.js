import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';

export default class OrderList extends NavigationMixin(LightningElement) {
    @api recordId;
    orders = [];
    activateActionDisabled = false;
    markAsShippedActionDisabled = false;
    previewInvoiceActionDisabled = false;
    downloadInvoiceActionDisabled = false;

    actions = [
        { label: 'Activate', name: 'activate', disabled: this.activateActionDisabled },
        { label: 'Mark As Shipped', name: 'markAsShipped', disabled: this.markAsShippedActionDisabled },
        { label: 'Preview Invoice', name: 'previewInvoice', disabled: this.previewInvoiceActionDisabled },
        { label: 'Download Invoice', name: 'downloadInvoice', disabled: this.downloadInvoiceActionDisabled }
    ];
    columns = [
        {
            label: 'Number',
            fieldName: 'orderId',
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'orderNumber' },
                variant: 'base',
                name: 'redirectToOrder'
            }
        },
        {
            label: 'Date',
            fieldName: 'startDate',
            type: 'date',
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text',
        },
        {
            label: 'Amount',
            fieldName: 'amount',
            type: 'currency',
            typeAttributes: { currencyCode: 'USD' },
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Invoice', 
            type: 'button', 
            initialWidth: 135,
            disabled: this.downloadInvoiceActionDisabled,
            typeAttributes: {
                label: 'Download',
                title: 'Download Invoice',
                name: 'downloadInvoice',
                iconName: 'utility:download',
                variant: 'base',
                disabled: {fieldName: 'isInvoiceAvailable'},
            },
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.actions,
            }
        }
    ];

    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({error, data}) {
        if(data) {
            this.orders = data;
            // this.disableActions();

        } else if(error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    disableActions() {
        for (let order of this.orders) {
            console.log(order);
            if (order.status !== 'Draft') {
                this.activateActionDisabled = true;
            }
            else if (order.status !== 'Activated') {
                this.markAsShippedActionDisabled = true;
            }
            else if (order.contentDocumentId == null) {
                this.previewInvoiceActionDisabled = true;
                this.downloadInvoiceActionDisabled = true;
            }
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'redirectToOrder':
                this.redirectToOrderRecord(row);
                break;
            case 'activate':
                this.activateSelectedOrder(row.orderId);
                break;
            case 'markAsShipped':
                this.markOrderAsShipped(row.orderId);
                break;
            case 'previewInvoice':
                this.navigateToInvoicePreview(row.contentDocumentId);
                break;
            case 'downloadInvoice':
                this.downloadInvoice(row.contentDocumentId);
                break;
            default:
                break;
        }
    }

    redirectToOrderRecord(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.orderId,
                actionName: 'view'
            }
        });
    }

    activateSelectedOrder(orderId) {
        activateOrder({ orderId: orderId })
            .then(result => {
                this.showToast('Success', result, 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    markOrderAsShipped(orderId) {
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                this.showToast('Success', result, 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    navigateToInvoicePreview(contentDocumentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contentDocumentId,
                actionName: 'view'
            }
        });
    }

    downloadInvoice(contentDocumentId) {
        window.open(`/sfc/servlet.shepherd/document/download/${contentDocumentId}`);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}
