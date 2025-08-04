# Kubecost Release Process

A Kubecost release is a snapshot of the source, build output, artifacts, and other metadata associated with a tagged code version.

## Kubecost (self-hosted)

Self-hosted Kubecost, our primary product, uses [semantic versioning](https://semver.org/).

### Production releases

Kubecost schedules a production release for the beginning of each fiscal quarter. We will support the most current production release plus one prior production release, which means we will patch the prior production release for any critical vulnerabilities. The most recent production release will be patched with critical security or functionality issues throughout the quarter. We anticipate several security/stability patches to be released every quarter. For example, starting with Q3 2023, we’ll release Version 1.106.0. Throughout the quarter, patch releases will be incremented on the patch version: 1.106.1, 1.106.2, etc.

### Edge releases

Kubecost schedules multiple edge releases throughout production release time frames. Building on the previous example, 1.106.2 is the current production release. If we announce a new feature to be released in 1.107.0, you can expect that all security patches in 1.106.2 will be present in 1.107.0. Once product and QA have determined the feature is ready for a production release, we will release the feature in the following production release (In this case, 1.108.0).

Not all features released in an edge release are guaranteed to make a production release. We intend to ensure our production releases are reserved for the highest quality of features. Our product and engineering teams will determine if a feature will be released in a production release. All releases will be treated the same from engineering.&#x20;

### Nightly releases

A Helm chart release is created every night with the latest images. These images should be considered "bleeding edge" and may be unstable. You can get this Helm repo with the following:

```bash
helm repo add kubecost-nightly https://kubecost.github.io/nightly-helm-chart
```

You can then update your existing installation to the latest nightly:

```bash
helm repo update
helm upgrade kubecost -n kubecost kubecost-nightly/cost-analyzer
```

If you want to change your installation back to a production release, run the following (only if you have a Helm repo called `kubecost` tracking the production release):

```bash
helm upgrade kubecost kubecost/cost-analyzer -n kubecost
```

### Getting notified when a release is created

You can receive updates for releases only ([more info](https://docs.github.com/en/github/managing-subscriptions-and-notifications-on-github/viewing-your-subscriptions)) for our [cost-analyzer-helm-chart repo](https://github.com/kubecost/cost-analyzer-helm-chart), or join our [Slack workspace](https://kubecost.com/join-slack) to learn whenever a new update or patch goes live.

## Kubecost Cloud

Kubecost Cloud releases regularly throughout the week (sometimes multiple times in one day). Features and bug fixes are typically fixed and deployed in real time.

## Submitting feedback on a release

We always appreciate receiving feedback and feature requests. Please reach out to support@kubecost.com or submit an issue in the respective repositories:

* If you installed our Helm chart, all issues can be through the [cost-analyzer-helm-chart repo](https://github.com/kubecost/cost-analyzer-helm-chart).
* If you installed OpenCost, you can file issues through the [OpenCost GitHub repo](https://github.com/opencost/opencost/issues).
