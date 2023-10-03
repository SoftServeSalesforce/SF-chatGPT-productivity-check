# Changes Description
Introduced new classes:
- 'CreateActionsUnsupportedException.cls' used for defining unsupported type exception.
- 'ContactSelector.cls' responsible for selecting Contact with AccountId if available.
- 'CreateActionsController.cls' class for Create Actions LWC component, handles logic of providing default values for Case creation. Contains 'NewCaseDetailsResponse.cls' that helps wrap output to LWC component.

Modified 'Constants.cls' with new constants.
Created new LWC Component Create Actions with button to create new Case. Handles UI logic, builds url from Apex Controller data to be opened by Aura wrapper. 
Created new Aura Component Create Actions Wrapper Aura responsible for passing record Id to LWC component, opening new tab in Customer Support App.
Created Create Actions message channel to pass data from LWC to Aura component.
Modified Customer Support UtilityBar to add new Action button - Create Actions based on Aura wrapper component.
Created new Exception CreateActionsUnsupportedException.cls 

Updated 'Constants.cls' with new error messages.
# Pre-Deployment Manual Steps
None.
# Metadata Changes Listing
- Apex Classes:
    - ContactSelector.cls
    - TestContactSelector.cls
    - CreateActionsUnsupportedException.cls
    - CreateActionsController.cls
    - TestCreateActionsController.cls
    - TestDataFactory.cls
    - Constants.cls
- Aura Components:
    - <details>
        <summary>createActionsWrapperAura</summary>

        - createActionsWrapperAura.cmp
        - createActionsWrapperAura.cmp-meta.xml
        - createActionsWrapperAura.design
        - createActionsWrapperAura.svg
        - createActionsWrapperAura.css
        - createActionsWrapperAura.auradoc
        - createActionsWrapperAuraController.js
        - createActionsWrapperAuraHelper.js
        - createActionsWrapperAuraRenderer.js
        <details>
- LWC Components:
    - <details>
        <summary>createActions</summary>

        - createActions.html
        - createActions.js
        - createActions.js-meta.xml
        <details>
- Message Channels:
    - createActions.messageChannel-meta.xml
- Flexipages:
    - Customer_Support_UtilityBar.flexipage-meta.xml

# Post-Deployment Manual Steps
After deployment run all tests and ensure that all tests executed successfully.