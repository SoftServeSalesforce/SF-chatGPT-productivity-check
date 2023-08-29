import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';

export default class OrdersListView extends NavigationMixin(LightningElement) {
    @api recordId; // Assuming this component is on a record page and the recordId is the Account Id
    orders = [];
    
    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        if(data) {
            this.orders = JSON.parse(JSON.stringify(data));
            this.error = undefined;
        } else if(error) {
            this.error = error;
            this.orders = undefined;
        }
    }

    createNewOrder() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order',
                actionName: 'new'
            }
        });
    }

    navigateToOrderRecord(event) {
        const orderId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orderId,
                actionName: 'view'
            }
        });
    }

    handleMenuSelect(event) {
        const combinedValue = event.detail.value;
        const action = combinedValue.split('_')[0];
        const recordId = combinedValue.split('_')[1];
        switch (action) {
            case 'activate':
                this.handleActivateOrder(recordId);
                break;
            case 'markShipped':
                this.handleMarkAsShipped(recordId);
                break;
            case 'previewInvoice':
                this.handlePreviewInvoice(recordId);
                break;
            case 'downloadInvoice':
                this.handleDownloadInvoice(recordId);
                break;
            default:
                console.error('Unknown action: ' + action);
                break;
        }
    }
    
    handleActivateOrder(orderId) {
        activateOrder({ orderId: orderId })
            .then(result => {
                if(result.status === 'OK') {
                    this.showToast('Success', 'Order activated successfully!', 'success');
                    // Refresh the orders list or specific order details as needed
                } else {
                    this.showToast('Error', result.ErrorMessage, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }
    
    handleMarkAsShipped(orderId) {
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                if(result.status === 'OK') {
                    this.showToast('Success', 'Order marked as shipped successfully!', 'success');
                    // Refresh the orders list or specific order details as needed
                } else {
                    this.showToast('Error', result.ErrorMessage, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    
    handlePreviewInvoice(contentDocumentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: contentDocumentId
            }
        });
    }
    
    handleDownloadInvoiceIcon(event) {
        const contentDocumentId = event.currentTarget.dataset.id;
        this.handleDownloadInvoice(contentDocumentId);
    }

    handleDownloadInvoice(contentDocumentId) {
        window.open(`/sfc/servlet.shepherd/document/download/${contentDocumentId}`);
    }

    get processedOrders() {
        return this.orders.map(order => {
            return {
                ...order,
                isDraft: order.status === 'Draft',
                isActivated: order.status === 'Activated',
                activateValue: 'activate_' + order.orderId,
                markShippedValue: 'markShipped_' + order.orderId,
                previewInvoiceValue: 'previewInvoice_' + order.contentDocumentId,
                downloadInvoiceValue: 'downloadInvoice_' + order.contentDocumentId
            };
        });
    }
}
