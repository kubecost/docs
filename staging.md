# Deploy Kubecost Staging Builds

Staging builds for the Kubecost helm chart are produced daily before moving to production. 
To deploy one of these builds, complete the following steps: 

### 1. Add [Staging Repo](https://github.com/kubecost/staging-repo)

```
helm repo add kubecost-staging https://kubecost.github.io/staging-repo/
```

### 2. Create new namespace (only required on helm 3)

```
kubectl create namespace kubecost-staging
```

### 3. Helm install 

```
helm install kubecost-staging kubecost/cost-analyzer --namespace kubecost-staging
```

### 4. Connect to build

```
kubectl port-forward --namespace kubecost-staging deployment/kubecost-staging-cost-analyzer 9090
```

You can now visit <http://localhost:9090> to view the Kubecost frontend.

<br/>  

This chart can be uninstalled with `helm uninstall kubecost-staging -n kubecost-staging`
