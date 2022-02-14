Installing Kubecost with Rafay
================

[Rafay](https://rafay.co) is a SaaS-first Kubernetes Operations Platform (KOP) with enterprise-class scalability, zero-trust security and interoperability for managing applications across public clouds, data centers & edge.

See [Rafay documentation](https://docs.rafay.co/) to learn more about the platform and how to use it.

This document will walk you through installing Kubecost on a cluster that has been provisioned or imported using the Rafay controller. The steps below describe how to create and use a custom cluster blueprint via the [Rafay Web Console](https://console.rafay.dev/). The entire workflow can also be fully automated and embedded into an automation pipeline using the [RCTL CLI utility](https://docs.rafay.co/cli/overview/) or [Rafay REST APIs](https://docs.rafay.co/api/apis/).

## Prerequisites

You have already [provisioned or imported](https://docs.rafay.co/learn/overview/) one or more Kubernetes clusters using the [Rafay controller](https://console.rafay.dev/).

## Step 1: Create a Repository

Under **Integrations**:

- Select **Repositories** and create a new repository named `kubecost` of type **Helm**
- Click **Create**

![Create Repository](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-repository-1.png)

- Enter the endpoint value of `https://kubecost.github.io/cost-analyzer/`
- Click **Save**

![Create Repository](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-repository-2.png)

## Step 2: Customize Values

You'll need to override the default `values.yaml` file. Create a new file called `kubecost-custom-values.yaml` with the following content:

```yaml
# Custom values for Kubecost
reporting:
  valuesReporting: false
# Replace token with the value you get from kubecost.com/install
# after entering your email address
kubecostToken: 'token_string'
```

## Step 3: Create a Namespace

- Login into the [Rafay Web Console](https://console.rafay.dev/) and navigate to your Project as an _Org Admin_ or _Infrastructure Admin_
- Under **Infrastructure**, select **Namespaces** and create a new namespace called `kubecost`, and select type **Wizard**

![Create Namespace](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-namespace-1.png)

- Click **Save & Go to Placement**

![Create Namespace](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-namespace-2.png)

- Select the cluster/s that the namespace will be added to. Select **Save & Go To Publish**

![Create Namespace](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-namespace-3.png)

- Click **Publish** to publish the namespace to the selected cluster(s)

![Create Namespace](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-namespace-4.png)

- Once the namespace has been published, Click **Exit**

![Create Namespace](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-namespace-5.png)

- Under **Infrastructure**, select **Clusters**
- Click on the `kubectl` button on the cluster to open a virtual terminal
- Verify that the `kubecost` namespace has been created by running the following command:

```sh
$ kubectl get ns kubecost

NAME            STATUS   AGE
kubecost        Active   44m
```

## Step 4: Create an Add-on

From the [Web Console](https://console.rafay.dev/):

- Select **Add-ons** and **Create** a new add-on called `kubecost`
- Select **Bring your own**
- Select `Helm 3` for type
- Select **Pull files from repository**
- Select `Helm` for the repository type
- Select `kubecost` for the namespace
- Click **Create**

![Create Addon](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-addon-1.png)

- Create a new version of the add-on
- Select **New Version**
- Provide a version name such as `v1`
- Select `kubecost` for the repository
- Enter `cost-analyzer` for the chart name
- Upload the `kubecost-custom-values.yaml` file that was previously created
- Click **Save Changes**

![Create Addon](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-addon-2.png)

## Step 5: Create a Blueprint

Once you've created the Kubecost add-on, use it in assembling a custom cluster blueprint. You can add other add-ons to the same custom blueprint.

- Under _Infrastructure_, select **Blueprints**
- Create a new blueprint and give it a name such as `kubecost`
- Click **Save**

![Create Blueprint](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-blueprint-1.png)

- Create a new version of the blueprint
- Select **New Version**
- Provide a version name such as `v1`
- Under Add-Ons, select the `kubecost` Add-on and the version that was previously created
- Click **Save Changes**

![Create Blueprint](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-blueprint-2.png)

## Step 6: Apply Blueprint

You may now apply this custom blueprint to a cluster.

- Click on **Options** for the target cluster in the Web Console
- Select **Update Blueprint** and select the `kubecost` blueprint and version you created previously
- Click on **Save and Publish**

![Update Blueprint](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-blueprint-3.png)

This will start the deployment of the Add-ons configured in the `kubecost` blueprint to the targeted cluster. The blueprint sync process can take a few minutes. Once complete, the cluster will display the current cluster blueprint details and whether the sync was successful or not.

## Step 7: Verify Deployment

You can optionally verify whether the correct resources have been created on the cluster. Click on the `kubectl` button on the cluster to open a virtual terminal.

Then, verify the pods in the `kubecost` namespace. Run `kubectl get pod -n kubecost`, and check that the output is similar to the example below.

```sh
$ kubectl get pod -n kubecost

NAME                                          READY   STATUS    RESTARTS   AGE
kubecost-cost-analyzer-8544c4bbd4-gx4nl       3/3     Running   0          6m23s
kubecost-grafana-768655466d-vlsmq             3/3     Running   0          6m23s
kubecost-kube-state-metrics-f99c657b5-mh5mt   1/1     Running   0          6m23s
kubecost-prometheus-node-exporter-26fwv       1/1     Running   0          6m23s
kubecost-prometheus-node-exporter-zfkvw       1/1     Running   0          6m23s
kubecost-prometheus-server-5cc6745978-z98f8   2/2     Running   0          6m23s
```

## Step 8: Enable Port Forwarding

In order to access the Kubecost UI, you'll need to enable access to the frontend application using [port-forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/). To do this, download and use the `Kubeconfig` with the KubeCTL CLI (`../../accessproxy/kubectl_cli/`)

```sh
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090

Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090
```

## Step 9: View Data

You can now access the Kubecost UI by visiting `http://localhost:9090` on your browser.

![kubecost Dashboards](https://docs.rafay.co/recipes/cost/img/kubecost/kubecost-view-1.png)

---

Et voilà! You have successfully created a custom cluster blueprint with the `kubecost` add-on and applied to a cluster. Use this blueprint on as many clusters as you require.

You can find [this same guide](https://docs.rafay.co/recipes/cost/kubecost/) as well as the guides for how to create or import a cluster using the Rafay controller on the [Rafay documentation site](https://docs.kubecost.com/custom-prom.html#troubleshooting-issues).

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/rafay.md)


<!--- {"article":"4413635957271","section":"4402815636375","permissiongroup":"1500001277122"} --->