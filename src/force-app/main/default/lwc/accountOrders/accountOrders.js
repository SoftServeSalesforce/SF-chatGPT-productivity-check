import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import LightningConfirm from 'lightning/confirm';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import moveOrdersToActivatedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToActivatedStatus';
import moveOrdersToShippedStatus from '@salesforce/apex/AccountOrdersController.moveOrdersToShippedStatus';
import getPageSizeFromLWCPaginationSetting from '@salesforce/apex/AccountOrdersController.getPageSizeFromLWCPaginationSetting';
import updatePageSizeForLWCPaginationSetting from '@salesforce/apex/AccountOrdersController.updatePageSizeForLWCPaginationSetting';
import MOMENT_JS from '@salesforce/resourceUrl/momentjs';

const PAGE_SIZES = [10, 25, 50, 100, 200];

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

    @api recordId;

    @track
    orders;

    /**
     * Conditional rendeing-related logic.
     */
    _isLoadingLWCPaginationSettings = true;

    _isUpdatingLWCPaginationSettings = false;

    _isLoadingOrders = false;

    _isUpdatingOrder = false;

    _hasNextPage = false;

    _hasPreviousPage = false;

    _totalOrders = 0;

    totalPages = 1;

    pageNumber = 1;

    pageSize = 0;

    allRowsSelected = false;

    showActivateOrdersButton = false;

    showMarkOrdersAsSentButton = false;

    get title() {
        return `Orders (${this._totalOrders})`;
    }

    get showSpinner() {
        return this._isLoadingOrders || this._isUpdatingOrder || this._isLoadingLWCPaginationSettings;
    }

    get showData() {
        return 0 < this._pageEntriesCount;
    }

    get showError() {
        return this.orders?.error;
    }

    get showNoRelatedOrdersMsg() {
        return !this.showData && !this.showError && 0 >= this._pageEntriesCount;
    }

    get _pageEntriesCount() {
        return this.orders?.data?.length || 0;
    }

    get pageSizesOptions() {
        return PAGE_SIZES.map((ps) => {
            return { label: ps, value: ps };
        });
    }

    get disableLeftHandNavigation() {
        return !this._hasPreviousPage;
    }

    get disableRightHandNavigation() {
        return !this._hasNextPage;
    }

    get disablePageSizePicklist() {
        return this._isUpdatingLWCPaginationSettings;
    }

    /**
     * Handlers.
     */
    async connectedCallback() {
        await loadScript(this, MOMENT_JS);
        await this._getLWCPaginationSetting();
        await this._getOrders();
    }

    async handleActivateOrderClick(event) {
        this._isUpdatingOrder = true;
        const recordId = event.target.dataset.recordId;
        const result = await moveOrdersToActivatedStatus({ orderIds: [recordId] });
        await this._getOrders();
        this._isUpdatingOrder = false;
        this._displayToastWithSaveResult(result);
    }

    async handleMarkAsShippedClick(event) {
        this._isUpdatingOrder = true;
        const recordId = event.target.dataset.recordId;
        const result = await moveOrdersToShippedStatus({ orderIds: [recordId] });
        await this._getOrders();
        this._isUpdatingOrder = false;
        this._displayToastWithSaveResult(result);
    }

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

    async handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value);
        await this._updatePageSizeForLWCPaginationSetting();
        await this._getOrders();
    }

    async handleNavigateToFistPageClick() {
        this.pageNumber = 1;
        await this._getOrders();
    }

    async handleNavigateToPreviousPageClick() {
        this.pageNumber--;
        await this._getOrders();
    }

    async handleNavigateToNextPageClick() {
        this.pageNumber++;
        await this._getOrders();
    }

    async handleNavigateToLastPageClick() {
        this.pageNumber = this.totalPages;
        await this._getOrders();
    }

    async handleForceRefreshClick() {
        await this._getOrders();
    }

    handleSelectAllClick(event) {
        this.allRowsSelected = event.target.checked;
        for (let i = this._pageEntriesCount; i--;) {
            this.orders.data[i].isSelected = this.allRowsSelected;
        }
        this._refreshShowActivateOrdersButtonFlag();
        this._refreshShowMarkOrdersAsSentButtonFlag();
    }

    handleSelectRowClick(event) {
        const index = event.target.dataset.index;
        this.orders.data[index].isSelected = event.target.checked;
        this._refreshShowActivateOrdersButtonFlag();
        this._refreshShowMarkOrdersAsSentButtonFlag();
        this._refreshIsSelectedFlagOnAllOrders();
    }

    /**
     * Helper methods.
     */

    async _getLWCPaginationSetting() {
        try {
            this._isLoadingLWCPaginationSettings = true;
            this.pageSize = await getPageSizeFromLWCPaginationSetting({});
        } catch (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        } finally {
            this._isLoadingLWCPaginationSettings = false;
        }
    }

    async _getOrders() {
        try {
            this._isLoadingOrders = true;
            //Deep clone so it is possible to create new properties as necessary.
            let response = JSON.parse(JSON.stringify(await getOrders({
                accountId: this.recordId,
                pageNumber: this.pageNumber,
                pageSize: this.pageSize
            })));
            //Add UI-only properties.
            for (let i = response.orders.length; i--;) {
                let order = response.orders[i];
                //timeInCurrentStatus - time from now in Current Status (non-Apex based solution because of possible maintenance issues).
                order.timeInCurrentStatus = order.lastStatusChanged ? moment().from(order.lastStatusChanged, true) : undefined;
                //isSelected - indicates does or not row action checkbox is checked.
                order.isSelected = false;
            }
            this._hasNextPage = response.hasNextPage;
            this._hasPreviousPage = response.hasPreviousPage;
            this._totalRecords = response.totalRecords;
            this._totalOrders = response.totalOrders;
            this.totalPages = response.totalPages;
            this.pageNumber = response.pageNumber;
            this.orders = { data: response.orders, error: undefined };
        } catch (error) {
            this.orders = { data: undefined, error: error };
        } finally {
            this._isLoadingOrders = false;
            this._refreshShowActivateOrdersButtonFlag();
            this._refreshShowMarkOrdersAsSentButtonFlag();
            this._refreshIsSelectedFlagOnAllOrders();
        }
    }

    async _updatePageSizeForLWCPaginationSetting() {
        try {
            this._isUpdatingLWCPaginationSettings = true;
            await updatePageSizeForLWCPaginationSetting({ pageSize: this.pageSize });
        } catch (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        } finally {
            this._isUpdatingLWCPaginationSettings = false;
        }
    }

    _refreshIsSelectedFlagOnAllOrders() {
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
}