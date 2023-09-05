Application Desctiption:
The application helps to work with Account related orders on the Account record page.
The page has embedded LWC component accountRelatedOrders which retrieves related to account orders with attachments with latest salesforce file attached to order with name that starts with 'Invoice'.
The functionality allows user to set order status to 'Activated' via Activate row action, set status to 'Shipped' via Mark as shipped row action. 
User can download file within download icon click in the table row or within row action select Download. Preview attachment via ro action Preview.
For mass order processing have 'Activate' and 'Mark as Shipped' buttons, user need to select orders via checkbox for these actions. Only 'Draft' orders allowed to activate and 'Activated' to mask as shipped.
Table is reactive, so any updates instantly reflected.


# Testing
To setup test data - use command through CLI: sfdx force:apex:execute -f scripts\apex\generateData.apex
After successfull execution of the script Account named 'SoftServe Inc.' could be used for testing purposes.


# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

