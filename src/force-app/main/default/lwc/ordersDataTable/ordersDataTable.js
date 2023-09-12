import LightningDatatable from 'lightning/datatable';
import customStatusTemplate from './customStatusTemplate.html';
import customCheckboxTemplate from './customCheckboxTemplate.html';

export default class OrdersDataTable extends LightningDatatable {
    static customTypes = {
        customStatusType: {
            template: customStatusTemplate,
            standardCellLayout: true,
            typeAttributes: ['duration', 'status']
        },
        customCheckboxType: {
            template: customCheckboxTemplate,
            standardCellLayout: true,
            typeAttributes: ['isSelected', 'rowId']
        }
    };

    handleCheckboxChangeEvent(event) {
        this.dispatchEvent(new CustomEvent('checkboxchange', { 
            detail: event.detail,
            bubbles: true,
            composed: true
        }));
    }    
}