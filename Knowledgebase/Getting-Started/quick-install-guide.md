Quick Intall Guide
==================

Welcome! This guide will walk you through installing Kubecost into your Kubernetes cluster. The Kubecost helm chart includes all product dependencies and takes only a few minutes to install.

## **Before you begin**

In order to deploy the Kubecost helm chart, ensure the following are completed:

\1. Helm client (version 2.14+) installed [(Helm install doc)](https://helm.sh/docs/intro/install/)

\2. When using helm 2 on clusters with RBAC enabled, run the following commands to grant Tiller permissions. [Learn more](https://v2.helm.sh/docs/rbac/)

```
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=<your-userid> kubectl create clusterrolebinding cluster-self-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

## **Step 1: Install Kubecost**

Running the following commands will also install Prometheus, Grafana, and kube-state-metrics in the namespace supplied. View install configuration options [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/README.md#config-options).

**helm 2**

```
helm repo add kubecost https://kubecost.github.io/cost-analyzer/

helm install kubecost/cost-analyzer --namespace kubecost --name kubecost --set kubecostToken="c3RhY3lAa3ViZWNvc3QuY29txm343yadf98"
```

**helm 3**

```
kubectl create namespace kubecost

helm repo add kubecost https://kubecost.github.io/cost-analyzer/

helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="c3RhY3lAa3ViZWNvc3QuY29txm343yadf98"
```

**Note:** if you receive a message stating the installation is "forbidden" then see the instructions above on granting RBAC permissions.

Having installation issues? View our [Troubleshooting Guide](http://docs.kubecost.com/troubleshoot-install) or contact us directly at team@kubecost.com.

## **Step 2: Enable port-forward**

```
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090 
```

## **Step 3: See the data! 🎉**

You can now view the deployed frontend by visiting the following link. Publish :9090 as a secure endpoint on your cluster to remove the need to port forward.

[http://localhost:9090](http://localhost:9090/)

 

With this newfound visibility, teams often start with **1)** looking at cost allocation trends and **2)** searching for quick cost savings or reliability improvements. View our [Getting Started](http://docs.kubecost.com/#getting-started) guide for more information on product configuration and common initial actions.

We're available any time for questions or concerns at team@kubecost.com and Slack ([invite](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU)).

 

## **Updating Kubecost**

Now that your Kubecost chart is installed, you can update with the following commands:

**helm 2**

```
helm repo update && helm upgrade kubecost kubecost/cost-analyzer 
```

**helm 3**

```
helm repo update && helm upgrade kubecost kubecost/cost-analyzer -n kubecost
```

## **Deleting Kubecost**

To uninstall Kubecost and its dependencies, run the following command:

**helm 2**

```
helm del --purge kubecost 
```

**helm 3**

```
helm uninstall kubecost -n kubecost 
```