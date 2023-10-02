# Changes Description
Introduced new classes:
- 'AccountsService.cls' responsible for updating Accounts before insert to make sure they have Active field set to Yes and preventing updates of inactive Accounts with adding error on records. Also it uses Custom Permission to 'Account Allow Reactivate'.
- 'AccountTriggerHandler.cls' handler that provides wrap logic for trigger and supports before insert and before update operations.
New trigger 'Account.trigger' for Account objects.
New Custom Permission 'Account Allow Reactivate' to allow Administrators or responsible persons reactivate Account if it was accidentaly deactivated.
New Permission Set 'Allow Account Reactivation' containing Custom permission 'Account Allow Reactivate'
New fields for Features Enabler:
- Account.Trigger - Enable/Disable Account Trigger Handler functionality
- Account.PreventUpdatesOnInactive - Enable/Disable inactive accounts modifications prevention
- Account.MakeActiveOnInsert - Enable/Disable automatic Active field assignment to 'Yes'
Updated 'Constants.cls' with new error messages.
# Pre-Deployment Manual Steps
None.
# Metadata Changes Listing
- Apex Classes:
    - AccountsService.cls
    - TestAccountsService.cls
    - AccountTriggerHandler.cls
    - TestAccountTriggerHandler.cls
    - TestAccountTrigger.cls
    - Constants.cls
- Triggers:
    - Account.trigger
- Custom Permissions:
    - Account_AllowReactivate.customPermission-meta.xml
- Permission Sets:
    - Allow_Account_Reactivation.permissionset-meta.xml
- Custom Fields:
    - Account_MakeActiveOnInsert__c.field-meta.xml
    - Account_PreventUpdatesOnInactive__c.field-meta.xml
    - Account_Trigger__c.field-meta.xml

# Post-Deployment Manual Steps
After deployment run all tests and ensure that all tests executed successfully.
As needed assign Allow Account Reactivation Permission Set to person responsible for Accounts Reactivation.