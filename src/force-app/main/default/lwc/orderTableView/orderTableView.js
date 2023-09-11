import { LightningElement, wire, api,track } from 'lwc';
import getOrders from '@salesforce/apex/AccountOrdersController.getOrders';
import activateOrder from '@salesforce/apex/AccountOrdersController.activateOrder';
import markOrderAsShipped from '@salesforce/apex/AccountOrdersController.markOrderAsShipped';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import activateSelectedOrders from '@salesforce/apex/AccountOrdersController.activateSelectedOrders';
import shipSelectedOrders from '@salesforce/apex/AccountOrdersController.shipSelectedOrders';
import setPageSizeUSer from '@salesforce/apex/AccountOrdersController.setPageSizeUSer';
import LightningConfirm from "lightning/confirm";
import getPageSizeUser from '@salesforce/apex/AccountOrdersController.getPageSizeUser';



const COLTODISPLAY = [
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
   
    @track Buttontrue=true;
    @track ButtontrueShipped=true;

    
    

    // JS Properties 
    
    records = []; //All records available in the data table
    columns = []; //columns information available in the data table
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number    
   
   
    selectedRows = [];
    columns = COLTODISPLAY;
    orders;
    _wiredOrders;
    
    
    selectedOrders = [];
    selectedOrdersNumberActive=[];
    selectedOrdersNumberShipped=[];
   

    constructor() {
        super();
        this.columns = this.columns.concat( [
            { type: 'action', typeAttributes: { rowActions: this.getRowActions.bind( this ) } }
        ] );
    }

    get pageSizeOptions() {
        return [
                 { label: '10', value: 10 },
                 { label: '25', value: 25 },
                 { label: '50', value: 50 },
                 { label: '100', value: 100 },
                 { label: '200', value: 200 }                
               ];
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }


    renderedCallback() {
        
        getPageSizeUser()
            .then(result => { 
                if(result){                    
                    this.pageSize = result; 
                    
                }else{
                    this.pageSize= this.pageSizeOptions[0].value;
                    
                }               
                
                
          })
          .catch(error => {
            console.error('PAge size not retrieved,Error!:', error);
          });        
    }

    


    @wire(getOrders, { accountId: '$recordId' })
    retrieveOrders(wireResult){
        const { data, error } = wireResult;
        this._wiredOrders = wireResult;
   
                if (data) {
                    
                    this.records = data;
                    this.totalRecords = data.length; // update total records count
                      
                    
                    this.paginationHelper(); // call helper menthod to update pagination logic 
                } else if (error) {
                    this.showToast('Error', 'An error occurred while loading your orders', 'error');
                }

    }


   
    refreshData() {
        return refreshApex(this._wiredOrders);
    }
 

    getRowActions( row, doneCallback ) {

        const actions = [];
        
        if (row[ 'Status' ] === 'Draft' ) {    
            actions.push({ label: 'Activate', name: 'activate' });
        }     
        else if (row[ 'Status' ] === 'Activated') {
            actions.push({ label: 'Mark As Shipped', name: 'markShipped' });
        }
        if (row.hasInvoiceFiles) {
            actions.push({ label: 'Preview Invoice', name: 'previewInvoice' });
        }
        if (row.hasInvoiceFiles) {
            actions.push({ label: 'Download Invoice', name: 'downloadInvoice' });
        }
        actions.push({ label: 'Refresh', name: 'refresh' });
        setTimeout( () => {
            doneCallback( actions );
        }, 200 );

    }

   

    handleDownload(event) {
        const row = event.target.dataset.row;
        const FileId =row.FileId;
        const downloadLink = document.createElement('a');
                downloadLink.href = `/sfc/servlet.shepherd/document/download/${FileId}`;
                downloadLink.download = 'InvoiceFile'; 
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
        }else if (actionType === 'refresh') {
           
            this.refreshData();
            this.showToast('Success', 'Orders refreshed successfully.', 'success');
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
                    
                    this.showToast('Success', 'Order activated successfully.', 'success');
                    this.refreshData();

                   
                } else {
                    
                    this.showToast('Error', result.ErrorMessage, 'error');
                }
            })
            .catch(error => {
               
                this.showToast('Some error Activating occurred', error.body.message, 'error');
            });
    }

    handleMarkShipped(orderId) {
        markOrderAsShipped({ orderId: orderId })
            .then(result => {
                if (result.status === 'OK') {
                    this.showToast('Success', 'Order marked as shipped successfully.', 'success');
                    this.refreshData();
                } else {
                    this.showToast('Error', result.ErrorMessage, 'error');
                }
            })
            .catch(error => {
                this.showToast('Some error Shipping occurred', error.body.message, 'error');
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



    handleRowSelection( event ) {

        
        const selRows = event.detail.selectedRows;
                    
            this.selectedRows = selRows;
       
        
            this.selectedOrdersNumberActive=[];
            this.selectedOrdersNumberShipped=[];
            this.selectedOrders=[];


        for ( let i = 0; i < this.selectedRows.length; i++ ) {

            this.selectedOrders.push( this.selectedRows[ i ].Id );
            if(this.selectedRows[ i ].Status==='Draft'){
                if(!this.selectedOrdersNumberActive.includes(this.selectedRows[ i ].OrderNumber) ){
                    this.selectedOrdersNumberActive.push( this.selectedRows[ i ].OrderNumber );
                }
               
                this.Buttontrue=false;
            }
            if(this.selectedRows[ i ].Status==='Activated'){
                if(!this.selectedOrdersNumberShipped.includes(this.selectedRows[ i ].OrderNumber)){
                    this.selectedOrdersNumberShipped.push(this.selectedRows[ i ].OrderNumber );
                }
                this.ButtontrueShipped=false;
            }

        }
        

        if(this.selectedRows.length==0){
            this.ButtontrueShipped=true;
            this.Buttontrue=true;
        }


    }

    


    // Function to handle the "Activate Selected" button click
     handleActivateSelected() {
        if (this.selectedOrders.length > 0) {
            // Call the Apex method to activate selected orders
            activateSelectedOrders({ orderIds: this.selectedOrders })
                
                .then(result => {
                   
                        this.showToast('Success', 'Orders activated successfully.', 'success');
                        this.template.querySelector('lightning-datatable').selectedRows = [];
                        this.Buttontrue=true;
                        this.ButtontrueShipped=true;
                        this.refreshData();
                    
                })
                .catch(error => {
                    this.showToast('Some error Activating occurred', error.body.message, 'error');
                    this.refreshData();
                });
        } else {
            this.showToast('Error','No Orders were selected', 'error');
        }
    }

    handleShippedSelected() {
        if (this.selectedOrders.length > 0) {
            // Call the Apex method to activate selected orders
            shipSelectedOrders({ orderIds: this.selectedOrders })
                .then(result => {
                   
                        this.showToast('Success', 'Orders shipped successfully.', 'success');
                        this.template.querySelector('lightning-datatable').selectedRows = [];
                        this.ButtontrueShipped=true;
                        this.Buttontrue=true;
                        this.refreshData();
                    
                   
                })
                .catch(error => {
                    this.showToast('Some error Shipping occurred', error.body.message, 'error');
                });
        } else {
            this.showToast('Error','No Orders were selected', 'error');
        }
    }

    async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: "Do you confirm to Activate "+ this.selectedOrdersNumberActive.length + " of Draft orders: " +this.selectedOrdersNumberActive +" ?",
            variant: "default", 
            label: "Acitvate Orders"
        });
    
        
        if (result) {
            
            this.handleActivateSelected();
            
        } 
    }


    async handleConfirmClickShipped() {
        const result = await LightningConfirm.open({
            message: "Do you confirm to mark as sent "+ this.selectedOrdersNumberShipped.length + " of Activated order: " +this.selectedOrdersNumberShipped +" ?",
            variant: "default", 
            label: "Ship Orders"
        });
    
       
        if (result) {
            
            this.handleShippedSelected();
            
        } 
    }


    refreshedOrders() {
       
                    
                    this.showToast('Success', 'Orders refreshed successfully.', 'success');
                    this.template.querySelector('lightning-datatable').selectedRows = [];
                    this.ButtontrueShipped=true;
                    this.Buttontrue=true;
                    this.refreshData();
                   
           
    }
    
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        setPageSizeUSer({ pageSize: this.pageSize });
        this.paginationHelper();
    }


    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        
        this.orders = [];
        
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }

        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }

            this.orders.push(this.records[i]);

            this.orders = this.orders.map(order => {
                return {
                    ...order,
                    disableDownload: !order.hasInvoiceFiles,
                    OrderNumberLink: `/${order.Id}` // Construct the link to the Order record
                };
            
            });  


            
        }
        
        
    }

    
   
}
