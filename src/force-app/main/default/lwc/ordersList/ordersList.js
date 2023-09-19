import { api, wire, LightningElement } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import getOrdersNumber from '@salesforce/apex/AccountOrdersController.getOrdersNumber';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder'
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped'
import getPageSize from '@salesforce/apex/AccountOrdersController.getPageSize';
import setPageSize from '@salesforce/apex/AccountOrdersController.setPageSize';
import { refreshApex } from "@salesforce/apex";
import {NavigationMixin} from 'lightning/navigation'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

export default class OrdersList extends NavigationMixin(LightningElement) {
    @api recordId;

    ordersData = [];
    selectedRows = [];
    wiredOrdersValue;
    pageSize;
    currentPage = 1;
    limitSize;
    offsetSize = 0;
    totalOrdersNumber = 0;

    ordersColumns = [
        { label: 'Number', fieldName: 'orderNumber', type: 'text' },
        { label: 'Date', fieldName: 'startDate', type: 'date' },
        { label: 'Status', type: 'status',
        typeAttributes: {
            lastStatusChanged: {fieldName: 'lastStatusChanged'},
            status: {fieldName: 'status'}
        } },
        { label: 'Amount', fieldName: 'amount', type: 'currency', 
            typeAttributes: {currencyCode: 'USD'} },
        { type: 'button-icon', label: 'Invoice',
            typeAttributes: {
                iconName: 'utility:download',
                title: 'Invoice',
                variant: 'bare',
                name: 'downloadInvoice',
                disabled: {fieldName: 'disableDownload'}
            },},
        { type: 'action', typeAttributes: { rowActions: this.getActions } }
    ];

    pageSizeOptions = [
        { label: '10', value: '10' },
        { label: '20', value: '20' },
        { label: '50', value: '50' },
        { label: '100', value: '100' }                
      ];

    @wire(getOrders, {accountId: '$recordId', limitSize: '$limitSize', offsetSize: '$offsetSize'})
    wiredOrders(value) {
        this.wiredOrdersValue = value;
        const { data, error } = value;
        if (data) {
            this.ordersData = data.map(order => ({...order, disableDownload: !order.contentDocumentId}) );
        } else if (error) {
            console.error('error loading orders');
        }
    }

    @wire(getPageSize) 
    wiredPageSize({ data, error }) {
        if (data) {
            this.pageSize = '' + data;
            this.limitSize = data;
        } else if (error) {
            console.error('error getting page size: ' + error.message);
        }
    }

    @wire(getOrdersNumber, {accountId: '$recordId'})
    wiredTotalOrdersNumber({ data, error }) {
        if (data) {
            this.totalOrdersNumber = data;
        } else if (error) {
            console.error('error getting orders number: ' + error.message);
        }
    }

    get disableMarkRowsAsShipped(){
        if (this.selectedRows.length === 0){
            return true;
        }
        for (let row of this.selectedRows) {
            if (row.status !== 'Activated') {
                return true;
            }
        }
        return false;
    }
    
    get disableMarkROwsAsActive(){
        if (this.selectedRows.length === 0){
            return true;
        }
        for (let row of this.selectedRows) {
            if (row.status !== 'Draft') {
                return true;
            }
        }
        return false;
    }

    get totalPages(){
        return Math.ceil(this.totalOrdersNumber/this.pageSize)
    }

    get isFirstPage(){
        return (this.currentPage === 1);
    }

    get isLastPage(){
        return (this.currentPage === this.totalPages);
    }

    setLimitSize(){
        this.limitSize = this.currentPage * this.pageSize;
    }
    setOffsetSize(){
        this.offsetSize = (this.currentPage - 1) * this.pageSize;
    }

    getActions(row, doneCallback){
        let actions = [];
        if (row.status === 'Draft') {
            actions.push({ label: 'Activate', name: 'activate'});
        }
        if (row.status === 'Activated') {
            actions.push({ label: 'Mark as Shipped', name: 'markAsShipped'});
        }
        if (!row.disableDownload) {
            actions.push({ label: 'Preview Invoice', name: 'previewInvoice'});
            actions.push({ label: 'Download Invoice', name: 'downloadInvoice'});
        }
        doneCallback(actions);
    }

    handleRowAction(event){
        const row = event.detail.row;
        const action = event.detail.action.name;
        switch (action) {
            case 'activate':
                this.handleActivateOrderAction(row.id);
                break;
            case 'markAsShipped':
                this.handleMarkOrderAsShippedAction(row.id);
                break;
            case 'downloadInvoice':
                this.downloadInvoice(row.contentDocumentId);
                break;
            case 'previewInvoice':
                this.previewInvoice(row.contentDocumentId);
                break;
            default:
        }
    }

    downloadInvoice(contentDocumentId){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage', attributes: {
                url: `/sfc/servlet.shepherd/document/download/${contentDocumentId}`
            }
        });
    }

    previewInvoice(contentDocumentId){
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: contentDocumentId
            }
        })
    }

    async handleActivateOrderAction(orderId){        
        this.activateOrders([orderId]);
    }

    async handleMarkOrderAsShippedAction(orderId){
        this.markOrdersAsShipped([orderId])
    }

    async activateOrders(orderIds){        
        try {
            let result = await activateOrder({orderIds: orderIds});
            if (result.status === 'ERROR') {
                this.showToast(`${result.message}`, 'error', 'Error');
            }
            if (result.status === 'OK') {
                this.showToast(`Order successfully updated`, 'success', 'Success');
            }
        } catch (error) {
            console.error('error updating order: ' + JSON.stringify(error));
        }
    }

    async markOrdersAsShipped(orderIds){
        try {
            let result = await markOrderAsShipped({orderIds: orderIds});
            if (result.status === 'ERROR') {
                this.showToast(`${result.message}`, 'error', 'Error');
            }
            if (result.status === 'OK') {
                this.showToast(`Order successfully updated`, 'success', 'Success');
            }
        } catch (error) {
            console.error('error updating order: ' + JSON.stringify(error));
        }
    }

    async handleActivateOrders(){
        const result = await LightningConfirm.open({
            message: `Do you confirm to activate ${this.selectedRows.length} of Draft order(s)?`,
            label: 'Confirm',
        });
        if (result){  
            this.activateOrders(this.selectedRows.map(e => e.id));
        }
    }

    async handleMarkOrdersAsShipped(){
        const result = await LightningConfirm.open({
            message: `Do you confirm to mark as sent ${this.selectedRows.length} of Draft order(s)?`,
            label: 'Confirm',
        });
        if (result){
            this.markOrdersAsShipped(this.selectedRows.map(e => e.id));
        }
    }

    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            message: message, variant: variant, title: title
        });
        this.dispatchEvent(event);
    }

    handleRowSelection(event){
        this.selectedRows = event.detail.selectedRows;
    }

    handleRefresh() {
        refreshApex(this.wiredOrdersValue);
    }
    
    handlePageSizeChange(event) {
        this.pageSize = event.target.value;
        setPageSize({pageSize: this.pageSize}).catch(error => {
            console.error('Failed to save page size: ', error);
        });
        this.currentPage = 1;
        this.setLimitSize();
        this.setOffsetSize();
        this.handleRefresh();   
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
        }
        this.setLimitSize();
        this.setOffsetSize();
        this.handleRefresh();         
    }

    async handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
        }
        this.setLimitSize();
        this.setOffsetSize();
        this.handleRefresh(); 
    }
}