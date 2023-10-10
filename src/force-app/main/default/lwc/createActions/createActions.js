import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseDetails from '@salesforce/apex/CreateActionsController.getCaseDetails';

export default class CreateCaseUtilityBar extends LightningElement {
    @api recordId;

    handleCreateCase() {
        if (this.recordId) {
            getCaseDetails({ recordId: this.recordId })
            .then(result => {
                const createCaseEvent = new CustomEvent("createCase", {
                    detail: { result }
                });
                this.dispatchEvent(createCaseEvent);
            })
            .catch(error => {                
                this.showToast('Error', error, 'error');
            }) 
        } else {
            this.showToast('Warning', 'Please select existing record page', 'warning');
        }       
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}