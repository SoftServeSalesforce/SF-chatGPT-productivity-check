import { LightningElement, api } from 'lwc';

export default class CustomCheckbox extends LightningElement {
    @api isSelected;
    @api rowId;

    handleCheckboxChange(event) {
        this.dispatchEvent(new CustomEvent('checkboxchange', { 
            detail: { 
                checked: event.target.checked,
                rowId: this.rowId
            },
            bubbles: true,
            composed: true
        }));        
    }
}