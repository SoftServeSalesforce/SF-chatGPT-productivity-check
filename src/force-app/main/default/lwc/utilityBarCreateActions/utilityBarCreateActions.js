import { LightningElement, wire, api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getData from '@salesforce/apex/CreateCaseActionController.getData';
import utilityBarcreateActions from '@salesforce/messageChannel/utilityBarcreateActions__c';


export default class UtilityBarCreateActions extends LightningElement {
   
    
    _recordId;
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
    }

    @wire(MessageContext)
    messageContext;

    
    handleCreateCase() {
        getData({recordId: this._recordId}).then(response => {
           
            publish(this.messageContext, utilityBarcreateActions, {buildUrl: response.url});
        }).catch(error => { 
            
            this.showToast('Error', error.body.message, 'error');
            
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
