# What is Kubecost Cloud?

Kubecost Cloud is a SaaS solution that offers easier deployment and more convenient maintenance as an alternative to our on-prem product. You can get started with a free trial [here](http://app.kubecost.com/signup).

## Functionality

### What features are currently available?

Kubecost Cloud will provide you with everything you need in order to visualize your cost spend data and begin saving, with many more features to come soon. Kubecost Cloud currently supports:

* Allocations, Assets, and Cloud Cost dashboards for multiple Kubernetes clusters
* Cloud integration for AWS, GCP, and Azure billing
* Savings page with container right-sizing, cluster right-sizing, and abandoned workload detection
* SSO via Google, Microsoft, Okta, and GitHub
* Saved reports of your monitoring dashboard data
* Team and user management
* Overview homepage

### What features are coming next?

Kubecost Cloud's functionality will be quickly expanded. Here's a sneak peek at which features we plan to implement next:

* Clusters dashboard
* Shared and idle costs
* RBAC
* Expanded Savings page options

## Is Kubecost Cloud right for me?

Kubecost Cloud can help teams oversee cloud spend like our existing product, but there are more reasons this hosted version can be advantageous:

* Simplicity: Kubecost will handle your upgrades, scaling, and maintenance.
* Cost effective: Kubecost Cloud will empower users to think big, start small, and scale quickly. Save on team time when you don’t host on-prem.
* Security: We take responsibility for ensuring information on our servers is secure and private.

## Requirements

Kubecost Cloud has been tested with deployments of up to 1,000 nodes. Please reach out to us [via support channels listed below](https://docs.google.com/document/d/1aC\_Xx4\_IHm392vCMcDVy6ereTSHB4IuPcqkuQRQackU/edit#heading=h.y90zj4a1kvu3) if you have any questions or issues about any of these requirements.&#x20;

### Environments supported

* Kubernetes 1.8+
* Helm 3.1+
* Does not support air-gapped environments

### Resource requirements

* In a small Kube cluster (less than 20 nodes), the Kubecost Cloud Agent total resource usage is approximately:
  * 2 GiB RAM
  * .5 CPUs
* The network costs DaemonSet will add a per node resource usage at:
  * 20 MiB RAM
  * .05 CPU

### **Cluster requirements:**

* Supports all major cloud Kubernetes services (EKS, AKS, GKE)
* Supports on-prem Kubernetes clusters
* Supports self-managed clusters on AWS, GCP, and Azure.&#x20;

## Using existing Kubecost documentation

Kubecost Cloud brings lots of the same functionality from our existing on-prem product, but there are several distinct differences in their composition that may prevent you from consulting standard Kubecost documentation for assistance. We do not recommend you consult our other live documentation resources for help, and instead contact us directly at [cloud-support@kubecost.com](mailto:cloud-support@kubecost.com) with questions. Hyperlinks embedded in this group of docs may take you to live Kubecost web properties for additional information where relevant.

All information found in this group of docs will be applicable for your installation and experience. Over time, we hope to expand this group to assist with troubleshooting and support.
