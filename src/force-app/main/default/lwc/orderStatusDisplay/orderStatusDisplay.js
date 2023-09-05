import {api, LightningElement} from 'lwc';

export default class OrderStatusDisplay extends LightningElement {
    @api status;
    @api duration;

    get badgeCss(){
        let css = 'slds-badge';
        switch (this.status) {
            case 'Activated':
                css += ' badge-orange';
                break;
            case 'Shipped':
                css += ' badge-blue';
                break;
            case 'Delivered':
                css += ' badge-green';
                break;
            default:
                css += ' badge-gray';
        }
        return css;
    }

    get durationText() {
        if (!this.duration) {
            return '';
        }
        let resultText = '';
        let durationMin = this.duration / 60000;
        if (durationMin < 60) {
            let resultMin = Math.floor(durationMin);
            resultText = resultMin + ' minute' + (resultMin !== 1 ? 's' : '') + ' in ';
        } else if (durationMin < 60 * 24) {
            let resultHr = Math.floor(durationMin / 60);
            resultText = resultHr + ' hour' + (resultHr !== 1 ? 's' : '') + ' in ';
        } else if (durationMin < 60 * 24 * 360) {
            let resultDays = Math.floor(durationMin / 60 / 24);
            resultText = resultDays + ' day' + (resultDays !== 1 ? 's' : '') + ' in ';
        } else {
            let resultYears = Math.floor(durationMin / 60 / 24 / 360);
            resultText = resultYears + ' year' + (resultYears !== 1 ? 's' : '') + ' in ';
        }
        return resultText;
    }
}