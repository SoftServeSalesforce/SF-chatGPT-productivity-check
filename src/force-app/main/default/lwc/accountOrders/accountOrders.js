import { LightningElement, wire, api, track } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';

export default class AccountOrders extends LightningElement {
    @api recordId;  
    @track orders;
    @track error;

    columns = [
        { label: 'Order Number', fieldName: 'OrderURL', type: 'url', 
          typeAttributes: { label: { fieldName: 'OrderNumber' }, target: '_blank'} },
        { label: 'Start Date', fieldName: 'EffectiveDate', type: 'date' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Amount', fieldName: 'TotalAmount', type: 'currency' }
    ];

    // data  [{"Id":"8017Y000002KMYhQAO","OrderNumber":"00000101","Status":"Draft","TotalAmount":0,"EffectiveDate":"2023-09-07"},
    // {"Id":"8017Y000002KMYDQA4","OrderNumber":"00000100","Status":"Draft","TotalAmount":0,"EffectiveDate":"2023-09-03"}]

    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        if (data) {
            // console.log('data ', JSON.stringify(data));
            for (let dat of data) {
                console.log('dat', dat);
            }
            this.orders = data.map(row => {
                let rowData = { ...row };
                rowData.OrderURL = `/lightning/r/Order/${row.Id}/view`;

                return rowData;
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.orders = undefined;
        }
    }
}

