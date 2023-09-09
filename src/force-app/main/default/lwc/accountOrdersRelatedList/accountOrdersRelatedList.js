import {api, LightningElement, wire} from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders'
import activateOrderById from '@salesforce/apex/AccountOrdersController.activateOrderById'
import activateOrdersByIds from '@salesforce/apex/AccountOrdersController.activateOrdersByIds';
import markOrderAsShippedById from '@salesforce/apex/AccountOrdersController.markAsShippedOrderById'
import markAsShippedOrdersByIds from '@salesforce/apex/AccountOrdersController.markAsShippedOrdersByIds';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import {refreshApex} from "@salesforce/apex";

export default class AccountOrdersRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    ordersTableData = [];
    wiredOrders;
    selectedOrderIds = [];

    ordersTableColumnsDef = [
        {
            type: 'boolean', fieldName: 'isSelected', label: '', initialWidth: 30
        },
        {
            type: 'url', fieldName: 'orderUrl', label: 'Number',
            typeAttributes: {
                label: {fieldName: 'orderNumber'}, target: '_blank'
            }
        },
        {type: 'date', fieldName: 'startDate', label: 'Date'},
        {
            label: 'Status',
            type: 'customStatusType',
            typeAttributes: {
                duration: {fieldName: 'duration'},
                status: {fieldName: 'status'}
            }
        },
        {
            type: 'currency', fieldName: 'amount', label: 'Amount',
            typeAttributes: {currencyCode: 'USD'}
        },
        {
            type: 'button-icon', label: 'Invoice',
            typeAttributes: {
                iconName: 'utility:download',
                title: 'Invoice',
                variant: 'bare',
                name: 'download_invoice',
                disabled: {fieldName: 'disableDownload'}
            },
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.getRowActions, iconAlternativeText: {fieldName: 'rowAction'}, variant: 'bare'
            }
        }];

    get hasOrders() {
        return this.ordersTableData?.length
    }

    get componentTitle() {
        return `Orders (${this.ordersTableData.length})`;
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
        this.selectedOrderIds = selectedRows.map(row => row.id);
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
        this.handleBulkOrderAction('activate');
    }

    handleBulkMarkShipped() {
        this.handleBulkOrderAction('mark_shipped');
    }

    handleRefresh() {
        this.handleBulkOrderAction('refresh');
    }

    async handleOrderAction(action, orderId) {
        try {
            let result;
            switch (action) {
                case 'activate':
                    result = await activateOrderById({orderId: orderId});
                    break;
                case 'mark_shipped':
                    result = await markOrderAsShippedById({orderId: orderId});
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

    @wire(getOrders, {accountId: '$recordId'})
    relatedOrdersData(value) {
        this.wiredOrders = value;
        const {data, error} = value;
        if (data) {
            this.ordersTableData = data.map((record) => ({
                ...record,
                orderUrl: '/' + record.id,
                disableDownload: !record.contentDocumentId,
                duration: this.getDurationUntilNow(record.lastStatusChangedTimestamp)
            }));
        } else if (error) {
            this.showToast('Error loading orders', 'error', 'Error');
            this.ordersTableData = [];
        }
    }

    getDurationUntilNow(timestamp){
        return timestamp ? Date.now() - Date.parse(timestamp) : undefined;
    }

    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            message: message, variant: variant, title: title
        });
        this.dispatchEvent(event);
    }

}