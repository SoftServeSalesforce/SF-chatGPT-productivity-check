import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import moveOrdersToActivatedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToActivatedStatus';
import moveOrdersToShippedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToShippedStatus';

const PREVIEW_ROWS_COUNT = 5;
const CARD_STATE_PREVIEW = 'preview';
const CARD_STATE_SHOW_ALL = 'show-all';
const CARD_BODY_BASE_CSS_CLASSES = 'slds-card__body slds-card__body_inner ';

const ORDER_UPDATE_RESPONSE_STATUS_OK = 'ok';
const TOAST_TITLE_SUCCESS = 'Success!';
const TOAST_TITLE_ERROR = 'Error!';
const TOAST_MESSAGE_SUCCESS = 'Order status was successfuly updated!';
const TOAST_MESSAGE_ERROR_TEMPLATE = 'Invalid Operation for Order #{0}.';
const TOAST_VARIANT_SUCCESS = 'success';
const TOAST_VARIANT_ERROR = 'error';

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
     * @description _isLoadingOrders: Orders data load indicator.
     * When set, component load spinner is shown.
     */
    _isLoadingOrders = true;

    /**
     * @desciption _isUpdatingOrder: Order update indicator. Set to "true" when
     * update is in progress. Once set, component load spinner is shown.
     */
    _isUpdatingOrder = false;

    /**
     * @description orders: Currently shown data.
     */
    @track
    orders;

    _totalOrders = 0;

    async connectedCallback() {
        await this._getOrders();
    }

    /**
     * @description title: Getter used to reactively render component title.
     */
    get title() {
        return `Orders (${this._totalOrders})`;
    }

    /**
     * @description showSpinner: Getter used to conditionally render component's
     * load spinner while Orders data is being loaded.
     */
    get showSpinner() {
        return this._isLoadingOrders || this._isUpdatingOrder;
    }

    /**
     * @description showData: Getter used to conditionally render table with Order details
     * (if there is any to display).
     */
    get showData() {
        return 0 < this.orders?.data?.length;
    }

    /**
     * @description showError: Getter used to conditionally render error message
     * (if any returned).
     */
    get showError() {
        return this.orders?.error;
    }

    /**
     * @description cardBodyCSSClasses: Getter used to conditionally render component's body
     * based on a "_cardState" property value.
     */
    get cardBodyCSSClasses() {
        return CARD_BODY_BASE_CSS_CLASSES + (CARD_STATE_PREVIEW === this._cardState ? CARD_STATE_PREVIEW : CARD_STATE_SHOW_ALL);
    }

    /**
     * @description showNoRelatedOrdersMsg: Getter used to conditionally render notification
     * message if there are no Orders related to given Account.
     */
    get showNoRelatedOrdersMsg() {
        return !this.showData && !this.showError && 0 >= this.orders?.data?.length;
    }

    /**
     * @description showViewAll: Getter used to conditionally render "View All" button.
     */
    get showViewAll() {
        return PREVIEW_ROWS_COUNT < this._totalOrders && this._cardState !== CARD_STATE_SHOW_ALL;
    }

    /**
     * @description handleViewAllClick: Handler for "View All" button click.
     * Changes "_cardState" to "CARD_STATE_SHOW_ALL".
     * @param {Object} event: Event to handle.
     */
    async handleViewAllClick(event) {
        this._cardState = CARD_STATE_SHOW_ALL;
        await this._getOrders();
    }

    /**
     * @description handleActivateOrderClick: Handler for "Activate"
     * button click. Attempts to move given Order to "Activated" Status.
     * @param {Object} event: Event with Order details.
     */
    async handleActivateOrderClick(event) {
        this._isUpdatingOrder = true;
        const recordId = event.target.dataset.recordId;
        const result = await moveOrdersToActivatedStatus({ orderIds: [recordId] });
        await this._getOrders();
        this._isUpdatingOrder = false;
        this._handleOrderStatusChangeResult(recordId, result);
    }

    /**
     * @description handleMarkAsShippedClick: Handler for "Mart as Shipped"
     * button click. Attempts to move given Order to "Shipped" Status.
     * @param {Object} event: Event with Order details.
     */
    async handleMarkAsShippedClick(event) {
        this._isUpdatingOrder = true;
        const recordId = event.target.dataset.recordId;
        const result = await moveOrdersToShippedStatus({ orderIds: [recordId] });
        await this._getOrders();
        this._isUpdatingOrder = false;
        this._handleOrderStatusChangeResult(recordId, result);
    }

    /**
     * @description _handleOrderStatusChangeResult: Helper method used to handle
     * Order "Status" update result by showing toast message.
     * @param {String} recordId: Record to update Id.
     * @param {Object} result: Update result. 
     */
    _handleOrderStatusChangeResult(recordId, result) {
        this.dispatchEvent(new ShowToastEvent({
            title: this._buildToastTitleOnOrderUpdate(result),
            message: this._buildToastMessageOnOrderUpdate(recordId, result),
            variant: this._buildToastVariantOnOrderUpdate(result)
        }));
    }

    _buildToastTitleOnOrderUpdate(result) {
        return ORDER_UPDATE_RESPONSE_STATUS_OK === result.status ? TOAST_TITLE_SUCCESS : TOAST_TITLE_ERROR;
    }

    _buildToastMessageOnOrderUpdate(recordId, result) {
        let message;
        if (ORDER_UPDATE_RESPONSE_STATUS_OK === result.status) {
            message = TOAST_MESSAGE_SUCCESS;
        } else {
            const o = this.orders.data.find((order) => {
                return order.recordId === recordId
            });
            message = TOAST_MESSAGE_ERROR_TEMPLATE.replace('{0}', o?.orderNumber);
        }
        return message;
    }

    _buildToastVariantOnOrderUpdate(result) {
        return ORDER_UPDATE_RESPONSE_STATUS_OK === result.status ? TOAST_VARIANT_SUCCESS : TOAST_VARIANT_ERROR;
    }

    /**
     * @description _getOrders: Helper method used to load Orders data
     * related to opened Account. 
     */
    async _getOrders() {
        try {
            this._isLoadingOrders = true;
            //Deep clone so it is possible to create new properties as necessary.
            let response = await getOrders({ accountId: this.recordId });
            this._totalOrders = response.length;
            //Drop records which cannot be shown at preview state (if necessary).
            const trunc = CARD_STATE_PREVIEW === this._cardState && PREVIEW_ROWS_COUNT <= this._totalOrders;
            this.orders = {
                data: trunc ? response.slice(0, PREVIEW_ROWS_COUNT) : response,
                error: undefined
            };
        } catch (error) {
            this.orders = { data: undefined, error: error };
        } finally {
            this._isLoadingOrders = false;
        }
    }
}