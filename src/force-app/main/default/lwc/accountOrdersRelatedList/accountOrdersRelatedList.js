import { LightningElement, api, wire} from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    { label: 'Number', fieldName: 'orderLink', type: 'url' , typeAttributes: 
    { label: { fieldName: "Number" }, tooltip:"Number", target: "_blank" }},
    { label: 'Date', fieldName: 'Date', type: 'date' },
    { label: 'Status', fieldName: 'Status', type: 'text' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency' }
]

export default class AccountOrdersRelatedList extends LightningElement {

    @api
    recordId;
    result = []
    columns = columns;
   
    @wire (getOrders, {accountId: '$recordId'})
    orders({data, error}) {
        if(data) {
            this.result = data;
            console.log(this.result);
            let preparedOrders = [];
            this.result.forEach(order => {
                let preparedOrder = {};
                preparedOrder.Id = order.id;
                preparedOrder.orderLink = "/" + order.id;
                preparedOrder.Number = order.orderNumber;
                preparedOrder.Date = order.orderDate;               
                preparedOrder.Status = order.status;
                preparedOrder.Amount = order.amount;
                preparedOrders.push(preparedOrder);
        });
        this.result = preparedOrders;
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
}