# Installing Kubecost
<br/>

We strongly recommend using the [Kubecost helm chart](http://kubecost.com/install) to install and operate Kubecost. This install method is available for free and contains all the required components to get started, provides access to all Kubecost features, and can scale to large clusters. It also provides the most flexibility for configuring Kubecost and its dependencies.

Alternative install options:

* You can run [helm template](https://helm.sh/docs/helm/helm_template/) against the [Kubecost helm chart](http://kubecost.com/install) to generate local YAML output. This requires extra effort when compared to directly installing the helm chart but is more flexible than deploying static YAML.

* You can install via [flat manifest](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/README.md#manifest). This install path provides less flexibility for managing your deployment and has several product limitations, e.g. Thanos is not easily enabled.

* Lastly, you can deploy the open source cost-model directly as a pod. This install path provides a subset of Kubecost functionality and is available [here](https://github.com/kubecost/cost-model/blob/master/deploying-as-a-pod.md). Specifically, this install path deploys the underlying cost allocation model without UI or enterprise functionality, e.g. SAML support. 

<br/><br/>
<br/><br/>
