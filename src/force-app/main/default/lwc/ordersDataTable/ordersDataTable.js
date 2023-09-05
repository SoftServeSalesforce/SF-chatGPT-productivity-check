import LightningDatatable from 'lightning/datatable';
import customStatusTemplate from './customStatusTemplate.html';
export default class OrdersDataTable extends LightningDatatable {
    static customTypes = {
        customStatusType: {
            template: customStatusTemplate,
            standardCellLayout: true,
            typeAttributes: ['duration', 'status']
        }
    };
}