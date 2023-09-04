import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from "@salesforce/apex";

import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import bulkActivateOrders from '@salesforce/apex/AccountOrdersController.bulkActivateOrders';
import bulkMarkOrdersAsShipped from '@salesforce/apex/AccountOrdersController.bulkMarkOrdersAsShipped';

export default class OrderList extends NavigationMixin(LightningElement) {
    @api recordId;
    orders = [];
    wiredOrdersValue;
    selectedOrders = new Map();
    isOnlyDraftOrdersSelected = true;
    isOnlyActivatedOrdersSelected = true;


    @wire(getOrders, { accountId: '$recordId' })
    wiredOrders(value) {
        this.wiredOrdersValue = value;
        const { data, error } = value; 
        if(data) {
            this.orders = this.proceedOrders(data);;
        } else if(error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    proceedOrders(data) {
        return data.map(order => {
            return {
                ...order,
                isActivated: order.status == 'Activated',
                isDraft: order.status == 'Draft',
                activateValue: 'activate.' + order.orderId,
                markShippedValue: 'markAsShipped.' + order.orderId,
                previewInvoiceValue: 'previewInvoice.' + order.contentDocumentId,
                downloadInvoiceValue: 'downloadInvoice.' + order.contentDocumentId,
                statusTime: this.getStatusTime(order.lastStatusChanged),
                statusStyle: this.getStatusStyle(order.status)
            };
        });
    }

    getStatusStyle(status) {
        switch(status) {
            case 'Draft':
                return '';
            case 'Activated':
                return 'slds-theme_warning';
            case 'Shipped':
                return 'slds-theme_alt-inverse';
            case 'Delivered':
                return 'slds-theme_success';
            default:
                return '';
        }
    }

    getStatusTime(lastStatusChanged) {
        if (lastStatusChanged == null || lastStatusChanged == undefined) {
            return ' ';
        }

        const currentDate = new Date();
        const duration = currentDate - new Date(lastStatusChanged);

        const minute = 60 * 1000;
        const hour = minute * 60;
        const day = hour * 24;
        const month = day * 30;
        const year = day * 365;

        if (duration < minute) {
            return `${Math.round(duration / 1000)} seconds`; 
        } 
        else if (duration < hour) {
            return `${Math.round(duration / minute)} minutes`;
        } 
        else if (duration < day) {
            return `${Math.round(duration / hour)} hours`;
        } 
        else if (duration < month) {
            return `${Math.round(duration / day)} days`;
        } 
        else if (duration < year) {
            return `${Math.round(duration / month)} months`;
        } 
        else {
            return `${Math.round(duration / year)} years`;
        }
    }

    handleRowAction(event) {
        let actionName = event.currentTarget.name;
        let id = event.currentTarget.dataset.id;
        const value = event.detail.value;

        if (actionName == undefined) {
            actionName = value.split('.')[0];
            id = value.split('.')[1];
        }

        switch (actionName) {
            case 'redirectToOrder':
                this.redirectToOrderRecord(id);
                break;
            case 'activate':
                this.activateSelectedOrder(id);
                break;
            case 'markAsShipped':
                this.markOrderAsShipped(id);
                break;
            case 'previewInvoice':
                this.navigateToInvoicePreview(id);
                break;
            case 'downloadInvoice':
                this.downloadInvoice(id);
                break;
            default:
                break;
        }
    }

    redirectToOrderRecord(id) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                actionName: 'view'
            }
        });
    }

    activateSelectedOrder(orderId) {
        activateOrder({ orderId: orderId })
            .then(result => {
                this.showToast('Success', result, 'success');
                this.handleRefresh();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    markOrderAsShipped(orderId) {
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                this.showToast('Success', result, 'success');
                this.handleRefresh();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleRefresh() {
        refreshApex(this.wiredOrdersValue);
    }

    navigateToInvoicePreview(contentDocumentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contentDocumentId,
                actionName: 'view'
            }
        });
    }

    downloadInvoice(contentDocumentId) {
        window.open(`/sfc/servlet.shepherd/document/download/${contentDocumentId}`);
    }

    handleCheckboxChange(event) {
        const isChecked = event.target.checked;
        const orderId = event.target.dataset.id;
        const value = event.target.value;
        if (isChecked) {
            this.selectedOrders.set(orderId, value);
        } 
        else if (this.selectedOrders.has(orderId)) {
            this.selectedOrders.delete(orderId); 
        }        

        this.updateButtonsStatus();
    }

    updateButtonsStatus() {
        const selectedOrderStatuses = Array.from(this.selectedOrders.values());

        if (!(selectedOrderStatuses.length > 0 && selectedOrderStatuses.every((status) => status === 'Draft'))) {
            this.isOnlyDraftOrdersSelected = true;
        } else {
            this.isOnlyDraftOrdersSelected = false;
        }
          
        if (!(selectedOrderStatuses.length > 0 && selectedOrderStatuses.every((status) => status === 'Activated'))) {
            this.isOnlyActivatedOrdersSelected = true;
        } else {
            this.isOnlyActivatedOrdersSelected = false;
        }
    }

    activateSelectedOrders() {
        if (window.confirm(`Do you confirm to activate ${this.selectedOrders.size} of Draft order(s)?`)) {
            const orderIds = [... this.selectedOrders.keys()];      
            bulkActivateOrders({ orderIds: orderIds})
                .then(result => {
                    this.showToast('Success', result, 'success');
                    this.handleRefresh();
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                });
        }
    }

    markSelectedOrdersAsShipped() {
        if(window.confirm(`Do you confirm to mark as sent ${this.selectedOrders.length} of activated order(s)?`)) {
            const orderIds = [... this.selectedOrders.keys()];
            bulkMarkOrdersAsShipped({ orderIds: orderIds })
                .then(result => {
                    this.showToast('Success', result, 'success');
                    this.handleRefresh();
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                });
        }
    }


    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}
