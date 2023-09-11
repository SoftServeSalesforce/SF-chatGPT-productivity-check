import { LightningElement, api } from 'lwc';

export default class CustomCheckbox extends LightningElement {
    @api isSelected;
    @api rowId;  // Add this line to accept rowId as a property

    handleCheckboxChange(event) {
        console.log('Dispatching event with rowId:', this.rowId);
        console.log('isSelected value:', this.isSelected);
        this.dispatchEvent(new CustomEvent('checkboxchange', { 
            detail: { 
                checked: event.target.checked,
                rowId: this.rowId  // Include the rowId in the event detail
            },
            bubbles: true,
            composed: true
        }));        
    }
}
