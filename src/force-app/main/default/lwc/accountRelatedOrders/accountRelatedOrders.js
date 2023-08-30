import { LightningElement, wire, api } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

export default class AccountRelatedOrders extends NavigationMixin(LightningElement) {
    @api recordId; 
    wiredOrders;
    orders;
    error;
    rowActions = [
        { value: 'activate', label: 'Activate' },
        { value: 'markAsShipped', label: 'Mark as Shipped' },
        { value: 'previewInvoice', label: 'Preview Invoice'},
        { value: 'downloadInvoice', label: 'Download Invoice'}
    ];

    @wire(getOrders, { accountId: '$recordId' })
    handleOrders(value) {        
        this.wiredOrders = value; 
        const { data, error } = value; 
        if (data) {  
            this.orders = data;
            console.log('data ' + JSON.parse(JSON.stringify(data)));
            this.error = undefined;           
        } else if (error) {
            this.error = error;
            this.showToast('Error updating order', error.body.message, 'error');            
        }
    }

    handleActionSelected(event) {        
        const selectedAction = event.detail.value;
        const orderId = event.target.dataset.id;
        switch (selectedAction) {
            case 'activate':
                this.handleActivate(orderId);
                break;
            case 'markAsShipped':
                this.handleMarkAsShipped(orderId);
                break;
            case 'previewInvoice':
                console.log('previewInvoice ' + selectedAction);
                break;
            case 'downloadInvoice':
                handleDownloadRowAction(orderId);
                break;            
        }        
    }

    handleDownloadRowAction(orderId) {
        const row = this.template.querySelectorAll(`[data-id="$orderId"]`);
        console.log(row);
    }

    handleOrderNumberClick(event) {        
        this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: event.target.dataset.id,
            objectApiName: 'Order',
            actionName: 'view'
        },
    });        
    }

    handleActivate(orderId) {        
        activateOrder({ orderId: orderId })
            .then(result => {
                this.handleResponse(result);
            })
            .catch(error => {
                this.showToast('Some error occurred', error.body.message, 'error');
            });
    }

    handleMarkAsShipped(orderId) {        
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                this.handleResponse(result);
            })
            .catch(error => {
                this.showToast('Some error occurred', error.body.message, 'error');
            });
    }

    handleResponse(response) {
        if (response.responseStatus === 'Success') {
            this.showToast('Success', response.responseMessage, response.responseStatus);
            refreshApex(this.wiredOrders);
        } else if (response.responseStatus === 'Error') {
            this.showToast('Something went wrong', response.responseMessage, response.responseStatus);
        }
    }

    handleDownloadInvoice(event) {
        const contentDocumentId = event.target.dataset.id;
        this.downloadInvoice(contentDocumentId);
    }

    downloadInvoice(fileId) {
        const fileUrl = '/sfc/servlet.shepherd/document/download/' + fileId + '?operationContext=S1';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: fileUrl
            }
        }, false);
    }

    handlePreviewInvoice(fileId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: fileId
            }
        });
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
}