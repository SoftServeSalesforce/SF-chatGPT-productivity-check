Change Description

	•	ContactSelector - query Contact with AccountId if available.
	•	CreateCaseActionController -  handles responses to the LWC building the URL for Case/Contact/Account

New LWC Component 'utilityBarCreateActions' which holds the button to ‘Create Case’.Handles UI logic, retrieve the URL from 'CreateCaseActionController' to be opened by Aura component ‘utilityBarCrateActions’. Created new Aura Component ‘utilityBarCrateActions’ responsible for passing record Id to LWC component, opening new tab in Customer Support App. 
Created ‘utilityBarcreateActions.messageChannel’ to pass data from LWC to Aura component. 

------------------
Pre-deployment steps
No pre-deployment Activities

----------------------
Metadata changes listing

Classes:
- ContactSelector
- CreateCaseActionController
- TestCreateCaseActionController
- TestContactSelector

Aura Components:
- utilityBarCrateActions

LWC Components:
- utilityBarCreateActions

Message Channels:
-utilityBarcreateActions.messageChannel

Flexipages:
- Customer_Support_UtilityBar.flexipage

Permission set:
- Access_customer_support_app (added apex permission to contactSelector and CreateCaseActionController classes)

---------------------
Post deployment

All component will get through deployment, no need of manual post-deployment activities.

For testing functionality, follow the below:

Create new User according to specifications below:
a.	First Name: Customer Support;
b.	Last Name: Agent;
c.	Role: None;
d.	User License: Salesforce;
e.	Profile: Customer Sipport;
f.	Active: Checked;
5.	Assign “	Customer Support Member” Permission Group to newly-created User;
6.	Create Default Organization Level Value of “Features Enabler” Custom Setting with all items checked;


