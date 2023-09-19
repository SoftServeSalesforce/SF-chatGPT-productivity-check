import { api, wire, LightningElement } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder'
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped'
import { refreshApex } from "@salesforce/apex";
import {NavigationMixin} from 'lightning/navigation'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

export default class OrdersList extends NavigationMixin(LightningElement) {
    @api recordId;

    ordersData = [];
    selectedRows = [];
    wiredOrdersValue;

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

    @wire(getOrders, {accountId: '$recordId'})
    wiredOrders(value) {
        this.wiredOrdersValue = value;
        const { data, error } = value;
        if (data) {
            this.ordersData = data.map(order => ({...order, disableDownload: !order.contentDocumentId}) );
        } else if (error) {
            console.error('error loading orders');
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
}