# Install Kubecost on Red Hat OpenShift

Kubecost supports deploying to Red Hat OpenShift (OCP) and includes options and features which assist in getting Kubecost running quickly and easily with OpenShift-specific resources.

## Deployment options

There are two main options to deploy Kubecost on OpenShift.

1. [Standard Helm chart deployment](#standard-deployment-guide)
2. [OpenShift Community Operator](#community-operator-deployment-guide)

More details and instructions on both deployment options are covered in the sections below.

## Standard deployment guide

### Overview

A standard deployment of Kubecost to OpenShift is no different from deployments to other platforms with the exception of additional settings which may be required to successfully deploy to OpenShift.

Kubecost is installed with Cost Analyzer and Prometheus as a time-series database. Data is gathered by the Prometheus instance. Kubecost then pushes and queries metrics to and from Prometheus.

The standard deployment is illustrated in the following diagram.

![Standard deployment](/images/diagrams/openshift-cluster.png)

### Prerequisites

* An existing OpenShift or OpenShift-compatible cluster (ex., OKD).
* Access to the cluster to create a new project and deploy new workloads.
* `helm` CLI installed locally.

### Installation

Add the Kubecost Helm chart repository and scan for new charts.

```sh
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update
```

Install Kubecost using OpenShift specific values. Note that the below command fetches the OpenShift values from the development branch which may not reflect the state of the release which was just installed. We recommend using the corresponding values file from the chart release.

```sh
helm upgrade --install kubecost kubecost/cost-analyzer -n kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/<$VERSION>/cost-analyzer/values-openshift.yaml
```

Because OpenShift disallows defining certain fields in a pod's `securityContext` configuration, values specific to OpenShift must be used. The necessary values have already been defined in the OpenShift values file but may be customized to your specific needs.

If you want to install Kubecost with your desired cluster name, provide the following values to either your values override file or via the `--set` command. Remember to replace the cluster name/id with the value you wish to use for this installation.

```sh
--set kubecostProductConfigs.clusterName=my-ocp-cluster
--set prometheus.server.global.external_labels.cluster_id=my-ocp-cluster
```

Other OpenShift-specific values include the ability to deploy a Route and SecurityContextConstraints for optional components requiring more privileges such as Kubecost network costs and Prometheus node exporter. To view all the latest OpenShift-specific values and their use, please see the [OpenShift values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-openshift.yaml).

If you have not opted to do so during installation, it may be necessary to create a Route to the service `kubecost-cost-analyzer` on port `9090` of the `kubecost` project (if using default values). For more information on Routes, see the OpenShift documentation [here](https://docs.openshift.com/container-platform/4.13/networking/routes/route-configuration.html).

After installation, wait for all pods to be ready. Kubecost will begin collecting data and may take up to 15 minutes for the UI to reflect the resources in the local cluster.

### Using in-cluster Prometheus

{% hint style="warning" %} 
This installation method is available, but not generally recommended. Please review the following documentation before proceeding. [Documentation](/install-and-configure/advanced-configuration/custom-prom).
{% endhint %}

If required Kubecost can leverage an existing Prometheus that exists on your cluster, as opposed to installing Kubecost's bundled Prometheus.

1. First, add the following label to the namespace where Kubecost will be deployed:

```sh
oc label namespace kubecost openshift.io/cluster-monitoring=true
```

2. Install Kubecost with the following command:

```sh
helm upgrade --install kubecost kubecost/cost-analyzer -n kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/<$VERSION>/cost-analyzer/values-openshift-cluster-prometheus.yaml
```

After installation, wait for all pods to be ready. Kubecost will begin collecting data and may take up to 15 minutes for the UI to reflect the resources in the local cluster.


## Community operator deployment guide

### Overview

Kubecost offers a Red Hat community operator which can be found in the Operator Hub catalog of the OpenShift web console. When using this deployment method, the operator is installed and a Kubernetes [Custom Resource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) is created which then triggers the operator to deploy the Helm chart. The chart deployed by the community operator is the same chart which is referenced in the standard deployment.

### Prerequisites

* An existing OpenShift cluster.
* Access to the cluster to create a new project and deploy new workloads.

### Installation

Log in to your OCP cluster web console and select _Operators_ > _OperatorHub_ > then enter "Kubecost" in the search box.

![Discovery](/images/ocp-operator-discovery.png)

Click the Install button to be taken to the operator installation page.

On the installation page, select the update approval method and then click Install.

![Installation step 1a](/images/ocp-operator-installation-step-1.png)

Once the operator has been installed, create a namespace in which to deploy a Kubecost installation.

![Installation step 1b](/images/ocp-operator-installation-step-1b.png)

```sh
oc create ns kubecost
```

You can also select _Operators_ > _Installed Operators_ to review the details as shown below.

![Installation step 1c](/images/ocp-operator-installation-step-1c.png)

Once the namespace has been created, create the CostAnalyzer Custom Resource (CR) with the desired values for your installation. The CostAnalyzer CR represents the total Helm values used to deploy Kubecost and any of its components. This may either be created in the OperatorHub portal or via the `oc` CLI. The default CostAnalyzer sample provided is pre-configured for a basic installation of Kubecost.

To create the CostAnalyzer resource from OperatorHub, from the installed Kubecost operator page, click on the CostAnalyzer tab and click the Create CostAnalyzer button.

![Installation step 2](/images/ocp-operator-installation-step-2.png)

Click on the radio button YAML view to see a full example of a CostAnalyzer CR. Here, you can either create a CostAnalyzer directly or download the Custom Resource for later use.

Change the `namespace` field to `kubecost` if this was the name of your namespace created previously.

![Installation step 3](/images/ocp-operator-installation-step-3.png)

Click the Create button to create the CostAnalyzer based on the current YAML.

After about a minute, Kubecost should be up and running based upon the configuration defined in the CostAnalyzer CR. You can get details on this installation by clicking on the instance which was just deployed.

If you have not opted to do so during installation, it may be necessary to create a Route to the service `kubecost-cost-analyzer` on port `9090` of the `kubecost` project (if using default values). For more information on Routes, see the OpenShift documentation [here](https://docs.openshift.com/container-platform/4.13/networking/routes/route-configuration.html).
