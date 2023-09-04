import { LightningElement, track, api, wire } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import moveOrdersToActivatedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToActivatedStatus';
import moveOrdersToShippedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToShippedStatus';

const PREVIEW_ROWS_COUNT = 5;
const CARD_STATE_PREVIEW = 'preview';
const CARD_STATE_SHOW_ALL = 'show-all';
const CARD_BODY_CSS_CLASSES_PREVIEW = 'slds-card__body slds-card__body_inner preview';
const CARD_BODY_CSS_CLASSES_SHOW_ALL = 'slds-card__body slds-card__body_inner show-all';
const ACTION_MENU_CSS_CLASSES_CLOSED = 'slds-dropdown-trigger slds-dropdown-trigger_click';
const ACTION_MENU_CSS_CLASSES_OPEN = 'slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';

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
     * @desciption _isUpdatingOrder: Order update indicator. Set to "true" when
     * update is in progress. Once set, component load spinner is shown.
     */
    _isUpdatingOrder = false;

    /**
     * @description dataToDisplay: Currently shown data.
     */
    @track
    dataToDisplay;

    /**
     * @description orderInfos: All data returned by Apex controller.
     */
    _orderInfos;

    /**
     * @description wiredOrders: Method used to get Orders data and make it
     * display-ready.
     * @param {Object} response: Returned information (error and/or data).
     */
    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders(response) {
        this._orderInfos = { data: undefined, error: undefined };
        let info = JSON.parse(JSON.stringify(response));
        if (!info?.data) {
            return;
        }
        for (let i = info.data.length; i--;) {
            this._configureActionsMenu(info.data[i]);
        }
        this._orderInfos = info;
        this._setDataToDisplay();
        console.clear();
        console.log('this._orderInfos?.data', this._orderInfos?.data);
    };

    _configureActionsMenu(dataItem) {
        dataItem.showActionsMenu = dataItem.canBeActivated || dataItem.canBeShipped;
        dataItem.isActionMenuOpen = false;
        dataItem.actionMenuCSSClasses = ACTION_MENU_CSS_CLASSES_CLOSED;
    }

    _setDataToDisplay() {
        if (
            PREVIEW_ROWS_COUNT >= this._orderInfos.length
            || PREVIEW_ROWS_COUNT === this._cardState
        ) {
            this.dataToDisplay = this._orderInfos;
        } else {
            this.dataToDisplay = {
                data: this._orderInfos.data.slice(0, PREVIEW_ROWS_COUNT),
                error: this._orderInfos.error
            };
        }
    }

    /**
     * @description title: Getter used to reactively render component title.
     */
    get title() {
        return `Orders (${this._orderInfos?.data?.length || '0'})`;
    }

    /**
     * @description showSpinner: Getter used to conditionally render component's
     * load spinner while Orders data is being loaded.
     */
    get showSpinner() {
        return !Object.hasOwn(this._orderInfos || {}, 'data') || this._isUpdatingOrder;
    }

    /**
     * @description showData: Getter used to conditionally render table with Order details
     * (if there is any to display).
     */
    get showData() {
        return 0 < this._orderInfos?.data?.length;
    }

    /**
     * @description showError: Getter used to conditionally render error message
     * (if any returned).
     */
    get showError() {
        return this._orderInfos?.error ? true : false;
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
        return !this.showData && !this.showError && 0 >= this._orderInfos?.data?.length;
    }

    /**
     * @description showViewAll: Getter used to conditionally render "View All" button.
     */
    get showViewAll() {
        return PREVIEW_ROWS_COUNT < this._orderInfos?.data?.length && this._cardState !== CARD_STATE_SHOW_ALL;
    }

    /**
     * @description handleViewAllClick: Handler for "View All" button click.
     * Changes "_cardState" to "CARD_STATE_SHOW_ALL".
     * @param {Object} event: Event to handle.
     */
    handleViewAllClick(event) {
        this.dataToDisplay = this._orderInfos;
        this._cardState = CARD_STATE_SHOW_ALL;
    }

    toggleActionsMenu(event) {
        const index = parseInt(event.target.dataset.index);
        for (let i = this.dataToDisplay.data.length; i--;) {
            let dataItem = this.dataToDisplay.data[i];
            if (i != index) {
                //Close other dropdown menus.
                dataItem.isActionMenuOpen = false;
                dataItem.actionMenuCSSClasses = ACTION_MENU_CSS_CLASSES_CLOSED;
            } else {
                //Toggle touched dorpdown menu.
                dataItem.isActionMenuOpen = !dataItem.isActionMenuOpen;
                dataItem.actionMenuCSSClasses = dataItem.isActionMenuOpen ? ACTION_MENU_CSS_CLASSES_OPEN : ACTION_MENU_CSS_CLASSES_CLOSED;
            }
        }
    }

    async handleActivateOrderClick(event) {
        this._isUpdatingOrder = true;
        try {

        } catch (error) {
            //TODO: handle error
        } finally {
            this._isUpdatingOrder = false;
        }
    }

    async handleMarkAsShippedClick(event) {
    }
}