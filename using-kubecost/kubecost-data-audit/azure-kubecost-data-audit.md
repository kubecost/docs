# Azure/Kubecost Data Audit

### Performing a data audit

First, in the Kubecost user interface, [view the price of a single node for a single day](/using-kubecost/kubecost-data-audit/README.md). Note, that Kubecost breaks out each VM within a VMSS (Virtual Machine Scale Set) as its own line item.

<figure><img src="../../images/data-auditing/dataaudit-azure-kubecost.png" alt=""><figcaption></figure>

Next, compare this node's costs with what is found in Azure Cost Management (Amortized). Ensure you adjust the date range, and filter for the VMSS.

<figure><img src="../../images/data-auditing/dataaudit-azure-acm.png" alt=""><figcaption></figure>

### Troubleshooting non-matching costs

* Check whether Kubecost's price of a single node for a single day matches with the Azure Cost Export CSV file. The CSV will be located in the bucket configured for [Azure Cloud Billing Integration](/azure-out-of-cluster.md).
* Check whether the Azure Cost Export is [configured correctly](/azure-out-of-cluster.md).
* Check whether the CSV line items in the Azure Cost Export matches with the Azure Cost Management Dashboard.
