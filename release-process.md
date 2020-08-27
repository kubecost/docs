# Kubecost Release Process

A Kubecost Release is a snapshot of the source, build output, artifacts, and other metadata associated with a tagged version of code.

## Production releases 

* Production releases are scheduled every other Tuesday with one cycle off after four consecutive releases. 
* Release notes published [here](https://kubecost.com/releases).
* Production releases are always generated from the Master branch.  
* In each production release, we update each image version plus our helm chart version in lock step. 
* Historically we average one patch release between minor releases.
* You can target an older release of the Kubecost pod by setting `imageVersion` to the desired value, e.g. ` prod-1.63.1`

## Staging releases

* Staging/nightly releases published in [this repo](https://github.com/kubecost/staging-repo).
* You can get the latest staging build by following the [install steps](https://github.com/kubecost/docs/blob/master/staging.md)

## Getting notified when a release is created

* You can watch Releases Only ([more info](https://docs.github.com/en/github/managing-subscriptions-and-notifications-on-github/viewing-your-subscriptions)) for this [helm chart repo](https://github.com/kubecost/cost-analyzer-helm-chart).
Or join our Slack workspace - https://kubecost.slack.com
