import { LightningElement, api } from 'lwc';

export default class CreateActions extends LightningElement {
    @api recordId;

    handleCreateCaseClick() {
        console.log("xxx Create Case button clicked.");

        // Create and dispatch the Aura event
        const auraEvent = new CustomEvent('createcase', {
            detail: {
                recordId: this.recordId
            }
        });
        this.dispatchEvent(auraEvent);
    }
}
