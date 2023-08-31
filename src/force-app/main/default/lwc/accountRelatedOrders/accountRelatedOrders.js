import { LightningElement, wire, api } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
const SEPARATOR = '_';

export default class AccountRelatedOrders extends NavigationMixin(LightningElement) {
    @api recordId; 
    wiredOrders;
    orders;
    error;

    @wire(getOrders, { accountId: '$recordId' })
    handleOrders(value) {        
        this.wiredOrders = value; 
        const { data, error } = value; 
        if (data) {  
            console.log(JSON.parse(JSON.stringify(data)));
            this.orders = data.map(item => {
                const hasInvoices = item.attachmentId;
                const orderIdContentDocumentId = item.orderId + SEPARATOR + item.contentDocumentId;
                return {
                    "Id": item.orderId,
                    "orderNumber": item.orderNumber,
                    "startDate": item.EffectiveDate,
                    "orderStatus": item.orderStatus,
                    "timeInCurrentStatus": this.getTimeInCurrentStatus(item.lastStatusChanged),
                    "statusBadgeCSS": this.getStatusCSS(item.orderStatus),
                    "amount": item.amount,
                    "contentDocumentId": item.contentDocumentId,
                    "orderIdContentDocumentId": orderIdContentDocumentId,
                    "hasInvoices": hasInvoices,
                    "orderActions": this.populateOrderActions(item.orderStatus, hasInvoices)
                }
            });
            this.error = undefined;           
        } else if (error) {
            this.error = error;
            this.showToast('Error updating order', error.body.message, 'error');            
        }
    }

    getTimeInCurrentStatus(lastStatusChanged) {
        let finalTimeInStatusString = '';
        let lastStatusChangedParsed = Date.parse(lastStatusChanged);
        let timeDiff = Date.now() - lastStatusChangedParsed;
        let totalMinutes = parseInt(Math.floor(timeDiff / (60 * 1000)));
        if (totalMinutes < 60) {
            finalTimeInStatusString += totalMinutes + ' minutes in ';
            return finalTimeInStatusString;
        }
        let totalHours = parseInt(Math.floor(totalMinutes / (60)));
        if (totalHours < 24) {
            finalTimeInStatusString += totalHours + ' hours ' + parseInt(totalMinutes % 60) + ' minutes in ';
            return finalTimeInStatusString;
        }
        let totalDays = parseInt(Math.floor(totalHours / 24));
        if (totalDays <  30) {
            finalTimeInStatusString += totalDays + ' days ' + parseInt(totalMinutes % 24) + ' hours ' + parseInt(totalMinutes % 60) + ' minutes in ';
            return finalTimeInStatusString;
        }
        let totalMonths = parseInt(Math.floor(totalDays / 30));
        if (totalMonths <  12) {
            finalTimeInStatusString += totalMonths + ' months ' + parseInt(totalDays % 30) + ' days ' + parseInt(totalMinutes % 24) + ' hours ' + parseInt(totalMinutes % 60) + ' minutes in ';
            return finalTimeInStatusString;
        } else {
            let totalYears = parseInt(Math.floor(totalDays / 365));
                finalTimeInStatusString += totalYears + 'years ' + parseInt(totalYears % 12) + ' months ' + parseInt(totalDays % 30) + ' days ' + parseInt(totalMinutes % 24) + ' hours ' + parseInt(totalMinutes % 60) + ' minutes in ';
                return finalTimeInStatusString;        
        }        
    }

    populateOrderActions(status, hasInvoices) {
        let isDraft = status === 'Draft';
        let isActivated = status === 'Activated';
        let rowActions = new Array();
        if (isDraft) {
            rowActions.push({ value: 'activate', label: 'Activate' });  
        } else if (isActivated) {
            rowActions.push({ value: 'markAsShipped', label: 'Mark as Shipped' });
        }
        if (hasInvoices) {
            rowActions.push({ value: 'previewInvoice', label: 'Preview Invoice'});
            rowActions.push({ value: 'downloadInvoice', label: 'Download Invoice'});
        }
        return rowActions;
    }

    handleActionSelected(event) {   
        const selectedAction = event.detail.value;
        const orderIdContentDocumentId = event.target.dataset.id;
        const ids = orderIdContentDocumentId.split(SEPARATOR);
        const orderId = ids[0];
        const contentDocumentId = ids[1];
        switch (selectedAction) {
            case 'activate':
                this.handleActivate(orderId);
                break;
            case 'markAsShipped':
                this.handleMarkAsShipped(orderId);
                break;
            case 'previewInvoice':
                this.handlePreviewInvoice(contentDocumentId)
                break;
            case 'downloadInvoice':
                this.downloadInvoice(contentDocumentId);
                break;            
        }        
    }
    
    getStatusCSS(status) {
        switch(status) {
            case 'Draft':
                return 'slds-badge';
            case 'Activated':
                return 'slds-badge slds-theme_warning';
            case 'Shipped':
                return 'slds-badge badge-status-shipped';
            case 'Delivered':
                return 'slds-badge slds-theme_success';
            default:
                return 'slds-badge';
        }
    }

    handleOrderNumberClick(event) {        
        this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: event.target.dataset.id,
            objectApiName: 'Order',
            actionName: 'view'
        },
    });        
    }

    handleActivate(orderId) {        
        activateOrder({ orderId: orderId })
            .then(result => {
                this.handleResponse(result);
            })
            .catch(error => {
                this.showToast('Some error occurred', error.body.message, 'error');
            });
    }

    handleMarkAsShipped(orderId) {        
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                this.handleResponse(result);
            })
            .catch(error => {
                this.showToast('Some error occurred', error.body.message, 'error');
            });
    }

    handleResponse(response) {
        if (response.responseStatus === 'Success') {
            this.showToast('Success', response.responseMessage, response.responseStatus);
            refreshApex(this.wiredOrders);
        } else if (response.responseStatus === 'Error') {
            this.showToast('Something went wrong', response.responseMessage, response.responseStatus);
        }
    }

    handleDownloadInvoice(event) {
        const contentDocumentId = event.target.dataset.id;
        this.downloadInvoice(contentDocumentId);
    }

    downloadInvoice(fileId) {
        const fileUrl = '/sfc/servlet.shepherd/document/download/' + fileId + '?operationContext=S1';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: fileUrl
            }
        }, false);
    }

    handlePreviewInvoice(fileId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: fileId
            }
        });
    }    

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
              title: title,
              message: message,
              variant: variant,
            }),
          );
    }
}