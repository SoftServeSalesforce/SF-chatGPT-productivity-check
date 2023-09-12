import { api, wire, LightningElement } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';

export default class OrdersList extends LightningElement {
    @api recordId;

    ordersData = [];
    ordersColumns = [
        { label: 'Number', fieldName: 'orderNumber', type: 'text' },
        { label: 'Date', fieldName: 'startDate', type: 'date' },
        { label: 'Status', fieldName: 'status', type: 'text' },
        { label: 'Amount', fieldName: 'amount', type: 'currency', typeAttributes: {currencyCode: 'USD'} }
    ];

    @wire(getOrders, {accountId: '$recordId'})
    wiredOrders({ error, data }) {
        if (data) {
            this.ordersData = data;
        } else if (error) {
            console.error('error loading orders');
        }
    }
}