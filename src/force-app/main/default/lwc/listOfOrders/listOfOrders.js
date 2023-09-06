import { LightningElement, wire } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';

export default class OrdersTable extends LightningElement {
    orders;

    @wire(getOrders)
    wiredOrders({ error, data }) {
        if (data) {
            this.orders = data;
        } else if (error) {
            // Handle error
        }
    }
}