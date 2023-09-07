import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import LightningConfirm from 'lightning/confirm';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import moveOrdersToActivatedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToActivatedStatus';
import moveOrdersToShippedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToShippedStatus';
import MOMENT_JS from '@salesforce/resourceUrl/momentjs';

const PREVIEW_ROWS_COUNT = 5;
const CARD_STATE_PREVIEW = 'preview';
const CARD_STATE_SHOW_ALL = 'show-all';
const CARD_BODY_BASE_CSS_CLASSES = 'slds-card__body slds-card__body_inner ';

const ORDER_UPDATE_RESPONSE_STATUS_OK = 'ok';
const TOAST_TITLE_SUCCESS = 'Success!';
const TOAST_TITLE_ERROR = 'Error!';
const TOAST_MESSAGE_SUCCESS = 'Order status was successfuly updated!';
const TOAST_VARIANT_SUCCESS = 'success';
const TOAST_VARIANT_ERROR = 'error';
const TOAST_MODE_STICKY = 'sticky';
const CONFIRM_MESSAGE_DO_YOU_CONFIRM_TO_ACTIVATE_X_OF_DRAFT_ORDERS = 'Do you confirm to activate {0} of Draft order(s)?';
const CONFIRM_MESSAGE_DO_YOU_CONFIRM_TO_MARK_AS_SENT_X_OF_ACTIVATED_ORDERS = 'Do you confirm to mark as sent {0} of activated order(s)?';

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

    _totalOrders = 0;

    allRowsSelected = false;

    showActivateOrdersButton = false;

    showMarkOrdersAsSentButton = false;

    /**
     * @description orders: Currently shown data.
     */
    @track
    orders;

    async connectedCallback() {
        await loadScript(this, MOMENT_JS);
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

    get showBulkUpdateButtons() {
        return this.showActivateOrdersButton || this.showMarkOrdersAsSentButton;
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
        this._displayToastWithSaveResult(result);
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
        this._displayToastWithSaveResult(result);
    }

    /**
     * @description handleSelectAllClick: Handler for "Select All" checkbox click.
     * Toggle "isSelected" flag on all orders and refrehses bulk update actions visibility.
     * @param {Object} event: Event with details about new state of the "Select All" checkbox.
     */
    handleSelectAllClick(event) {
        this.allRowsSelected = event.target.checked;
        for (let i = this.orders.data.length; i--;) {
            this.orders.data[i].isSelected = this.allRowsSelected;
        }
        this._refreshShowActivateOrdersButtonFlag();
        this._refreshShowMarkOrdersAsSentButtonFlag();
    }

    /**
     * @description handleSelectRowClick: Handler for "Select Row" checkbox click.
     * Toggle "isSelected" flag on single orders and refrehses bulk update actions visibility.
     * @param {Object} event: Event with details about toggled order and new flag state.
     */
    handleSelectRowClick(event) {
        const index = event.target.dataset.index;
        this.orders.data[index].isSelected = event.target.checked;
        this._refreshShowActivateOrdersButtonFlag();
        this._refreshShowMarkOrdersAsSentButtonFlag();
        this._refreshAllRowsSelectedFlag();
    }

    /**
     * @description handleActivateOrdersClick: Handler for "Activate" button click.
     * Moves selected order(s) to "Activated" Status in bulk.
     */
    async handleActivateOrdersClick() {
        const scope = this._getSelectedOrdersToActivate();
        const decision = await LightningConfirm.open({
            message: CONFIRM_MESSAGE_DO_YOU_CONFIRM_TO_ACTIVATE_X_OF_DRAFT_ORDERS.replace('{0}', scope.length)
        });
        if (!decision) {
            return;
        }
        let recordIds = scope.map((o) => { return o.recordId });
        const result = await moveOrdersToActivatedStatus({ orderIds: recordIds });
        await this._getOrders();
        this._isUpdatingOrder = false;
        this._displayToastWithSaveResult(result);
    }

    /**
     * @description handleMarkOrdersAsSentClick: Handler for "Mark as Sent" button click.
     * Moves selected order(s) to "Shipped" Status in bulk.
     */
    async handleMarkOrdersAsSentClick() {
        const scope = this._getSelectedOrdersToMarkAsSent();
        const decision = await LightningConfirm.open({
            message: CONFIRM_MESSAGE_DO_YOU_CONFIRM_TO_MARK_AS_SENT_X_OF_ACTIVATED_ORDERS.replace('{0}', scope.length)
        });
        if (!decision) {
            return;
        }
        let recordIds = scope.map((o) => { return o.recordId });
        const result = await moveOrdersToShippedStatus({ orderIds: recordIds });
        await this._getOrders();
        this._isUpdatingOrder = false;
        this._displayToastWithSaveResult(result);
    }

    _refreshAllRowsSelectedFlag() {
        this.allRowsSelected = this.orders?.data?.every((o) => {
            return o.isSelected;
        }) || false;
    }

    _refreshShowActivateOrdersButtonFlag() {
        this.showActivateOrdersButton = this._getSelectedOrdersToActivate().length > 0;
    }

    _refreshShowMarkOrdersAsSentButtonFlag() {
        this.showMarkOrdersAsSentButton = this._getSelectedOrdersToMarkAsSent().length > 0;
    }

    _getSelectedOrdersToActivate() {
        return this.orders?.data?.filter((o) => {
            return o.canBeActivated && o.isSelected;
        }) || [];
    }

    _getSelectedOrdersToMarkAsSent() {
        return this.orders?.data?.filter((o) => {
            return o.canBeShipped && o.isSelected;
        }) || [];
    }

    _displayToastWithSaveResult(result) {
        console.clear();
        console.log(result);
        if (ORDER_UPDATE_RESPONSE_STATUS_OK === result.status) {
            this.dispatchEvent(new ShowToastEvent({
                title: TOAST_TITLE_SUCCESS, variant: TOAST_VARIANT_SUCCESS, message: TOAST_MESSAGE_SUCCESS
            }));
        } else {
            result.errorMessages.forEach((em) => {
                this.dispatchEvent(new ShowToastEvent({
                    title: TOAST_TITLE_ERROR, variant: TOAST_VARIANT_ERROR, message: em, mode: TOAST_MODE_STICKY
                }));
            });
        }
    }

    /**
     * @description _getOrders: Helper method used to load Orders data
     * related to opened Account. 
     */
    async _getOrders() {
        try {
            this._isLoadingOrders = true;
            //Deep clone so it is possible to create new properties as necessary.
            let response = JSON.parse(JSON.stringify(await getOrders({ accountId: this.recordId })));
            this._totalOrders = response.length;
            //Drop records which cannot be shown at preview state (if necessary).
            const trunc = CARD_STATE_PREVIEW === this._cardState && PREVIEW_ROWS_COUNT <= this._totalOrders;
            response = trunc ? response.slice(0, PREVIEW_ROWS_COUNT) : response;
            //Add UI-only properties.
            for (let i = response.length; i--;) {
                //timeInCurrentStatus - time from now in Current Status (non-Apex based solution because of possible maintenance issues).
                response[i].timeInCurrentStatus
                    = response[i].lastStatusChanged ? moment().from(response[i].lastStatusChanged, true) : undefined;
                //isSelected - indicates does or not row action checkbox is checked.
                response[i].isSelected = false;
            }
            this.orders = { data: response, error: undefined };
        } catch (error) {
            this.orders = { data: undefined, error: error };
        } finally {
            this._isLoadingOrders = false;
            this._refreshShowActivateOrdersButtonFlag();
            this._refreshShowMarkOrdersAsSentButtonFlag();
            this._refreshAllRowsSelectedFlag();
        }
    }
}