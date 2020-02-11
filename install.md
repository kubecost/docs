# Installing Kubecost
<br/>

* The recommended path to install and operate Kubecost is via the Helm chart install instructions available at [kubecost.com/install](http://kubecost.com/install). This chart contains all the required components to get started and can scale to large clusters. It also provides the most flexibility for configuring Kubecost and its dependencies.

* Alternatively, you can install via [flat manifest](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/README.md#manifest), but this install path provides less flexibility for managing your deployment and has several product limitations.

* Lastly, you can deploy the open-source cost model engine directly as a pod. This install path provides a subset of Kubecost functionality and is available [here](https://github.com/kubecost/cost-model/blob/master/deploying-as-a-pod.md). Specifically, this install path deploys the underlying cost allocation model without UI or enterprise functionality, e.g. SAML support. 

<br/><br/>
<br/><br/>
