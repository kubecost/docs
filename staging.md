# Deploy Kubecost Staging Builds

Staging builds for the Kubecost Helm Chart are produced at least daily before changes are moved to production. To upgrade an existing Kubecost Helm Chart deployment to the latest staging build, follow these quick steps:

1.  Add the [staging repo](https://github.com/kubecost/staging-repo) with the following command:

    ```
      helm repo add kubecoststagingrepo https://kubecost.github.io/staging-repo/
    ```
2.  Upgrade Kubecost to use the staging repo:

    ```
     helm upgrade kubecost kubecoststagingrepo/cost-analyzer -n kubecost
    ```
