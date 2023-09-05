import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from "@salesforce/apex";

import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import bulkActivateOrders from '@salesforce/apex/AccountOrdersController.bulkActivateOrders';
import bulkMarkOrdersAsShipped from '@salesforce/apex/AccountOrdersController.bulkMarkOrdersAsShipped';
import getTotalOrderCount from '@salesforce/apex/AccountOrdersController.getTotalOrderCount';
import getPageSize from '@salesforce/apex/AccountOrdersController.getPageSize';
import setPageSize from '@salesforce/apex/AccountOrdersController.setPageSize';

export default class OrderList extends NavigationMixin(LightningElement) {
    @api recordId;
    orders = [];
    wiredOrdersValue;
    selectedOrders = new Map();
    isOnlyDraftOrdersSelected = true;
    isOnlyActivatedOrdersSelected = true;

    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;
    pageSize = 10;    
    isPrevDisabled = true;
    isNextDisabled = false;
    orderPaginationData;

    renderedCallback() {
        getPageSize()
            .then(result => {        
                this.pageSize = result;
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });        
    }

    @wire(getTotalOrderCount, { accountId: '$recordId' })
    handleOrderPagination(value) {   
        this.orderPaginationData = value;
        const { data, error } = value; 
        if (data) {
            this.totalRecords = parseInt(data);
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        } 
        else if (error) {
            this.error = error;
            this.showToast('Error getting total orders count', error.body.message, 'error');
        }
    }   

    @wire(getOrders, { accountId: '$recordId', pageSize:'$pageSize', pageNumber:'$pageNumber' })
    wiredOrders(value) {
        this.wiredOrdersValue = value;
        const { data, error } = value; 
        if(data) {
            this.orders = this.proceedOrders(data);
            this.handlePaginationButtons();
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

    get pageSizeOptions() {
        const sizeOptions = [
            { label: '10', value: 10 },
            { label: '25', value: 25 },
            { label: '50', value: 50 },
            { label: '100', value: 100 },
            { label: '200', value: 200 }  
        ];
        
        return sizeOptions;
    }

    handlePaginationButtons() {
        this.isPrevDisabled = this.pageNumber === 1;
        this.isNextDisabled = this.pageNumber >= this.totalPages; 
    }

    handlePagePrevAction() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
        }

        this.handlePaginationButtons();

        getOrders({ accountId: '$recordId', pageSize: '$pageSize', pageNumber:'$pageNumber' });
    }

    handlePageNextAction() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber += 1;
        }

        this.handlePaginationButtons(); 

        getOrders({ accountId: '$recordId', pageSize: '$pageSize', pageNumber:'$pageNumber' });
    }

    handlePageSizeChange(event) {
        const newPageSize = event.target.value;

        this.pageSize = newPageSize;
        this.pageNumber = 1;

        setPageSize({ pageSize: this.pageSize })
            .then((result) => {
                this.totalPages = Math.ceil(this.totalRecords / newPageSize);
                this.pageNumber = 1;
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
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
