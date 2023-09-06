import { LightningElement, wire } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';

export default class OrdersTable extends LightningElement {
    orders;
    isActive;
    isDraft;

    @wire(getOrders)
    wiredOrders({ error, data }) {
        if (data) {
            this.orders = data.map(order => ({
                ...order,
                isActive: order.orderStatus === 'Active',
                isDraft: order.orderStatus === 'Draft',
                hasInvoice: order.latestInvoiceFileName != ''
            }));
        } else if (error) {
            // Handle error
        }
    }

    // Activate Order method
    activateOrder(event) {
        const orderNumber = event.currentTarget.dataset.number;
        activateOrder(orderNumber).then(() => console.log('SUCCESS'));
        
    }

    // Mark Order as Shipped method
    markAsShipped(event) {
        const orderNumber = event.currentTarget.dataset.number;
        markOrderAsShipped(orderNumber).then(() => console.log('SUCCESS'));
    }

    // Preview Invoice method
    previewInvoice(event) {
        const invoiceid = event.currentTarget.dataset.invoiceid;
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: invoiceid
            }
        });
    }

    // Download Invoice method
    downloadInvoice(event) {
        const url = event.currentTarget.dataset.url;
        const downloadLink = document.createElement('a');
                downloadLink.href = url;
                downloadLink.download = 'InvoiceFile'; 
                downloadLink.click();
    }

}