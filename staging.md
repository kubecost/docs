# Deploy Kubecost Staging Builds

Staging builds for the Kubecost helm chart are produced daily before moving to production. 
To deploy one of these builds, complete the following steps: 

### 1. Add [Staging Repo](https://github.com/kubecost/staging-repo)

```
helm repo add kubecoststagingrepo https://kubecost.github.io/staging-repo/
```

### 2. Upgrade kubecost to use staging repo 

```
 helm upgrade kubecost kubecoststagingrepo/cost-analyzer -n kubecost
```
