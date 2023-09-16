import { LightningElement, api, track, wire} from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
const actions = [
    // { label: 'Activate', name: 'activate' },
    // { label: 'Mark as Shipped', name: 'shipped' },
    { label: 'Preview Invoice', name: 'preview' },
    { label: 'Download Invoice', name: 'download' }
 ];
const columns = [
    { label: 'Number', fieldName: 'orderLink', type: 'url' , typeAttributes: 
    { label: { fieldName: "Number" }, tooltip:"Number", target: "_blank" }},
    { label: 'Date', fieldName: 'Date', type: 'date' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency', 
        typeAttributes: { currencyCode: 'USD' },
    },
    { label: 'Invoice', fieldName: 'Invoice'},
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
]

export default class AccountOrdersRelatedList extends LightningElement {

    
    @api recordId;
    @track data = []
    @track columns = columns;
    @track showLoadingSpinner = false;
    refreshTable;
    error;
    subscription = {};
    CHANNEL_NAME = '/event/RefreshDataTable__e';

    @wire (getOrders, {accountId: '$recordId'})
    orders({data, error}) {
        if(data) {
            this.data = data;
            let preparedOrders = [];
            this.data.forEach(order => {
                let preparedOrder = {};
                preparedOrder.Id = order.id;
                preparedOrder.orderLink = "/" + order.id;
                preparedOrder.Number = order.orderNumber;
                preparedOrder.Date = order.orderDate;               
                preparedOrder.Status = order.status;
                preparedOrder.Amount = order.amount;
                preparedOrders.push(preparedOrder);
        });
        this.data = preparedOrders;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error!", 
                    message: error.body.message, 
                    variant: 'error'
                })
            );
        }
    }

    constructor() {
        super();
        this.columns = [
            // Other column data here
            { type: 'action', typeAttributes: { rowActions: this.getRowActions } },
        ]
    }

    getRowActions(row, doneCallback) {
        const actions = [];
            if (row['Draft']) {
                actions.push({
                    'label': 'Activate',
                    'name': 'activate'
                });
            } else {
                actions.push({
                    'label': 'Mark as Shipped',
                    'name': 'shipped'
                });
            }
    }

    handleRowActions() {

    }
}