## Application Description:

Our Salesforce application is a dynamic and user-friendly Lightning Web Component (LWC) controlled by Apex, designed to streamline the management of orders associated with customer accounts. The centerpiece of this application is a versatile table that presents a comprehensive overview of orders, providing valuable tools for order status management and easy access to invoice files. The table is thoughtfully designed with a user-friendly interface, and it offers convenient customization options for pagination, ensuring a seamless user experience.

This application simplifies the process of order management within Salesforce, enhancing efficiency and productivity for your sales and customer support teams. With its intuitive design and robust functionality, it empowers users to effortlessly track, update, and organize orders, ultimately leading to improved customer satisfaction and more effective account management.

## Manual Testing Setup:
To manually test our Salesforce application, follow these steps:

1. Open your Salesforce CLI and run the following command to generate test data: `sf force apex execute -f scripts/apex/generateData.apex.`

2. Once the test data is generated, navigate to the account named `'Softserve Inc.'` within your Salesforce instance.

3. Use the table to experiment with order status management, view invoice files, and customize pagination as needed. Test different scenarios and ensure that the application responds as expected.

By following these steps, you can thoroughly test our application's functionality and confirm that it effectively streamlines order management within Salesforce for improved productivity and customer service.


---
<details>
    <summary>Default readme</summary>

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
</details>
