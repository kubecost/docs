There are three different approaches for passing custom helm config values into the Kubecost project:  


1. **pass exact parameters via `--set` command line flags.** For example, you can only pass a product key if that is all you need to configure.

```
helm install kubecost/cost-analyzer --name kubecost --set kubecostProductConfigs.productKey.key="123" ...
```
2. **pass exact parameters via custom `values` file** Similar to option #1, you can create a seperate values file that contains only the parameters needed. 

```
helm install kubecost/cost-analyzer --name kubecost --values values.yaml
```

```
 kubecostProductConfigs:
  productKey: 
    key: "123"
    enabled: true
```

3. **use [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) from kubecost helm chart repo.** 
Note that taking this approach means you may need to sync with the repo to use the latest release. 
