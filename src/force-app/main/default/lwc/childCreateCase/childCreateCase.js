import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import getSobjectTypeById from '@salesforce/apex/CasesService.getSobjectTypeById';
import createCase from '@salesforce/messageChannel/Create_Case__c';

export default class ChildCreateCase extends LightningElement {
    @api sobjectId;

    @wire(MessageContext)
    messageContext;

    async handleCreateCase() {
        let sobjectApiName;

        if (this.sobjectId) {
            sobjectApiName = await getSobjectTypeById({recordId: this.sobjectId});
        }

        const standardUrl = '/lightning/o/Case/new';
        let suffixUrl;
        if (sobjectApiName === 'Account') {
            suffixUrl = '?&defaultFieldValues=AccountId=' + this.sobjectId;
        } else if (sobjectApiName === 'Contact') {
            suffixUrl = '?&defaultFieldValues=ContactId=' + this.sobjectId;
        }
        const fullUrl = suffixUrl ? standardUrl + suffixUrl : standardUrl;
        const payload = { URL: fullUrl};
        publish(this.messageContext, createCase, payload);
    }
}