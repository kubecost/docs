# Deploy Kubecost Staging Builds

Staging builds for the Kubecost helm chart are produced at least daily before changes are moved to production. 
To upgrade an existing Kubecost helm chart deployment to the latest staging build, complete the following steps: 

### 1. Add [Staging Repo](https://github.com/kubecost/staging-repo)

```
helm repo add kubecoststagingrepo https://kubecost.github.io/staging-repo/
```

### 2. Upgrade Kubecost to use staging repo 

```
 helm upgrade kubecost kubecoststagingrepo/cost-analyzer -n kubecost
```
