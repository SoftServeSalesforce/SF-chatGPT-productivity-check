import LightningDatatable from 'lightning/datatable';
import customStatus from './customStatus.html';

export default class OrdersListDatatable extends LightningDatatable {
    static customTypes = {
        status: {
            template: customStatus,
            standardCellLayout: true,
            typeAttributes: ['lastStatusChanged', 'status']
        }
    };
}