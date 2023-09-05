import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrders from '@salesforce/apex/AccountOrdersController.activateOrders';
import markOrdersAsShipped from '@salesforce/apex/AccountOrdersController.markOrdersAsShipped';

import LightningConfirm from 'lightning/confirm';


export default class OrdersListView extends NavigationMixin(LightningElement) {
    @api recordId; // Assuming this component is on a record page and the recordId is the Account Id
    @track orders = [];
    @track selectedOrders = [];
    recordsAmountOnPage = '10';
    currentPage = 0;
    availableRecordAmounts = [
        { value: '10', label: '10' },
        { value: '20', label: '20' },
        { value: '50', label: '50' },
        { value: '100', label: '100' },
    ];
    wireResult;

    connectedCallback() {
        this.recordsAmountOnPage = localStorage.getItem('recordsAmountOnPage') || '10';
    }
    
    @wire(getOrders, { accountId: '$recordId', recordsAmount: '$recordsAmountOnPage', currentPage: '$currentPage' })
    wiredOrders(response) {
        this.wireResult = response;
        if(response.data) {
            this.orders = response.data;
            this.error = undefined;
        } else if(response.error) {
            this.error = response.error;
            this.orders = undefined;
        }
    }

    createNewOrder() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Order',
                actionName: 'new'
            }
        });
    }

    navigateToOrderRecord(event) {
        const orderId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orderId,
                actionName: 'view'
            }
        });
    }

    handleMenuSelect(event) {
        const combinedValue = event.detail.value;
        const action = combinedValue.split('_')[0];
        const recordId = combinedValue.split('_')[1];
        switch (action) {
            case 'activate':
                this.handleActivateOrder(recordId);
                break;
            case 'markShipped':
                this.handleMarkAsShipped(recordId);
                break;
            case 'previewInvoice':
                this.handlePreviewInvoice(recordId);
                break;
            case 'downloadInvoice':
                this.handleDownloadInvoice(recordId);
                break;
            default:
                console.error('Unknown action: ' + action);
                break;
        }
    }

    handleMenuBulkSelect(event) {
        const action = event.detail.value;
        const selectedIds = this.selectedOrders.map((order) => order.orderId);
        switch (action) {
            case 'activate':
                this.handleActivateBulkWithConfirm(selectedIds);
                break;
            case 'markShipped':
                this.handleMarkShippedBulkWithConfirm(selectedIds);
                break;
            case 'refresh':
                refreshApex(this.wireResult);
                break;
            default:
                console.error('Unknown action: ' + action);
                break;
        }
    }

    async handleActivateBulkWithConfirm(orderIds) {
        let number = orderIds.length;
        let message = `Do you confirm to activate ${number} of Draft order(s)?`;
        let variant = 'warning';
        let label = 'Confirm action';
        let isConfirmed = await this.showConfirmation(message, variant, label);
        if (!isConfirmed) {
            return;
        } 
        this.activateOrdersWrap(orderIds);
    }

    async handleMarkShippedBulkWithConfirm(orderIds) {
        let number = orderIds.length;
        let message = `Do you confirm to mark as sent ${number} of activated order(s)?`;
        let variant = 'warning';
        let label = 'Confirm action';
        let isConfirmed = await this.showConfirmation(message, variant, label);
        if (!isConfirmed) {
            return;
        } 
        this.markOrdersAsShippedWrap(orderIds);
    }
    
    activateOrdersWrap(orderIds) {
        activateOrders({ orderIds: orderIds })
        .then(result => {
            if(result.status === 'OK') {
                this.showToast('Success', 'Order activated successfully!', 'success');
                refreshApex(this.wireResult);
            } else {
                this.showToast('Error', result.errorMessage, 'error');
            }
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    markOrdersAsShippedWrap(orderIds) {
        markOrdersAsShipped({ orderIds: orderIds })
            .then(result => {
                if(result.status === 'OK') {
                    this.showToast('Success', 'Order(s) marked as shipped successfully!', 'success');
                    refreshApex(this.wireResult);
                } else {
                    this.showToast('Error', result.errorMessage, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleActivateOrder(orderId) {
        this.activateOrdersWrap([orderId]);
    }
    
    handleMarkAsShipped(orderId) {
        this.markOrdersAsShippedWrap([orderId]);
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    
    handlePreviewInvoice(contentDocumentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: contentDocumentId
            }
        });
    }
    
    handleDownloadInvoiceIcon(event) {
        const contentDocumentId = event.currentTarget.dataset.id;
        this.handleDownloadInvoice(contentDocumentId);
    }

    handleDownloadInvoice(contentDocumentId) {
        window.open(`/sfc/servlet.shepherd/document/download/${contentDocumentId}`);
    }

    get processedOrders() {
        return this.orders.map(order => {
            return {
                ...order,
                isDraft: order.status === 'Draft',
                isActivated: order.status === 'Activated',
                actionsAvailable: order.status === 'Draft' || order.status === 'Activated' || order.contentDocumentId,
                activateValue: 'activate_' + order.orderId,
                markShippedValue: 'markShipped_' + order.orderId,
                previewInvoiceValue: 'previewInvoice_' + order.contentDocumentId,
                downloadInvoiceValue: 'downloadInvoice_' + order.contentDocumentId,
                statusTime: this.getTimeDifference(order.lastStatusChanged),
                statusClass: this.getStatusClass(order.status)
            };
        });
    }

    getTimeDifference(lastChangedDate) {
        let currentDate = new Date();
        let statusDate = new Date(lastChangedDate);
        
        let totalSeconds = Math.floor((currentDate - statusDate) / 1000);

        let years = Math.floor(totalSeconds / (365 * 24 * 60 * 60));
        let months = Math.floor((totalSeconds % (365 * 24 * 60 * 60)) / (30 * 24 * 60 * 60));
        let days = Math.floor((totalSeconds % (30 * 24 * 60 * 60)) / (24 * 60 * 60));
        let hours = Math.floor((totalSeconds % (24 * 60 * 60)) / (60 * 60));
        let minutes = Math.floor((totalSeconds % (60 * 60)) / 60);

        if (years > 0) return this.combineTime('year', years, 'month', months);
        if (months > 0) return this.combineTime('month', months, 'day', days);
        if (days > 0) return this.combineTime('day', days, 'hour', hours);
        if (hours > 0) return this.combineTime('hour', hours, 'minute', minutes);
        return this.formatTime('minute', minutes);
    }

    formatTime(unit, value) {
        return `${value} ${unit}${value > 1 ? 's' : ''}`;
    }

    combineTime(primaryUnit, primaryValue, secondaryUnit, secondaryValue) {
        let result = this.formatTime(primaryUnit, primaryValue);
        if (secondaryValue > 0) result += ' ' + this.formatTime(secondaryUnit, secondaryValue);
        return result;
    }

    getStatusClass(status) {
        switch(status) {
            case 'Draft':
                return 'badge-draft';
            case 'Activated':
                return 'badge-activated';
            case 'Shipped':
                return 'badge-shipped';
            case 'Delivered':
                return 'badge-delivered';
            default:
                return 'badge-draft';
        }
    }

    handleSelectAll(event) {
        const checkboxes = this.template.querySelectorAll("*[name='select-order']");
        const isChecked = event.target.checked;
        checkboxes.forEach(checkbox => {
            checkbox.checked = isChecked;
        });
        if (isChecked) {
            this.selectedOrders = [...this.orders];
            console.log(JSON.stringify(this.selectedOrders));
            return;
        }
        this.selectedOrders = [];
        console.log(JSON.stringify(this.selectedOrders));

    }

    handleSelect(event) {
        const isChecked = event.target.checked;
        const dataOrderId = event.target.dataset.id;
        if(isChecked) {
            let order = this.orders.find(({orderId}) => orderId === dataOrderId);
            this.selectedOrders.push(order);
            console.log(JSON.stringify(this.selectedOrders));

            return;
        }
        this.selectedOrders = this.selectedOrders.filter(({orderId}) => orderId !== dataOrderId);

        console.log(JSON.stringify(this.selectedOrders));
    }


    get disableActivateSelected() {
        if (this.selectedOrders == null || this.selectedOrders.length == 0) {
            return true;
        }
        let nonDraftOrders = this.selectedOrders.filter(({status}) => status !== 'Draft');
        return nonDraftOrders.length != 0
    }

    get disableMarkShippedSelected() {
        if (this.selectedOrders == null || this.selectedOrders.length == 0) {
            return true;
        }
        let nonActiveOrders = this.selectedOrders.filter(({status}) => status !== 'Activated');
        return nonActiveOrders.length != 0
    }

    get displayCurrentPage() {
        return `${this.currentPage + 1}`;
    }

    get displayedRecordsAmount() {
        return this.orders?.length | 0;
    }


    handleRecordsAmountChange(event) {
        this.recordsAmountOnPage = event.detail.value;
        localStorage.setItem('recordsAmountOnPage', this.recordsAmountOnPage);
    }

    handleNextPage() {
        if(this.orders.length < this.recordsAmountOnPage) {
            return;
        }
        this.currentPage += 1;
    }
    
    handlePrevPage() {
        this.currentPage -= 1;
        if(this.currentPage < 0) {
            this.currentPage = 0;
        }
    }

    get nextPageDisabled() {
        return this.orders.length < this.recordsAmountOnPage;
    }

    get prevPageDisabled() {
        return this.currentPage == 0;
    }

    async showConfirmation(message, variant, label) {
        const result = await LightningConfirm.open({
            message: message,
            variant: variant,
            label: label,
        });
        return result;
    }
}
