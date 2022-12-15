Supported Environments
======================

## Supported Cloud Providers

* AWS (Amazon Web Services)
  * All regions supported, as shown in [opencost/pkg/cloud/awsprovider.go​](https://github.com/opencost/opencost/blob/0c2f063052723a65ca62a4c75be23392806b6fac/pkg/cloud/awsprovider.go#L111)
  * x86, ARM
* GCP (Google Cloud Platform)
  * All regions supported, as shown in [opencost/pkg/cloud/gcpprovider.go​](https://github.com/opencost/opencost/blob/0c2f063052723a65ca62a4c75be23392806b6fac/pkg/cloud/gcpprovider.go#L41)
  * x86
* Azure (Microsoft)
  * All regions supported, as shown in [opencost/pkg/cloud/azureprovider.go​](https://github.com/opencost/opencost/blob/0c2f063052723a65ca62a4c75be23392806b6fac/pkg/cloud/azureprovider.go#L82)
  * x86

## Supported Cluster Types

* ​Managed Kubernetes clusters (e.g. EKS, GKE, AKS) *most common*
* ​Kubernetes distributions (e.g. OpenShift, DigitalOcean, Rancher, Tanzu)
* ​Bootstrapped Kubernetes cluster​
* On-prem and air-gapped using custom [pricing sheets](https://guide.kubecost.com/hc/en-us/articles/4407601795863#q-how-do-i-configure-prices-for-my-on-premise-assets)

**This list is certainly not exhaustive!** This is simply a list of observations as to where our users run Kubecost based on their questions/feedback.

## Supported Kubernetes Versions

* Kubecost runs in any Kubernetes v1.8 (Aug 2017) or greater environment.
* Kubernetes 1.22 is officially supported as of v1.91.0
