import { LightningElement, api } from 'lwc';

export default class CustomCheckbox extends LightningElement {
    @api isSelected;
    @api rowId;
    @api keyField;

    handleCheckboxChange(event) {
        console.log('xxx cc event');
        console.log('xxx cc event.detail: ' + JSON.stringify(event.detail));
        console.log('xxx cc event.target.checked: ' + event.target.checked);
        console.log('xxx cc event.target.rowId:', event.target.rowId);
        console.log('xxx cc event.target.keyField:', event.target.keyField);
        console.log('xxx cc event.detail.rowId:', event.detail.rowId);
        console.log('xxx cc event.detail.keyField:', event.detail.keyField);
        console.log('xxx cc this.rowId:', this.rowId);
        console.log('xxx cc this.keyField:', this.keyField);
        console.log('xxx cc event.target: ' + JSON.stringify(event.target));
        console.log('xxx cc event.detail rowId: ' + this.rowId);
        console.log('xxx cc event.detail selected: ' + this.isSelected);
        this.dispatchEvent(new CustomEvent('checkboxchange', { 
            detail: { 
                checked: event.target.checked,
                rowId: this.keyField
            },
            bubbles: true,
            composed: true
        }));        
    }
    
    connectedCallback() {
        console.log('CustomCheckbox rowId:', this.rowId);
        console.log('CustomCheckbox keyField:', this.keyField);
    }
}