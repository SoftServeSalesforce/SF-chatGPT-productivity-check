import { LightningElement, api, wire } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';


export default class AccountOrders extends LightningElement {
    @api recordId;

    orderInfos

    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        console.log('error', error);
        console.log('data', data);
        console.log(JSON.stringify(data));
        // if (data) {
        //     this.orderInfos = data;
        // }
    };

    get title() {
        return `Orders (${this.orderInfos?.data?.length || '0'})`;
    }

    get showSpinner() {
        return this.orderInfos && !Object.hasOwn(this.orderInfos, 'data');
    }

    get showData() {
        return 0 < this.orderInfos?.data?.length;
    }

    get showError() {
        return this.orderInfos?.error ? true : false;
    }

    get showNoDataReturned() {
        return !this.showData && !this.showError && 0 >= this.orderInfos?.data?.length;
    }

}