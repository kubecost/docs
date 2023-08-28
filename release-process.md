# Kubecost Release Process

A Kubecost Release is a snapshot of the source, build output, artifacts, and other metadata associated with a tagged version of code.

## Production releases

* Major production releases should typically go out once a month.
* Patch releases are pushed as needed between scheduled releases.
* Release notes will be published [here](https://kubecost.com/releases).
* Production releases are always generated from Master branches.
* In each production release, we update each image version plus our helm chart version in lock step.
* Historically we average one patch release between minor releases.
* You can target an older release of the Kubecost pod by setting `imageVersion` to the desired value, e.g. `prod-1.63.1`

## Release candidate (RC) builds

* Release candidates are produced between production releases for early testing
* To pick up a release candidate, add `--devel` to your helm install/upgrade instructions. For example:

```
helm install kubecost kubecost/cost-analyzer --namespace kubecost --devel
```

## Staging releases

* Staging releases are built before scheduled releases and published in [this repo](https://github.com/kubecost/staging-repo).
* You can get the latest staging build by following the [install steps](staging.md).

## Delaying Releases

We never want to miss our communicated release date, but sometimes it happens. We will only delay a release when we as a team feel like we're not delivering our best possible work product. Generally speaking, if we don't release on time, we have more work to complete before we feel like we're putting our best foot forward. Occasionally this happens, and when it does, we will communicate through our RC release notes what the new anticipated release date is. We will, at a minimum, have RC images available by the planned release date. We will also regularly cut RC images every few days until the anticipated launch date.

## Nightly releases

A Helm chart release is created every night with the latest images. These images should be considered "bleeding edge" and may be unstable. You can get that Helm repo with the following:

```
helm repo add kubecost-nightly https://kubecost.github.io/nightly-helm-chart
```

You can then update your existing installation to the latest nightly:

```
helm repo update
helm upgrade kubecost -n kubecost kubecost-nightly/cost-analyzer
```

If you want to change your installation back to a production release, run the following (assuming you have a Helm repo called `kubecost` tracking the production release):

```
helm upgrade kubecost kubecost/cost-analyzer -n kubecost
```

## Getting notified when a release is created

* You can watch Releases Only ([more info](https://docs.github.com/en/github/managing-subscriptions-and-notifications-on-github/viewing-your-subscriptions)) for this [Helm chart repo](https://github.com/kubecost/cost-analyzer-helm-chart), or join our [Slack workspace](https://kubecost.slack.com).&#x20;

## Submitting feedback on a release

We always love receiving feedback and feature requests. Please reach out to support@kubecost.com or submit an issue in the respective repo:

* If you installed our Helm chart, all issues can be filed at https://github.com/kubecost/cost-analyzer-helm-chart
* If you installed just the open source cost-model, you can file issues at https://github.com/kubecost/cost-model
