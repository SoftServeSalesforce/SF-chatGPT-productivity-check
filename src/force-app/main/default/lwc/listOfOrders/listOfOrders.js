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
                hasInvoice: order.latestInvoiceFileName != '',
                orderStatusStyled: styleStatusText(order.orderStatus),
                statusCssClass: getStatusCssClass(order.orderStatus)
            }));
        } else if (error) {
            // Handle error
        }
    }

    getStatusCssClass(status) {
        switch (status) {
            case 'Draft':
                return 'draft-status';
            case 'Activated':
                return 'activated-status';
            case 'Shipped':
                return 'shipped-status';
            case 'Delivered':
                return 'delivered-status';
            default:
                return '';
        }
    }

    styleStatusText(status) {
        const now = new Date();
        const orderDate = new Date(order.orderDate);
        const timeDiff = now - orderDate;
        const years = Math.floor(timeDiff / (365 * 24 * 60 * 60 * 1000));
        const months = Math.floor(timeDiff / (30 * 24 * 60 * 60 * 1000));
        const days = Math.floor(timeDiff / (24 * 60 * 60 * 1000));
        const hours = Math.floor(timeDiff / (60 * 60 * 1000));
        const minutes = Math.floor(timeDiff / (60 * 1000));

        switch (order.orderStatus) {
            case 'Draft':
                return `${years} years ${months} months ${days} days ${hours} hours ${minutes} minutes in Draft`;
            case 'Activated':
                return `${years} years ${months} months ${days} days ${hours} hours ${minutes} minutes in Activated`;
            case 'Shipped':
                return `${years} years ${months} months ${days} days ${hours} hours ${minutes} minutes in Shipped`;
            default:
                return '';
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