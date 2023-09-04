import {api, LightningElement} from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders'

export default class AccountOrdersRelatedList extends LightningElement {
    @api recordId;

    ordersTableData = [];

    ordersTableColumnsDef = [{
        type: 'text', fieldName: 'orderNumber', label: 'Number'
    }, {
        type: 'date', fieldName: 'startDate', label: 'Date'
    }, {
        type: 'text', fieldName: 'status', label: 'Status'
    }, {
        type: 'currency', fieldName: 'amount', label: 'Amount', typeAttributes: {currencyCode: 'USD'}
    }];

    connectedCallback() {
        getOrders({accountId: this.recordId}).then(result => {
            if (null !== result) {
                this.ordersTableData = result;
            }
        }).catch(error => {
            console.error('## error loading orders: ' + JSON.stringify(error));
        })
    }


}