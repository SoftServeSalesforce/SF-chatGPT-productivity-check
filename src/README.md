# Description

The Application facilitate users working with Accounts and related Orders. The Component orderTableview is embedded in Account page and renders all related Account’s Orders. The user has the possibility to view order Number which has a link to the order record itself, the time in which the order is in Status Draft/Activated/Shipped, Amount,Date,Amount and allows the user to edit the status via inline row action. Updating the status re-render the component showing the new Status. User will be able to also preview/download file related to an Order whenever they contains ‘invoice’ in the file title. User has also possibility to mass activate and mark as sent orders via checkbox which streamline the order update process in a single view. Component also offers the pagination view with possibility to select record size per page, navigate to next and previous page and also having information of total orders number related to the Account

# Manual Testing

User can setup the data for manual testing running command :sfdx force:apex:execute -f scripts\apex\generateData.apex. Alternatively user can run generateData.apex in Anonymous Developer console to load data. The script will create an Account named Softserve.inc,related,400 orders and 5 new products. Related files titled ‘invoice’ will be also loaded to test the preview/download logic.


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
