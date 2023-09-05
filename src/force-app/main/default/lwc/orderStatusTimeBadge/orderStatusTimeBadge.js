import { LightningElement, api } from 'lwc';

export default class OrderStatusTimeBadge extends LightningElement {
    @api status;
    @api lastStatusChanged;

    time;
    label;
    className;

    connectedCallback() {
        this.time = this.calculateRelativeTime();
        this.label = this.status;
        this.className = this.status.toLowerCase();
    }

    calculateRelativeTime() {
        const seconds = this.lastStatusChanged ? Math.floor((new Date() - Date.parse(this.lastStatusChanged)) / 1000) : 0;
        const found = this.timeDividers.find(timeDivider => seconds / timeDivider.divider > 1);
        if (!found) {
            return '1 second(s) in '
        }
        return Math.floor(seconds / found.divider) + found.text;
    }

    timeDividers = [
        {
            divider: 31536000,
            text: ' year(s) in '
        },
        {
            divider: 2592000,
            text: ' month(s) in '
        },
        {
            divider: 86400,
            text: ' day(s) in '
        },
        {
            divider: 3600,
            text: ' hour(s) in '
        },
        {
            divider: 60,
            text: ' minute(s) in '
        },
        {
            divider: 1,
            text: ' second(s) in '
        },
    ]
}