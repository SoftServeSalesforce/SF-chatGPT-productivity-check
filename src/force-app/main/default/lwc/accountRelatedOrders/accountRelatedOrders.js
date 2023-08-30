import { LightningElement, wire, api } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

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
            new ShowToastEvent({
                title: "Error updating order",
                message: error.body.message,
                variant: "error",
            });
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
}