import { LightningElement, api, wire } from 'lwc';
import getCreateCaseDetails from '@salesforce/apex/CreateActionsController.getCreateCaseDetails';
import { publish, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createActions from '@salesforce/messageChannel/createActions__c';

const TOAST_ERROR_TITLE = 'Something went wrong...';
const TOAST_ERROR_MESSAGE_START = 'Details of error: ';
const TOAST_ERROR_VARIANT = 'error';

export default class CreateActions extends LightningElement {
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
        getCreateCaseDetails({recordId: this._recordId}).then(response => {
            // Should not happen
            if (response.caseOrigin == null) {
                return;
            }
            let createCaseUrl = `/lightning/o/Case/new?&defaultFieldValues=Origin=${response.caseOrigin}`;
            if(response.accountId) {
                createCaseUrl += `,AccountId=${response.accountId}`;
            }
            if(response.contactId) {
                createCaseUrl += `,ContactId=${response.contactId}`;
            }
            this.handlePublishCreateActions(createCaseUrl);
        }).catch(error => { 
            this.handleDisplayToast(
                TOAST_ERROR_TITLE, 
                TOAST_ERROR_MESSAGE_START + error.body.message, 
                TOAST_ERROR_VARIANT
            );
        });
    }

    handlePublishCreateActions(url) {
        let payload = {buildUrl: url};
        publish(this.messageContext, createActions, payload);

    }

    handleDisplayToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}