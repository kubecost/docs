# Kubecost Cloud GCP Marketplace Licensing

Kubecost Cloud is [available for licensing on GCP Marketplace](https://console.cloud.google.com/marketplace/product/kubecost-public/kubecost-cloud) and can be installed in minutes. This guide will take you through licensing through GCP Marketplace, and next steps for setting up Kubecost Cloud. Kubecost currently offers 30 days of Kubecost Cloud free without licensing fees.

{% hint style="info" %}
Licensing Kubecost Cloud through GCP Marketplace will not directly integrate your GCP billing data into your Kubecost Cloud environment. For more information, see our [GCP Cloud Integration guide](/kubecost-cloud/kubecost-cloud-cloud-billing-integrations/kubecost-cloud-gcp-integration.md).
{% endhint %}

## Prerequisites

* Set up a Google Cloud account with an attached [billing account](https://cloud.google.com/billing/docs/how-to/create-billing-account).
* [Set up a Kubecost Cloud account](/kubecost-cloud/cloud-installation-and-onboarding.md#creating-a-user-account)

## GCP Marketplace licensing guide

On the [Product details page for Kubecost](https://console.cloud.google.com/marketplace/product/kubecost-public/kubecost-cloud), select _Subscribe_. You will be taken to an Order Summary page.

![Order Summary page](/images/order-summary.png)

Under "1. Select Plan", the default plan should be Cloud Pro, and the default usage fee should be USD 0.167 per node per day. You can use the Pricing Calculator in the right sidebar to determine estimated costs by providing estimated time frame of usage from 1 day to 1 year, and total node count.

![Pricing Calculator](/images/pricing-calculator.png)

Under "2. Purchase Details", select the billing account you wish to associate Kubecost Cloud with from the dropdown.

Under "3. Terms", read and agree to the terms and conditions, which include Google Cloud Marketplace Terms of Service as well as the Kubecost Terms of Service. Then, select _Subscribe_. Wait a moment while your order request is processed. Select _Go to Product Page_ in the pop-up which should appear once the order has been sent to Kubecost. If you have not already, select _Sign up with provider_ on the product page and provide all necessary user info to get your Kubecost Cloud account set up. Purchase orders should be automatically processed. Refresh the product page until you see _Manage on Provider_. Selecting this will take you from GCP Marketplace to the Kubecost Cloud login page.

![Kubecost Cloud product page](/images/kc-cloud-gcp.png)

You should now have access to the Kubecost Cloud dashboard.

## Next steps

After having licensed Kubecost Cloud, you are able to install the Kubecost Cloud Agent onto all clusters you want to receive cost metrics for. See our existing [Kubecost Cloud Installation and Onboarding](/kubecost-cloud/cloud-installation-and-onboarding.md) guide for help getting started.


