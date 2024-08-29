# Environment

Kubecost requires a Kubernetes cluster to be deployed.

## Supported Kubernetes versions

* Users should be running Kubernetes 1.21+.
* Kubernetes 1.29 is officially supported as of v2.
* Versions outside of the stated compatibility range may work, depending on individual configurations, but are untested.

## Supported cluster types

* Managed Kubernetes clusters (e.g. EKS, GKE, AKS) most common
* Kubernetes distributions (e.g. OpenShift, DigitalOcean, Rancher, Tanzu)
* Bootstrapped Kubernetes cluster
* On-prem and air-gapped using custom [pricing sheets](/install-and-configure/install/provider-installations/air-gapped.md#how-do-i-configure-prices-for-my-on-premise-assets)

## Supported Cloud Providers

* AWS (Amazon Web Services)
  * All regions supported, as shown in [opencost/pkg/cloud/awsprovider.go](https://github.com/opencost/opencost/blob/0c2f063052723a65ca62a4c75be23392806b6fac/pkg/cloud/awsprovider.go#L111)
  * x86, ARM
* GCP (Google Cloud Platform)
  * All regions supported, as shown in [opencost/pkg/cloud/gcpprovider.go](https://github.com/opencost/opencost/blob/0c2f063052723a65ca62a4c75be23392806b6fac/pkg/cloud/gcpprovider.go#L41)
  * x86
* Azure (Microsoft)
  * All regions supported, as shown in [opencost/pkg/cloud/azureprovider.go](https://github.com/opencost/opencost/blob/0c2f063052723a65ca62a4c75be23392806b6fac/pkg/cloud/azureprovider.go#L82)
  * x86

**This list is certainly not exhaustive!** This is simply a list of observations as to where our users run Kubecost based on their questions and feedback. Please [contact us](/CONTACT.md) with any questions!
