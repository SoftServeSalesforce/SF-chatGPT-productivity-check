import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAccontCaseIds from '@salesforce/apex/CreateCasesAgentController.getAccontCaseIds';

export default class CreateNewCase extends LightningElement {
    @api recordId   
    
    handleCreateNewCase() {
        if (!this.recordId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Record Id issue',
                    message: 'You need to be on a record page',
                    variant: 'error',
                    mode: 'dismissable'
                }),
            );
        }
        console.log('Record Id jest wyciagane poprawnie' + this.recordId);
        getAccontCaseIds({ recordId: this.recordId }).then(wrapper => {
            if(!wrapper) {
                return;
            }
            this.dispatchEvent(new CustomEvent("createnewcase", {
                detail: { detail: wrapper }
            }));
        }).catch(error => {         
            console.error('tutaj wchodzi');       
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'An error occured',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                }),
            );
        });
    }
}