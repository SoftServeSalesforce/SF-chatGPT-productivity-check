import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';

export default class OrdersListView extends NavigationMixin(LightningElement) {
    @api recordId; // Assuming this component is on a record page and the recordId is the Account Id
    orders = [];
    
    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        if(data) {
            this.orders = JSON.parse(JSON.stringify(data));
            console.log(this.orders);
            this.error = undefined;
        } else if(error) {
            console.log(error);
            this.error = error;
            this.orders = undefined;
        }
    }

    navigateToOrderRecord(event) {
        const orderId = event.currentTarget.dataset.id;
        console.log(orderId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orderId,
                actionName: 'view'
            }
        });
    }
}
