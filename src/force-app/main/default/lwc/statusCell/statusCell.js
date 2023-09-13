import { api, LightningElement } from 'lwc';

export default class StatusCell extends LightningElement {
    @api status;
    @api lastStatusChanged;

    get classCss(){
        let css = 'slds-badge';
        switch (this.status) {
            case 'Activated':
                css += ' activated-status';
                break;
            case 'Shipped':
                css += ' shipped-status';
                break;
            case 'Delivered':
                css += ' delivered-status';
                break;
            default:
                css += ' draft-status';
        }
        return css;
    }

    get duration(){
        const now = new Date();
        const lastStatusChangeDate = new Date(this.lastStatusChanged);
        const timeDifference = now - lastStatusChangeDate;
        const diffYears = Math.floor(timeDifference / (365 * 24 * 60 * 60 * 1000));
        const diffMonths =  Math.floor(timeDifference / (30 * 24 * 60 * 60 * 1000));
        const diffDays =  Math.floor(timeDifference / (24 * 60 * 60 * 1000));
        const diffHours = Math.floor(timeDifference / (60 * 60 * 1000));
        const diffMins = Math.floor(timeDifference / (60 * 1000));

        if (diffYears > 0){
            return `${diffYears} years in `
        }
        if (diffMonths > 0){
            return `${diffMonths} months in `
        }
        if (diffDays > 0){
            return `${diffDays} days in `
        }
        if (diffHours > 0){
            return `${diffHours} hours in `
        }
        return `${diffMins} minutes in `
    }
}