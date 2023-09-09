# "Orders" functionality enhancements

This repository contains Salesforce metadata which extends publicly available OOTB SFDC Sales Cloud functionality for “Order” Object with new statuses, automations, actions validations, and even enhanced related list lwc so it is aligned with basic drop shipping flow.

## Functionality overview

> [!IMPORTANT]
> This is an Apex-first project. That means that majority (if not all) items below are implemented in code.

### Automations overview

This project introduces set of changes needed to automatically capture date and time of the last Order record Status change on the Order level so it is easier to report on such event and to calculate time spent at current status.

In order to implement above, new custom date/time field called **Last Status Changed** was added to **Order** Object. 

Population of the field value happens at **captureLastStatusChange** method of **OrderService** Class, which is executed upon Order insert or update at **BEFORE** context when **Order_CaptureLastStatusChange__c** property of **FeaturesEnabler__c** Custom Setting is set for User who performs the operation.

### Validations overview

This project introduces set of changes needed to validate certain Order record Status changes based on the previous Order state. Such validations enforces Business Rules for backward record processing.

Status changes in scope:
1. from **Draft** to **Activated**;
2. from **Activated** to **Shipped**, happens at **validateOrderStatusChangeToShipped** method of the same Class.

Validations happens at **validateOrderStatusChangeToActivated** and **validateOrderStatusChangeToShipped** methods of **OrderService** upon Order record Status update at **BEFORE** when corresponding **Order_ValidateActivation__c** and **Order_ValidateShipment__c** properties of **FeaturesEnabler__c** Custom Setting are set for User who performs the operation.

### Account flexipage changes overview

This project introduces set of changes needed to add custom Orders related list to default flexipage of Account Object.

Custom related list allows User who viewing it access basic Order information, like:
- **Order Number**, which is clickable link to Order;
- **Date**, which is **EffectiveDate** field of **Order** under the hood;
- **Status**, which includes time spent after record was moved to current Status; available when **Order_CaptureLastStatusChange__c** is populated;
- **Amount**, which is **TotalAmount** field of **Order** under the hood; formatted as USD;
- **Invoice**, which is a link to download the most recent attachment with **Invoice**-like name.

Custom related list allows User who viewing it perform following actions:
- **Refresh data shown**;
- **Bulk Orders Status Change** to **Activated** or **Shipped**;
- **Status Change** for single record to **Activated** or **Shipped**;
- **Invoice donwload** for single record;
- **Invoice preview** for single record.

> [!IMPORTANT]
> All action links are rendered conditionally when criteria are met.

> [!IMPORTANT]
> Actions related to Order status change does not guarantee that status change would actually occurs as record may be updated by other user. In this case an error will be shown and table will be refreshed.

Custom related list is implemted at **accountOrders** lwc, which has **AccountOrdersController** Class as a controller.

**AccountOrdersController** implements server-side pagination using **StandardSetController**.

## Considerations

1. There are no bugless implementations. Those just not tested enough;
2. Repo deployment may override your changes;
3. Implementation uses [FFLib ApexMocks Framework](https://github.com/apex-enterprise-patterns/fflib-apex-mocks), but think of updating it if used to follow UoW pattern.

## Testing

In order to simplify testing, there is an apex script called **generateData**, designed to seed necessary data. Consider executing it using below command:
```bash
sfdx force:apex:execute -f scripts/apex/generateData.apex
```
> [!IMPORTANT]
> File path to **generateData** script may needs to be adjusted depending on directly opened in terminal.

## License

[SoftServe, Inc.](https://www.softserveinc.com/uk-ua)