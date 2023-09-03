import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders'
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder'
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped'

export default class OrderList extends NavigationMixin(LightningElement) {
    @api recordId;

    loading = false;
    orders = [];
    data = [];
    actions = [];

    columns = [
        { 
            label: 'Number', 
            fieldName: 'recordUrl',
            type: 'url',
            typeAttributes: { label: { fieldName: 'orderNumber' }, target: '_blank' },
        },
        { 
            label: 'Date', 
            fieldName: 'startDate',
            type: 'date'
        },
        { 
            label: 'Status', 
            fieldName: 'status'
        },
        { 
            label: 'Shipped?', 
            fieldName: 'isShipped',
            type: 'boolean'
        },
        {
            label: 'Amount',
            fieldName: 'amount',
            type: 'currency',
            typeAttributes: { currencyCode: 'USD', step: '0.01' },
        },
        {
            label: 'Download',
            fieldName: 'downloadInvoice',
            type: 'button-icon',
            typeAttributes: { iconName: 'utility:download', name: 'downloadInvoice', disabled: { fieldName: 'disableDownloadButton'} },
        },
        {
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions },
        },
    ]

    async connectedCallback() {
        await this.refreshView();
    }

    async refreshView() {
        this.loading = true;
        this.data = [];
        try {
            const response = await getOrders({ accountId: this.recordId });
            this.orders = response;
            await this.processResponse(response);
        } catch (err) {
            console.error(err);
        } finally {
            this.loading = false;
        }
    }

    async processResponse(response) {
        response.forEach(async row => {
            this.data.push({
                ...row,
                disableDownloadButton: !row.lastInvoiceId,
                recordUrl: await this.generateRecordUrl(row.orderId)
            })
        })
    }

    getRowActions(row, callback) {
        const actions = [];
        if (row.status === 'Draft') {
            actions.push({ label: 'Activate', name: 'activate' });
        }
        if (row.status === 'Activated' && !row.isShipped) {
            actions.push({ label: 'Mark as Shipped', name: 'markAsShipped' });
        }
        if (row.lastInvoiceId != null) {
            actions.push({ label: 'Preview Invoice', name: 'previewInvoice' });
            actions.push({ label: 'Download Invoice', name: 'downloadInvoice' });
        }
        setTimeout(() => {
            callback(actions);
        }, 200);
    }

    async handleRowAction(event) {
        const actionName = event.detail.action.name;
        const orderId = event.detail.row.orderId;
        if (actionName === 'activate') {
            await this.handleActivateOrder(orderId);
        }
        if (actionName === 'markAsShipped') {
            await this.handleMarkOrderAsShipped(orderId);
        }
        if (actionName === 'previewInvoice') {
            await this.handlePreviewInvoice(orderId);
        }
        if (actionName === 'downloadInvoice') {
            await this.handleDownloadInvoice(orderId);
        }
        await this.refreshView();
    }

    async handleActivateOrder(orderId) {
        const order = this.getOrderById(orderId);
        this.loading = true;
        try {
            const response = await activateOrder({ order: JSON.stringify(order) })
            if (response.status === 'ERROR') {
                throw new Exception(response.message)
            }
        } catch(err) {
            console.error(err);
        } finally {
            this.loading = false;
        }
    }

    async handleMarkOrderAsShipped(orderId) {
        const order = this.getOrderById(orderId);
        this.loading = true;
        try {
            const response = await markOrderAsShipped({ order: JSON.stringify(order) })
            if (response.status === 'ERROR') {
                throw new Exception(response.message)
            }
        } catch(err) {
            console.error(err);
        } finally {
            this.loading = false;
        }
    }

    handlePreviewInvoice(orderId) {
        const order = this.getOrderById(orderId);
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: order.lastInvoiceId
            }
        })
    }

    handleDownloadInvoice(orderId) {
        const order = this.getOrderById(orderId);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/sfc/servlet.shepherd/document/download/${order.lastInvoiceId}`
            }
        })
    }

    getOrderById(orderId) {
        return this.orders.find(item => item.orderId === orderId);
    }

    async generateRecordUrl(recordId) {
        return await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view',
            },
        })
    }
}