import { LightningElement, api, track } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import getOrdersCount from '@salesforce/apex/AccountOrdersController.getOrdersCount';
import getPageSize from '@salesforce/apex/AccountOrdersController.getUserPageSize';
import setPageSize from '@salesforce/apex/AccountOrdersController.saveUserPageSize';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountOrders extends NavigationMixin(LightningElement) {
    @api recordId;
    @track orders;
    @track selectedRows = new Map();
    
    pageSize;
    totalOrders;
    pageSizeOptions = [
        { label: '10', value: 10 },
        { label: '25', value: 25 },
        { label: '50', value: 50 },
        { label: '100', value: 100 },
        { label: '200', value: 200 },
    ];
    currentPage = 1;

    isLoading = false;

    get totalPages() {
        return Math.ceil(this.totalOrders / this.pageSize);
    }
    get isGroupActivate() {
        return this.checkSelectedRowsStatuses('Draft');
    }

    get isGroupShip() {
        return this.checkSelectedRowsStatuses('Activated');
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    async connectedCallback() {
        this.pageSize = await getPageSize();
        this.totalOrders = await getOrdersCount({accountId: this.recordId});
        this.refreshView();
    }

    checkSelectedRowsStatuses(status) {
        if (this.selectedRows.size == 0) {
            return true;
        }
        let notAllDraft = false;
        this.selectedRows.forEach((value) => {
            if (value !== status) {
                notAllDraft = true;
            }
        });
        return notAllDraft;
    }

    getRowActions(status, isInvoiceDisabled) {
        const actions = [];
        if (status === 'Draft') {
            actions.push({ label: 'Activate', value: 'activate' });
        }
        if (status === 'Activated') {
            actions.push({ label: 'Mark as Shipped', value: 'mark_as_shipped' });
        }
        if (!isInvoiceDisabled) {
            actions.push({ label: 'Preview Invoice', value: 'preview_invoice' });
            actions.push({ label: 'Download Invoice', value: 'download_invoice' });
        }

        return actions;
    }

    refreshView() {
        this.isLoading = true;
        getOrders({accountId: this.recordId,
                    page: this.currentPage,
                    pageSize: this.pageSize})
            .then(data => {
                this.orders = data.map(row => {
                    let rowData = { ...row };
                    rowData.OrderURL = `/lightning/r/Order/${rowData.Id}/view`;
                    rowData.isInvoiceDisabled = rowData.ContentDocumentId ? false : true;

                    const statusTime = row.LastStatusChanged == null ?
                        new Date(row.CreatedDate) :
                        new Date(row.LastStatusChanged);
                    const currentTime = new Date();
    
                    rowData.statusTime = this.calculateTimeDifference(statusTime, currentTime);
                    rowData.statusClassName = this.getStatusClass(rowData.Status);
                    rowData.actionOptions = this.getRowActions(rowData.Status, rowData.isInvoiceDisabled);
                    rowData.hasActions = rowData.actionOptions.length > 0 ? true : false;

                    return rowData;
                });
                this.error = undefined;
                this.isLoading = false;
                this.selectedRows = new Map();               
            })
            .catch(error => {
                console.error('Error received: ', error);
            });
    }

    getStatusClass(status) {
        if (status === 'Draft') {
            return 'status-draft';
        } else if (status === 'Activated') {
            return 'status-activated';
        } else if (status === 'Shipped') {
            return 'status-shipped';
        } else if (status === 'Delivered') {
            return 'status-delivered';
        }
        return '';
    }

    showToast(title, message) {
        const variant = title === 'OK' ? 'success' : 'error';
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }

    navigateToPage(fileId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: fileId,
                actionName: 'view'
            }
        });
    }

    formatTimeDifference(timeDifferenceInSeconds) {
        if (timeDifferenceInSeconds < 3600) {
            return Math.floor(timeDifferenceInSeconds / 60) + ' minutes in ';
        } else if (timeDifferenceInSeconds < 86400) {
            return Math.floor(timeDifferenceInSeconds / 3600) + ' hours in ';
        } else if (timeDifferenceInSeconds < 2592000) {
            return Math.floor(timeDifferenceInSeconds / 86400) + ' days in ';
        } else if (timeDifferenceInSeconds < 31536000) {
            return Math.floor(timeDifferenceInSeconds / 2592000) + ' months in';
        } else {
            return Math.floor(timeDifferenceInSeconds / 31536000) + ' years in ';
        }
    }
    
    calculateTimeDifference(startDate, endDate) {
        const timeDifferenceInSeconds = Math.floor((endDate - startDate) / 1000);
        return this.formatTimeDifference(timeDifferenceInSeconds);
    }

    downloadInvoice(downloadUrl) {
        window.open(downloadUrl);
    }
    
    handleClickOnOrder(event) {
        const orderId = event.currentTarget.dataset.id;
        this.navigateToPage(orderId);
    }

    handleInvoiceButton(event) {
        const invoiceUrl = event.currentTarget.getAttribute('data-invoice-url');
        this.downloadInvoice(invoiceUrl);
    }

    handleActionChange(event) {
        const actionName = event.detail.value;
        const itemId = event.target.getAttribute('data-order-id');
        let invoiceId;
        let invoiceUrl;

        switch (actionName) {
            case 'activate':
                this.handleActivateOrder(itemId);
                break;
            case 'mark_as_shipped':
                this.handleMarkAsShipped(itemId);
                break;
            case 'preview_invoice':
                invoiceId = event.target.getAttribute('data-invoice-id');
                this.navigateToPage(invoiceId);
                break;
            case 'download_invoice':
                invoiceUrl = event.target.getAttribute('data-invoice-url');
                this.downloadInvoice(invoiceUrl);
                break;
        }
    }

    handleActivateOrder(itemId) {
        const items = [itemId];
        activateOrder({ orderIds: items })
            .then(result => {
                this.refreshView.call(this);
                this.showToast(result.status, result.ErrorMessage);
            })
            .catch(() => {
                this.showToast('ERROR', 'An unexpected error occurred.');
            });
    }

    handleMarkAsShipped(itemId) {
        const items = [itemId];
        markOrderAsShipped({ orderIds: items })
            .then(result => {
                this.refreshView.call(this);
                this.showToast(result.status, result.ErrorMessage);
            })
            .catch(() => {
                this.showToast('ERROR', 'An unexpected error occurred.');
            });
    }

    handleRowCheckbox(event) {
        const rowId = event.target.dataset.id;
        const isChecked = event.target.checked;
        const status = event.target.dataset.status;
        let localMap = this.selectedRows.size ? this.selectedRows : new Map();

        if (isChecked) {
            localMap.set(rowId, status);
        } else {
            localMap.delete(rowId);
        }
        this.selectedRows = new Map([...localMap]);
    }

    handleActivateOrders() {
        const orderIds = [...this.selectedRows.keys()];
        let confirmation = confirm(`Do you confirm to activate ${this.selectedRows.size} of Draft order(s)?`);
        if (confirmation) {
            activateOrder({ orderIds: orderIds })
                .then(result => {
                    this.refreshView.call(this);
                    this.showToast(result.status, result.ErrorMessage);
                })
                .catch(() => {
                    this.showToast('ERROR', 'An unexpected error occurred.');
            });
        }
    }

    handleShipOrders() {
        const orderIds = [...this.selectedRows.keys()];
        let confirmation = confirm(`Do you confirm to mark as sent ${this.selectedRows.size} of activated order(s)?`);
        if (confirmation) {
            markOrderAsShipped({ orderIds: orderIds })
                .then(result => {
                    this.refreshView.call(this);
                    this.showToast(result.status, result.ErrorMessage);
                })
                .catch(() => {
                    this.showToast('ERROR', 'An unexpected error occurred.');
                });
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.refreshView.call(this);
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.refreshView.call(this);
        }
    }

    async handlePageSizeChange(event) {
        this.pageSize = event.target.value;
        await setPageSize({pageSize: this.pageSize});
        this.refreshView.call(this);
    }
}


