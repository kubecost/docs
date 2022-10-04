Helm Parameters
===============

There are three different approaches for passing custom Helm config values into the Kubecost project:  


1. **Pass exact parameters via `--set` command-line flags.** For example, you can only pass a product key if that is all you need to configure.

      ```
        helm install kubecost/cost-analyzer --name kubecost --set kubecostProductConfigs.productKey.key="123" ...
      ```
  
2. **Pass exact parameters via custom `values` file** Similar to option #1, you can create a separate values file that contains only the parameters needed. 

      ```
        helm install kubecost/cost-analyzer --name kubecost --values values.yaml
      ```

      ```
       kubecostProductConfigs:
        productKey: 
          key: "123"
          enabled: true
      ```

3. **Use [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) from the Kubecost Helm Chart repository.** 

> **Note**: Taking this approach means you may need to sync with the repo to use the latest release. 

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/helm-install-params.md)

<!--- {"article":"4407601818391","section":"4402815636375","permissiongroup":"1500001277122"} --->
