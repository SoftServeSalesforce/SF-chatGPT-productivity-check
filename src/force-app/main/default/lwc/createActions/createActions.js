import { LightningElement , api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountContactName from '@salesforce/apex/CreateActionsController.getAccountContactName';


export default class CreateActions extends NavigationMixin(LightningElement) {

    @api recordId;
    accountId;
    contactId;
    linkToNewCase = '/lightning/o/Case/new';

    connectedCallback() {
        getAccountContactName({ recordId: this.recordId })
            .then(result => {
                console.log('result: ' + result);
                this.accountId = result?.accountId;
                this.contactId = result?.contactId;
            })
            .catch(error => {
                console.log('error: ' + error);
            });
    }

    createCase() {
        if (this.accountId || this.contactId) {
            this.linkToNewCase = this.linkToNewCase + '?defaultFieldValues=' + 
            (this.accountId ? 'AccountId=' + this.accountId : '' ) +
            (this.contactId && this.accountId ? ',' : '' ) +
            (this.contactId ? 'ContactId=' + this.contactId : '');
        }
        window.open(this.linkToNewCase, "_self");
    }
}