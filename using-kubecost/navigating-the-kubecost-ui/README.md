# Navigating the Kubecost UI

This grouping of docs explains how to navigate the Kubecost UI. The UI is composed of several primary dashboards which provide cost visualization, as well as multiple savings and governance tools. Below is the main Overview page, which contains several helpful panels for observing workload stats and trends. Individual pages have their own dedicated documentation for explaining all features which can be interacted with, as well as how they work.

![Kubecost overview](/images/overview.png)

To obtain access to the Kubecost UI following a successful installation, enable port-forwarding with the following command:

```
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

You can now access the UI by visiting `http://localhost:9090` in your web browser.
