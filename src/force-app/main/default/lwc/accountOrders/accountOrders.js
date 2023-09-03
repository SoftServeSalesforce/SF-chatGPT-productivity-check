import { LightningElement, api, wire } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';

const PREVIEW_ROWS_COUNT = 6;
const CARD_STATE_PREVIEW = 'preview';
const CARD_STATE_SHOW_ALL = 'show-all';
const CARD_BODY_CSS_CLASSES_PREVIEW = 'slds-card__body slds-card__body_inner preview';
const CARD_BODY_CSS_CLASSES_SHOW_ALL = 'slds-card__body slds-card__body_inner show-all';

export default class AccountOrders extends LightningElement {
    /**
     * @description recordId: Id of the currently opened Account record.
     */
    @api recordId;

    /**
     * @description _cardState: Inner property used store display state of
     * a component's body.
     */
    _cardState = CARD_STATE_PREVIEW;

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
     * @description showSpinner: Getter used to conditionally render component's
     * load spinner while Orders data is being loaded.
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
     * @description cardBodyCSSClasses: Getter used to conditionally render component's body
     * based on a "_cardState" property value.
     */
    get cardBodyCSSClasses() {
        return CARD_STATE_PREVIEW === this._cardState ? CARD_BODY_CSS_CLASSES_PREVIEW : CARD_BODY_CSS_CLASSES_SHOW_ALL;
    }

    /**
     * @description showNoRelatedOrdersMsg: Getter used to conditionally render notification
     * message if there are no Orders related to given Account.
     */
    get showNoRelatedOrdersMsg() {
        return !this.showData && !this.showError && 0 >= this.orderInfos?.data?.length;
    }

    /**
     * @description showViewAll: Getter used to conditionally render "View All" button.
     */
    get showViewAll() {
        return PREVIEW_ROWS_COUNT < this.orderInfos?.data?.length && this._cardState !== CARD_STATE_SHOW_ALL;
    }

    /**
     * @description handleViewAllClick: Handler for "View All" button click.
     * Changes "_cardState" to "CARD_STATE_SHOW_ALL".
     * @param {Object} event: Event to handle.
     */
    handleViewAllClick(event) {
        this._cardState = CARD_STATE_SHOW_ALL;
    }

}