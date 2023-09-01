import { LightningElement, wire, api } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


const COLUMNS = [
    { label: 'Number', fieldName: 'OrderNumberLink', type: 'url', 
      typeAttributes: { label: { fieldName: 'OrderNumber' }, 
      target: '_blank', tooltip: 'Click to view order' } },
    { label: 'Date', fieldName: 'EffectiveDate', type: 'date' },
    { label: 'Status', fieldName: 'TimeSinceLastStatusChange', type: 'text' },
    { label: 'Amount', fieldName: 'TotalAmount', type: 'currency', 
      typeAttributes: { currencyCode: 'USD' } },
      {
        label: 'Invoice',
         type: 'button-icon',
        initialWidth: 70,
        typeAttributes: {
            iconName: 'utility:download',
            title: 'Download Invoice',
            name: 'download',
            alternativeText: 'Download Invoice',
            variant: 'bare',
            disabled: { fieldName: 'disableDownload' }
            
        }
    }
    

];

export default class OrderListView extends NavigationMixin(LightningElement) {
    @api recordId; // Account Id passed from the parent record context

    columns = COLUMNS;
    orders = [];

    constructor() {
        super();
        this.columns = this.columns.concat( [
            { type: 'action', typeAttributes: { rowActions: this.getRowActions } }
        ] );
    }



    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders({ data, error }) {   
            if (data) {     
                this.orders = data.map(order => {
                    return {
                        ...order,
                        disableDownload: !order.hasInvoiceFiles,
                        OrderNumberLink: `/${order.Id}` // Construct the link to the Order record
                    };
                   
                });    
            } else if (error) {
                this.showToast('Error', 'An error occurred while loading your orders', 'error');
        }
    }

    getRowActions( row, doneCallback ) {

        const actions = [];
        if (row[ 'Status' ] === 'Draft') {
            actions.push({ label: 'Activate', name: 'activate' });
        }
        if (row[ 'Status' ] === 'Activated') {
            actions.push({ label: 'Mark As Shipped', name: 'markShipped' });
        }
        if (row.hasInvoiceFiles) {
            actions.push({ label: 'Preview Invoice', name: 'previewInvoice' });
        }
        if (row.hasInvoiceFiles) {
            actions.push({ label: 'Download Invoice', name: 'downloadInvoice' });
        }
        setTimeout( () => {
            doneCallback( actions );
        }, 200 );

    }

   

    handleDownload(event) {
        const row = event.target.dataset.row;
        const FileId =row.FileId;
        const downloadLink = document.createElement('a');
                downloadLink.href = `/sfc/servlet.shepherd/document/download/${FileId}`;
                downloadLink.download = 'InvoiceFile'; // You can set a default file name here
                downloadLink.click();
    }



    handleRowAction(event) {
        const actionType = event.detail.action.name;
        const row = event.detail.row;

        if (actionType === 'activate') {
            this.handleActivate(row.Id);
        } else if (actionType === 'markShipped') {
            this.handleMarkShipped(row.Id);
        }else if (actionType === 'downloadInvoice') {
            this.handleDownloadAction(row.FileId);
        }else if (actionType === 'previewInvoice') {
            this.handlePreviewAction(row.FileId);
        }else if (actionType === 'download') {
            this.handleDownloadAction(row.FileId);
        }          

    }

    handleDownloadAction(fileIds){
        const FileId =fileIds;
        const downloadLink = document.createElement('a');
                downloadLink.href = `/sfc/servlet.shepherd/document/download/${FileId}`;
                downloadLink.download = 'InvoiceFile'; 
                downloadLink.click();
    }

   handlePreviewAction(file){
        
        const FileIds =file;
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: FileIds
            }
        })
        
    }

    handleActivate(orderId) {
        activateOrder({ orderId: orderId })
            .then(result => {
                if (result.status === 'OK') {
                    console.log('here ok');
                    this.showToast('Success', 'Order activated successfully.', 'success');
                   
                } else {
                    console.log('here NOT ok');
                    this.showToast('Error', result.ErrorMessage, 'error');
                }
            })
            .catch(error => {
                console.log('exception');
                this.showToast('Error', 'An error occurred while activating the order.', 'error');
            });
    }

    handleMarkShipped(orderId) {
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                if (result.status === 'OK') {
                    this.showToast('Success', 'Order marked as shipped successfully.', 'success');
                   
                } else {
                    this.showToast('Error', result.ErrorMessage, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while marking the order as shipped.', 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
   
}
