import { api, LightningElement, wire, track } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrderById from '@salesforce/apex/AccountOrdersController.activateOrderById';
import activateOrdersByIds from '@salesforce/apex/AccountOrdersController.activateOrdersByIds';
import markOrderAsShippedById from '@salesforce/apex/AccountOrdersController.markAsShippedOrderById';
import markAsShippedOrdersByIds from '@salesforce/apex/AccountOrdersController.markAsShippedOrdersByIds';
import getPageSize from '@salesforce/apex/AccountOrdersController.getPageSize';
import setPageSize from '@salesforce/apex/AccountOrdersController.setPageSize';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class AccountOrdersRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    ordersTableData = [];
    wiredOrders;
    selectedOrderIds = [];
    pageSizeOptions = [
        { label: '1', value: 1 },
        { label: '10', value: 10 },
        { label: '20', value: 20 },
        { label: '50', value: 50 },
        { label: '100', value: 100 }
    ];
    selectedPageSize;
    currentPage = 1;
    pageSize = 10;
    totalRecords = 0;
    loading = true;

    ordersTableColumnsDef = [
        {
            type: 'customCheckboxType',
            fieldName: 'isSelected',
            label: '',
            initialWidth: 30,
            cellAttributes: { class: 'slds-text-align_center' },
            typeAttributes: { rowId: { fieldName: 'rowId' } }
        },  
        {
            type: 'url',
            fieldName: 'orderUrl',
            label: 'Number',
            typeAttributes: {
                label: { fieldName: 'orderNumber' },
                target: '_blank'
            }
        },
        { type: 'date', fieldName: 'startDate', label: 'Date' },
        {
            label: 'Status',
            type: 'customStatusType',
            typeAttributes: {
                duration: { fieldName: 'duration' },
                status: { fieldName: 'status' }
            }
        },
        {
            type: 'currency',
            fieldName: 'amount',
            label: 'Amount',
            typeAttributes: { currencyCode: 'USD' }
        },
        {
            type: 'button-icon',
            label: 'Invoice',
            typeAttributes: {
                iconName: 'utility:download',
                title: 'Invoice',
                variant: 'bare',
                name: 'download_invoice',
                disabled: { fieldName: 'disableDownload' }
            },
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.getRowActions,
                iconAlternativeText: { fieldName: 'rowAction' },
                variant: 'bare'
            }
        }
    ];

    connectedCallback() {
        console.log('connectedCallback called');
        this.initializePageSize().then(() => {
            this.fetchData();
        }).catch(error => {
            console.error("Error during initialization:", error);
        });
    }    

    async initializePageSize() {
        console.log(1);
        try {
            console.log(2);
            const initialPageSize = await getPageSize();
            console.log('Initial Page Size from Apex:', initialPageSize);
            this.pageSize = parseInt(initialPageSize, 10);
            this.selectedPageSize = this.pageSize;  // Keep it as an integer for consistency
            console.log('Initial Page Size from APEX (after parsing):', this.pageSize);
            console.log('Selected Page Size from APEX (after parsing):', this.selectedPageSize);
        } catch (error) {
            console.log('fail abc');
            console.error("Error initializing page size:", error);
        }
        console.log(3);
    }     

    fetchData() {
        console.log('fetchdata params: ' + this.recordId + ' ' + this.currentPage + ' ' + this.pageSize);
        getOrders({ accountId: this.recordId, pageNumber: this.currentPage, pageSize: this.pageSize })
            .then(result => {
                this.processFetchedData(result);
            })
            .catch(error => {
                console.log('Error fetching data:', JSON.stringify(error));
                this.loading = false;
            });
    }
    
    processFetchedData(result) {
        try {
            console.log('Fetched data: ', JSON.stringify(result));
            this.ordersTableData = result.orders.map((record) => ({
                ...record,
                orderUrl: '/' + record.id,
                isSelected: Boolean(record.isSelected),
                rowId: record.id,
                disableDownload: !record.contentDocumentId,
                duration: this.getDurationUntilNow(record.lastStatusChangedTimestamp)
            }));
            this.totalRecords = result.totalRecords;
            console.log('fetchData totalRecords ' + this.totalRecords);
            this.loading = false;
        } catch (error) {
            console.error('Error processing fetched data:', error);
        }
    }    

    get disablePrevButton() {
        return this.currentPage <= 1;
    }

    get disableNextButton() {
        return this.currentPage >= this.totalPages;
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    get hasPreviousPage() {
        return this.currentPage > 1;
    }

    get hasNextPage() {
        return this.currentPage < this.totalPages;
    }

    get hasOrders() {
        return this.ordersTableData && this.ordersTableData.length > 0;
    }    

    get componentTitle() {
        return `Orders (${this.totalRecords})`;
    }

    getRowActions(row, doneCallback) {
        let actions = [];
        if (row.status === 'Draft') {
            actions.push({
                'label': 'Activate', 'name': 'activate'
            });
        }
        if (row.status === 'Activated') {
            actions.push({
                'label': 'Mark Order as Shipped', 'name': 'mark_shipped'
            });
        }
        if (!row.disableDownload) {
            actions.push({
                'label': 'Download Invoice', 'name': 'download_invoice'
            }, {
                'label': 'Preview Invoice', 'name': 'preview_invoice'
            });
        }
        doneCallback(actions);
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('Selected Rows:', selectedRows);
        this.selectedOrderIds = selectedRows.map(row => row.id);
        console.log('Selected Order IDs:', this.selectedOrderIds);
    }

    handleCheckboxChange(event) {
        console.log('Received event detail:', event.detail);
        
        const isChecked = event.detail.checked;
        const rowId = event.detail.rowId; // Assuming you've added this to the event detail
    
        if (!rowId) {
            console.error('Row ID not found in event detail');
            return;
        }
    
        // Find the corresponding row in the ordersTableData array
        const row = this.ordersTableData.find(row => row.id === rowId);
        if (row) {
            row.isSelected = isChecked;
        }
    
        // Update the selectedOrderIds array based on the checkbox change
        if (isChecked && !this.selectedOrderIds.includes(rowId)) {
            this.selectedOrderIds.push(rowId);
        } else if (!isChecked) {
            this.selectedOrderIds = this.selectedOrderIds.filter(id => id !== rowId);
        }
    
        console.log('Updated Selected Order IDs:', this.selectedOrderIds);
    }
    

    handleRowAction(event) {
        const row = event.detail.row;
        const action = event.detail.action.name;
        switch (action) {
            case 'activate':
                this.handleOrderAction('activate', row.id);
                break;
            case 'mark_shipped':
                this.handleOrderAction('mark_shipped', row.id);
                break;
            case 'download_invoice':
                this.handleDownloadInvoice(row.contentDocumentId);
                break;
            case 'preview_invoice':
                this.handlePreviewInvoice(row.contentDocumentId);
                break;
            default:
        }
    }

    handleDownloadInvoice(contentDocumentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage', attributes: {
                url: `/sfc/servlet.shepherd/document/download/${contentDocumentId}`
            }
        });
    }

    handlePreviewInvoice(contentDocumentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage', attributes: {
                pageName: 'filePreview'
            }, state: {
                selectedRecordId: contentDocumentId
            }
        });
    }

    handleBulkActivate() {
        this.currentPage = 1; // Reset to the first page
        this.handleBulkOrderAction('activate');
    }

    handleBulkMarkShipped() {
        this.currentPage = 1; // Reset to the first page
        this.handleBulkOrderAction('mark_shipped');
    }

    async handleOrderAction(action, orderId) {
        try {
            let result;
            switch (action) {
                case 'activate':
                    result = await activateOrderById({ orderId: orderId });
                    break;
                case 'mark_shipped':
                    result = await markOrderAsShippedById({ orderId: orderId });
                    break;
                default:
            }
            if (result.status !== 'OK') {
                this.showToast(`There was an error updating the order: ${result.errorMessage}`, 'error', 'Error');
            }
        } catch (error) {
            console.error('## error updating order: ' + JSON.stringify(error));
        }
        return refreshApex(this.wiredOrders);
    }

    async handleBulkOrderAction(action) {
        if (this.selectedOrderIds.length === 0) {
            this.showToast('No orders selected', 'warning', 'Warning');
            return;
        }

        try {
            let result;
            switch (action) {
                case 'activate':
                    result = await activateOrdersByIds({ orderIds: this.selectedOrderIds });
                    break;
                case 'mark_shipped':
                    result = await markAsShippedOrdersByIds({ orderIds: this.selectedOrderIds });
                    break;
                case 'refresh':
                    return refreshApex(this.wiredOrders);
                default:
            }

            if (result && result.status !== 'OK') {
                this.showToast(`There was an error updating the orders: ${result.errorMessage}`, 'error', 'Error');
            }
        } catch (error) {
            console.error('## error updating orders: ' + JSON.stringify(error));
        }

        return refreshApex(this.wiredOrders);
    }
    
    @wire(getOrders, { accountId: '$recordId', pageNumber: '$currentPage', pageSize: '$pageSize' })
    wiredOrdersData({ error, data }) {
        console.log('Raw data:', JSON.stringify(data)); // Debugging statement
        if (data) {
            if (Array.isArray(data.orders)) { // Check if data.orders is actually an array
                this.ordersTableData = data.orders.map((record) => ({
                    ...record,
                    orderUrl: '/' + record.id,
                    rowId: record.id,
                    disableDownload: !record.contentDocumentId,
                    duration: this.getDurationUntilNow(record.lastStatusChangedTimestamp)
                }));
                this.totalRecords = data.totalRecords;
            } else {
                console.error('data.orders is not an array:', data.orders); // Debugging statement
            }
            this.loading = false;
        } else if (error) {
            this.showToast('Error loading orders', 'error', 'Error');
            this.ordersTableData = [];
            this.totalRecords = 0;
            this.loading = false;
        }
    }    

    showErrorToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(event);
    }

    get offset() {
        return (this.currentPage - 1) * this.pageSize;
    }

    handlePreviousPage() {
        if (this.hasPreviousPage) {
            this.currentPage--;
            this.fetchData();
        }
    }

    handleNextPage() {
        if (this.hasNextPage) {
            this.currentPage++;
            this.fetchData();
        }
    }

    handleRefresh() {
        this.fetchData();
    }

    handlePageSizeChange(event) {
        this.selectedPageSize = parseInt(event.target.value, 10); // Parse string to integer
        this.pageSize = parseInt(event.target.value, 10); // Parse string to integer
        this.currentPage = 1; // Reset to the first page

        setPageSize({ newSize: this.pageSize })
        .then(result => {
            if (result === 'OK') {
                this.fetchData();
            } else {
                console.error('Failed to set page size:', result);
            }
        })
        .catch(error => {
            console.error('Error setting page size:', error);
        });
    }

    getDurationUntilNow(timestamp) {
        return timestamp ? Date.now() - Date.parse(timestamp) : undefined;
    }

    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            message: message, variant: variant, title: title
        });
        this.dispatchEvent(event);
    }
}