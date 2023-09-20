## **Application Overview**

This application introduces a dynamic **Lightning Web Component (LWC)** designed primarily for displaying and managing orders associated with specific Salesforce accounts. Tailored to optimize the user experience, the component simplifies order viewing by presenting them in an intuitive interface, streamlining user interactions and enhancing overall order management efficiency.

## **Features and Functionality**

Beyond just displaying orders, the component provides seamless functionalities to work directly with the orders - whether it's updating their statuses or performing batch operations. Embedded within the component are user-friendly actions like **'Activate'**, **'Mark as Shipped'**, and **'Refresh'**, granting users the flexibility and power to manage orders with just a few clicks. The application stands as an invaluable tool for businesses looking to streamline their order management processes on the Salesforce platform.

## **Testing & Sample Data Generation**

To facilitate manual testing and provide a comprehensive view of the application's capabilities, we've included an Apex script that generates a rich set of sample data. By running this script, you can populate your Salesforce org with example orders, products, and related records, allowing for a hands-on experience with the LWC component.

To execute the script and generate the testing data, use the following Salesforce CLI command:

```sh
sfdx force:apex:execute -f scripts/apex/generateData.apex
