## Install with Helm (Recommended Method)

{% hint style="info" %}
**License Key Required** [Click Here](https://kubecost.com/install.html) to acquire your free community edition license key! You will need this to install **Kubecost**
{% endhint %}

### Pre-requisites

- Install [Helm](https://gethelm.com)
- Connect [Kubectl] to your cluster

### Install

```bash
# Create a dedicated namespace for Kubecost
kubectl create namespace kubecost
# Add the Kubecost Helm repository
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
# Install Kubecost with your Community License Key
helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="<License Key here>"
```

### Verify Install

We'll quickly port forward to the user interface so you can see Kubecost data!

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

### What's Next

We recommend connecting the cloud provider you're using to Kubecost to compile all of your cloud costs into a single pane of glass.
Click the next link below to get started!
