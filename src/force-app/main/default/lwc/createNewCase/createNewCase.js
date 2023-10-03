import { LightningElement, api, track, wire  } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getNewCaseParameters from '@salesforce/apex/CreateCaseController.getNewCaseParameters';

export default class CreateNewCase extends NavigationMixin(LightningElement) {
    @api recordId;
    
    @wire (getNewCaseParameters,{recordId: '$recordId'}) result;

    handleclick() {
        let defaultFieldValues = '';
        if (this.result.data) {
            defaultFieldValues = (this.result.data.accountId ? 'AccountId=' + this.result.data.accountId + ',' : '') + 
                                 (this.result.data.contactId ? 'ContactId=' + this.result.data.contactId : '')
        } else {
            defaultFieldValues = null;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                nooverride: '1',
                defaultFieldValues: defaultFieldValues
            }
        }, false);
    }
}
