import { LightningElement, api, wire } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';

export default class OrderList extends LightningElement {
    @api recordId;
    orders;
    error;

    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        if (data) {
            this.orders = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.orders = undefined;
        }
    }
}
