import { LightningElement, api, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getRecordData from '@salesforce/apex/CreateCaseController.getRecordData';

export default class CreateCase extends LightningElement {
    @api recordId   
    
    createCaseHandler() {   
        if (this.recordId) {
            getRecordData({ recordId: this.recordId }).then(result => {
                const createCaseEvent = new CustomEvent("createcase", {
                    detail: { result }
                  });
                this.dispatchEvent(createCaseEvent);
            }).catch(error => {                
                this.showToast(error, 'Some error occured', 'error');
             })           
        } else {
            this.showToast({ body: ['Please select existing record page']}, 'Please select existing record page', 'error');
        }        
    }

    showToast(error, title, variant, mode) {
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode ? mode : 'dismissable'
            }),
        );
    }
}