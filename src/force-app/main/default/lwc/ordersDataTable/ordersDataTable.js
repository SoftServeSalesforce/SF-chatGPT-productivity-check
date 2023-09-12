import LightningDatatable from 'lightning/datatable';
import {api} from 'lwc';
import customStatusTemplate from './customStatusTemplate.html';
import customCheckboxTemplate from './customCheckboxTemplate.html';

export default class OrdersDataTable extends LightningDatatable {
    @api rowId;
    @api keyField;
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
        console.log('xxx odt event');
        console.log('ODT Row ID:', this.rowId);
        console.log('ODT keyField:', this.keyField);
        console.log('xxx odt event.detail: ' + event.detail);
        this.dispatchEvent(new CustomEvent('checkboxchange', { 
            detail: event.detail,
            bubbles: true,
            composed: true
        }));
    }    

    get debugRowId() {
        console.log('ODT Row ID:', this.rowId);
        console.log('ODT keyField:', this.keyField);
        return this.rowId;
    }

    connectedCallback() {
        console.log('OrdersDataTable received data:', this.data);
    }
}