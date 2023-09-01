import { LightningElement, api, track } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders'

export default class OrderList extends LightningElement {
    @api recordId;

    @track data = [];

    loading = false;

    columns = [
        { 
            label: 'Number', 
            fieldName: 'orderNumber'
        },
        { 
            label: 'Date', 
            fieldName: 'startDate',
            type: 'date'
        },
        { 
            label: 'Status', 
            fieldName: 'status'
        },
        {
            label: 'Amount',
            fieldName: 'amount',
            type: 'currency',
            typeAttributes: { currencyCode: 'USD', step: '0.01' },
        },
    ]

    async connectedCallback() {
        this.loading = true;
        try {
            this.data = await getOrders({ accountId: this.recordId });
        } catch (err) {
            console.error(err);
        } finally {
            this.loading = false;
        }
    }
}