# Kubecost Cloud GCP Marketplace Install

Kubecost Cloud is [available on GCP Marketplace](https://console.cloud.google.com/marketplace/product/kubecost-public/kubecost-cloud) and can be installed in minutes. This guide will take you through the installation and getting set up on Kubecost Cloud.

## Prerequisites

* Set up a Google Cloud account
* Have a Project with at least one GCP cluster and a [billing account](https://cloud.google.com/billing/docs/how-to/create-billing-account).
* [Set up a Kubecost Cloud account](kubecost-cloud/cloud-installation-and-onboarding.md#creating-a-user-account)

## GCP Marketplace install guide

On the [Product details page for Kubecost](https://console.cloud.google.com/marketplace/product/kubecost-public/kubecost-cloud), select _Get Started_. You will be taken to the Agreements page. Confirm the Project you want Kubecost Cloud associated with, then agree to the terms and agreements. After agreeing to terms, you can return to the product page or select _Deploy_ to begin installation.

### Deploying Kubecost on GKE

Provide all necessary details about your environment for Kubecost to install successfully:

* Existing Kubernetes Cluster: Select an existing cluster in your Project from the dropdown, or create a new cluster. Kubecost Cloud supports multi-cluster environments, however you must first choose a singular cluster on which to install Kubecost Cloud.
* Namespace: Select a namespace from the dropdown in which to deploy the application.
* App instance name: Provide a name for the application instance to be created within the above namespace.

There are checkboxes below for optional configuration. All features are disabled by default, and should only be enabled based on your environment needs. Enter names for both a Prometheus Service Account and Cost-analyzer Service Account to be created (set to _default_). Finally, select _Deploy_.

You will be taken to the Applications page of GCP's Kubernetes Engine while Kubecost Cloud install. Be patient will it loads. Select _Manage on Provider_ on the Kubecost Cloudonce the option becomes available. This will take you to the Kubecost Cloud home page. Log in with your Kubecost Cloud account.
