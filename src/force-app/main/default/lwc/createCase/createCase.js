import { LightningElement, api, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import createActionsMC from '@salesforce/messageChannel/Create_Actions__c';

export default class CreateCase extends LightningElement {
    @api recordId;
    
    @wire(MessageContext)
    messageContext;

    handleCreateCase() {
        let id = this.recordId;
        const newCaseUrl = '/lightning/o/Case/new';
        let redirectURL;

        if (id == null) {
            redirectURL = newCaseUrl;
        } else if (id.startsWith("001")) {
            redirectURL = newCaseUrl + '?&defaultFieldValues=AccountId=' + id;
        } else if ( id.startsWith("003")) {
            redirectURL = newCaseUrl + '?&defaultFieldValues=ContactId=' + id;
        }

        const payload = { URL: redirectURL};
        publish(this.messageContext, createActionsMC, payload);
    }
}