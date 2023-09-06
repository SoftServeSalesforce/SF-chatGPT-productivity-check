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

## Application Description
Usage-ready LWC component controlled by Apex, designed to view related Account Orders with custom actions available. Enhanced status view for better managing over orders. Preview and download orders directly on the page. Availability of header actions to quickly manage multiple orders. Component supports pagination with an automatic save of selected records amount view individually for each user. For Invoice component checks for attached files on Order - only files starting with Invoice* and Latest creation date are displayed and available for download. 

## Quick Demo Setup
After deploying component with tests runs, from src folder run
```
sf force apex execute -f scripts/apex/generateData.apex
```
if you using latest SFDX or for older SFDX versions:
```
sfdx force:apex:execute -f scripts/apex/generateData.apex
```
Now go to the Sales app in Salesforce org, open Accounts and find the SoftServe Inc. account. After opening an account on the related tab you can see a new component displaying orders. Each Order has 5 Order items. There are Orders with PDFs attached to them, evenly distributed per Order status. There are 100 Orders without attachments, 100 with test pdf attached, 100 with Invoice pdf and 100 with both. Test pdf files are not visible on the component itself, we want only the Invoice to be actually on the component.