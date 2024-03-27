# Importing Kubecost Data into Microsoft Power BI

Microsoft Power BI is a data visualization tool which can be used for more advanced or customized analysis of your Kubecost spend data. Power BI is able to accept data retrieved from any standard Kubecost API endpoint, such as queries into your primary Monitoring dashboards (Allocation, Assets, and Cloud Costs). This document will show you how to import your Kubecost data into Power BI.

## Importing your data

In Power BI, select _Get data_ from the toolbar (select the text, not the icon itself) to open the Common data sources dropdown. When pulling data from an API, you need a web connector, so select _Web_ from the dropdown. The From Web window opens.

In the From Web window, select _Basic_, then in the URL box, enter the endpoint for the data you want to receive in Power BI. An example endpoint of Allocation data from the last three days aggregated by namespace will look like:

`http://<your-kubecost-address>/model/allocation?window=3d&aggregate=namespace`

To learn more about using Kubecost APIs, see our [API Directory](/apis/apis-overview.md).

![From Web window with an example Allocation query](/.gitbook/assets/from-web.png)

Once you've submitted a valid endpoint, select _OK_ to confirm. Be patient while Power BI loads your data. You have now successfully imported your Kubecost data into Power BI. You can perform these steps multiple times to import multiple sets of data into the same file.

### Refreshing your data

Importing your Kubecost data into Power BI will first generate static metrics. However, you will be able to refresh your query automatically so you don't need to repeat the above steps. Select _Refresh_ from the toolbar to refresh your query.

For information on modeling your data after it's been imported, consult Microsoft's [Power BI documentation](https://learn.microsoft.com/en-us/power-bi/).
