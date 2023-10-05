Change Description

	•	Account.Trigger - Trigger Before Insert and Before update actions calling AccountTriggerHandler
	•	AccountTriggerHandler - checks if Custom Settings(FeatureEnabler) is enabled and handle operations (before insert/before update) invoking AccountService
	•	AccountsService - is responsible to set Active field to YES when record is created and prevent any field Update on Account record if Active field is set to NO
--------------------------
Pre-deployment steps
No pre-deployment Activities

-----------------------
Metadata changes listing
Classes:
- AccountService.cls
- AccountTriggerHandler
- Constants
- TestAccountService
- TestAccountTriggerHandler
- TestAccountTrigger
	

Trigger:
- AccountTrigger

----------------------
Post deployment
No post Deployment activities
