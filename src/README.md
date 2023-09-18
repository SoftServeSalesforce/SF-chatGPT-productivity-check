# General Description

The Account Orders Manager is an innovative Lightning Web Component (LWC) designed to seamlessly integrate with Account record page, enriching it with a dynamic table that lists related orders. The table not only showcases order details but also allows users to instantly navigate to a specific order record by simply clicking on its number. For each order, users can quickly view or download the latest attached invoice, ensuring essential financial data is always at their fingertips.

Furthermore, the component bolsters productivity by empowering users to select one or multiple orders and effortlessly update their statuses. To enhance the user experience, the table includes an intelligent pagination system, with the added ability to customize and store the preferred page size in custom settings. As an additional insight-driven feature, the table computes the duration since the last status modification for each order and displays this valuable information, helping users track progression of their orders.


# Data Setup for Manual Testing

1. Make sure you have set a default devhub in your project. If not, configure or create one.

2. Once you have a default devhub, run "sf org create scratch -f config/project-scratch-def.json -a <scratchAliasName> -d". Please use paste your aliasName intead of <scratchAliasName>.

3. Run "sf project deploy start". Make sure code deployment completes without errors.

4. Run "sf apex run --file scripts/apex/generateData.apex". Check if all of the necessary records have been inserted without issues.

5. Run "sf org open". This will lead you to a new browser tab with your freshly created scratch org.

6. Select nine dots at the top left corner. Type in "Accounts". Select the option.

7. You should get the account default list view. Select "Softserve inc." account.

8. Scroll down to the bottom of the account record page. You should see our custom lwc table with related orders. 
⋅⋅* Check if order numbers are clickable and forward you to the order record page. 
⋅⋅* Make sure "Status" column correctly states the status and time since last order status update. 
⋅⋅* Check if dropdown menu on each record works. Depending on the status of the order and linked document presence, menu options should differ. 
⋅⋅* Use "Invoice" column to download related invoice document if available. Also check if in the same order actions menu has "preview invoice" and "download invoice". 
⋅⋅* Make sure that actions menu has "Activate" option for orders with status "Draft". Also make sure that actions menu has "Mark as shipped" status for orders with status "Activated". 
⋅⋅* Select multiple orders with different status - no option except for "refresh" should be action on the top action bar above the table. 
⋅⋅* Select multiple orders with status "Draft" - option "Activate" above the table should become available. Push the button. Make sure selected orders changed their status. Do the same with "Activated" status orders. 
⋅⋅* Check if pagination works. Change page size, refresh the browser tab to make sure your new preference is stored in the custom settings. 


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
