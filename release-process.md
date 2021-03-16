# Kubecost Release Process

A Kubecost Release is a snapshot of the source, build output, artifacts, and other metadata associated with a tagged version of code.

## Production releases 

* Production releases are scheduled for the 2nd and 4th Tuesday of every month.
* Patch releases are pushed as needed between scheduled releases.
* Release notes published [here](https://kubecost.com/releases).
* Production releases are always generated from Master branches.  
* In each production release, we update each image version plus our helm chart version in lock step. 
* Historically we average one patch release between minor releases.
* You can target an older release of the Kubecost pod by setting `imageVersion` to the desired value, e.g. ` prod-1.63.1`

## Staging releases

* Staging releases are built before scheduled releases and published in [this repo](https://github.com/kubecost/staging-repo).
* You can get the latest staging build by following the [install steps](https://github.com/kubecost/docs/blob/master/staging.md)

## Nightly releases

A Helm chart release is created every night with the latest images. These images should be considered "bleeding edge" and may be unstable. You can get that Helm repo with the following:

``` sh
helm repo add kubecost-nightly https://kubecost.github.io/nightly-helm-chart
```

You can then update your existing installation to the latest nightly:

``` sh
helm repo update
helm upgrade kubecost -n kubecost kubecost-nightly/cost-analyzer
```

If you want to change your installation back to a production release, run the following (assuming you have a Helm repo called `kubecost` tracking the production release):

``` sh
helm upgrade kubecost kubecost/cost-analyzer -n kubecost
```

## Getting notified when a release is created

* You can watch Releases Only ([more info](https://docs.github.com/en/github/managing-subscriptions-and-notifications-on-github/viewing-your-subscriptions)) for this [helm chart repo](https://github.com/kubecost/cost-analyzer-helm-chart).
Or join our Slack workspace - https://kubecost.slack.com

## Submitting feedback on a release

We always love receiving feedback and feature requests. Please reach out to team@kubecost.com or submit an issue in the respective repo:

* If you installed our helm chart, all issues can be filed at https://github.com/kubecost/cost-analyzer-helm-chart
* If you installed just the open source cost-model, you can file issues at https://github.com/kubecost/cost-model
