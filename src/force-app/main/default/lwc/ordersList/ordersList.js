import { api, wire, LightningElement } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';

export default class OrdersList extends LightningElement {
    @api recordId;

    ordersData = [];

    ordersColumns = [
        { label: 'Number', fieldName: 'orderNumber', type: 'text' },
        { label: 'Date', fieldName: 'startDate', type: 'date' },
        { label: 'Status', fieldName: 'status', type: 'text' },
        { label: 'Amount', fieldName: 'amount', type: 'currency', 
            typeAttributes: {currencyCode: 'USD'} },
        { type: 'button-icon', label: 'Invoice',
            typeAttributes: {
                iconName: 'utility:download',
                title: 'Invoice',
                variant: 'bare',
                name: 'download_invoice',
                disabled: {fieldName: 'hasInvoice'}
            },},
        { type: 'action', typeAttributes: { rowActions: this.getActions } }
    ];

    @wire(getOrders, {accountId: '$recordId'})
    wiredOrders({ error, data }) {
        if (data) {
            this.ordersData = data;
        } else if (error) {
            console.error('error loading orders');
        }
    }

    getActions(row, doneCallback){
        let actions = [];
        if (row.status === 'Draft') {
            actions.push({ label: 'Activate', name: 'activate'})
        }
        if (row.status === 'Activated') {
            actions.push({ label: 'Mark as Shipped', name: 'markAsShipped'})
        }
        if (row.hasInvoice) {
            actions.push({ label: 'Preview Invoice', name: 'previewInvoice'})
        }
        if (row.hasInvoice) {
            actions.push({ label: 'Download Invoice', name: 'downloadInvoice'})
        }
        doneCallback(actions);
    }

    handleRowAction(){
    
    }
}