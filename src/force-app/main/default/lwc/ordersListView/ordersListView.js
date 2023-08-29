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
}
