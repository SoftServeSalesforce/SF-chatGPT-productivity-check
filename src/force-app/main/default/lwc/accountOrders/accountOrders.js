import { LightningElement, api, wire } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';


export default class AccountOrders extends LightningElement {
    /**
     * @description recordId: Id of the currently opened Account record.
     */
    @api recordId;

    /**
     * @description orderInfos: Property used to store details about
     * Orders to be shown.
     */
    @wire(getOrders, { accountId: '$recordId' })
    orderInfos;

    /**
     * @description title: Getter used to reactively render component title.
     */
    get title() {
        return `Orders (${this.orderInfos?.data?.length || '0'})`;
    }

    /**
     * @description showSpinner: Getter used to conditionally render component load spinner
     * while Orders data is being loaded.
     */
    get showSpinner() {
        return !Object.hasOwn(this.orderInfos || {}, 'data');
    }

    /**
     * @description showData: Getter used to conditionally render table with Order details
     * (if there is any to display).
     */
    get showData() {
        return 0 < this.orderInfos?.data?.length;
    }

    /**
     * @description showError: Getter used to conditionally render error message
     * (if any returned).
     */
    get showError() {
        return this.orderInfos?.error ? true : false;
    }

    /**
     * @description showNoRelatedOrdersMsg: Getter used to conditionally render notification
     * message if there are no Orders related to given Account.
     */
    get showNoRelatedOrdersMsg() {
        return !this.showData && !this.showError && 0 >= this.orderInfos?.data?.length;
    }

}