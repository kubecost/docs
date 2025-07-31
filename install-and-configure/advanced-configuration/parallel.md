# Parallel Installation

The below guide is optional, as there is low risk to data loss in Kubecost as all metrics are stored in cloud object-storage. The primary benefit to a parallel installation is to reduce the amount of time the Kubecost UI is unavailable/incomplete during an upgrade.

It is possible to run multiple Kubecost Primaries on the same cluster in parallel. This is useful if you are upgrading to a new version and want to validate the new version before removing the current one.

The primary concern is to ensure that two Kubecost cost-analyzer pods on a single cluster are not writing to the same bucket at the same time.

To prevent this, add the following to the existing `values.yaml` file:

```yaml
federatedETL:
  readOnlyPrimary: true
```

All other core settings should be the same as the existing [primary](../../architecture/architecture.md) installation.

You MUST install the parallel installation in a different namespace than the primary installation, with a different release name.

For example, if the current install was done with

```bash
helm install kubecost --namespace kubecost ...
```

The parallel installation MUST be installed with a different release name, such as:

```bash
helm install kubecost2 --namespace kubecost2 ...
```

## Cut-over

Once the parallel installation is validated, you can cut-over to it. This involves deleting the old primary and removing the `readOnly: true` from the new install and running a helm upgrade with the updated values.yaml file.

Keep in mind that the old primary will retain the aggregator PVC, which can be removed manually.
