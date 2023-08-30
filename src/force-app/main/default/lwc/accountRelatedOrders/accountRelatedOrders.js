import { LightningElement, wire, api } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

export default class AccountRelatedOrders extends NavigationMixin(LightningElement) {
    @api recordId; 
    orders;
    error;

    @wire(getOrders, { accountId: '$recordId' })
    handleOrders({ error, data }) {
        if (data) {  
            this.orders = data;
            this.error = undefined;           
        } else if (error) {
            this.error = error;
            this.showToast('Error updating order', error.body.message, 'error');            
        }
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

    handleActivate(event) {
        const orderId = event.target.dataset.id;
        activateOrder({ orderId: orderId })
            .then(result => {
                this.handleResponse(result, orderId);
            })
            .catch(error => {
                this.showToast('Some error occurred', error.body.message, 'error');
            });
    }

    handleMarkAsShipped(event) {
        const orderId = event.target.dataset.id;
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                this.handleResponse(result, orderId);
            })
            .catch(error => {
                this.showToast('Some error occurred', error.body.message, 'error');
            });
    }

    handleResponse(response, recordId) {
        if (response.responseStatus === 'Success') {
            this.showToast('Success', response.responseMessage, response.responseStatus);
            notifyRecordUpdateAvailable([{recordId: recordId}]);
        } else if (response.responseStatus === 'Error') {
            this.showToast('Something went wrong', response.responseMessage, response.responseStatus);
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
}