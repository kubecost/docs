# Code Base Contribution Guide

Have you ever wanted to contribute to an open source project and community? This guide will help you understand the overall organization of the Kubecost project, and direct you to the best places to get started contributing. You’ll be able to share ideas, pick up issues, write code to fix them, and get your work reviewed and merged.

This document is the single source of truth for how to contribute to the code base. Feel free to browse the [open issues](https://github.com/kubecost/cost-model/issues) and file new ones. All feedback is welcome!

Kubecost offers a number of open-source software projects and tools which allow for contribution from the community, such as:
* [Kubecost docs](https://github.com/kubecost/docs)
* [Eventing API](https://github.com/kubecost/events)
* [Kubecost Helm chart](https://github.com/kubecost/cost-analyzer-helm-chart)
* [Lens Kubecost Extension](https://github.com/kubecost/kubecost-lens-extension)
* [kubectl-cost](https://github.com/kubecost/kubectl-cost)
* [Cluster Turndown](https://github.com/kubecost/cluster-turndown)

> **Note**: Please review the Prerequisites section below before attempting to make any contributions.

## Join our community 

Kubecost is a growing, lively, friendly open-source community. As many open source projects often do, it depends on new people becoming members and regular contributors of new ideas and implementation. Please consider joining the discussion around Kubecost, and making your first contribution to our community today. We ask our members to join the following channels of communication so we can better support you through your onboarding journey.

* [Slack community](https://kubecost.com/join-slack) - check out #support for any help you may need & drop your introduction in the #general channel
* [Kubecost Documentation](https://www.guide.kubecost.com/)
* Social media & blog
    * [Twitter ](https://twitter.com/kubecost)
    * [LinkedIn](https://www.linkedin.com/company/stackwatch/)
    * [Youtube](https://www.youtube.com/channel/UChIoMpeXm85T-kPCW1p9_PA)
    * [Blog](https://blog.kubecost.com/)

We can also be contacted at [support@kubecost.com](support@kubecost.com).

## Prerequisites

Before submitting code to Kubecost, you should first complete the following prerequisites. 

* Please make sure to read and observe the [code of conduct](https://github.com/kubecost/cost-model/blob/develop/CODE_OF_CONDUCT.md) and Community Values.
* Set up your development environment [here](https://github.com/kubecost/cost-model/blob/develop/CONTRIBUTING.md).

## Contribution workflow

This repository's contribution workflow follows a typical open-source model:

* [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repository
* Work on the forked repository
* Open a pull request to [merge the fork back into this repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)

## Building Kubecost

Follow these steps to build from source and deploy:

1. `docker build --rm -f "Dockerfile" -t <repo>/kubecost-cost-model:<tag>`

2. Edit the [pulled image](https://github.com/kubecost/cost-model/blob/master/kubernetes/deployment.yaml#L25) in the deployment.yaml to /kubecost-cost-model

3. Set [this environment variable](https://github.com/kubecost/cost-model/blob/master/kubernetes/deployment.yaml#L33) to the address of your prometheus server

4. `kubectl create namespace cost-model`

5. `kubectl apply -f kubernetes/ --namespace cost-model`

6. `kubectl port-forward --namespace cost-model service/cost-model 9003`

To test, build the cost-model docker container and then push it to a Kubernetes cluster with a running Prometheus.

To confirm that the server is running, you can hit [http://localhost:9003/costDataModel?timeWindow=1d](http://localhost:9003/costDataModel?timeWindow=1d).

## Running locally

In order to run cost-model locally, or outside of the runtime of a Kubernetes cluster, you can set the environment variable KUBECONFIG_PATH.

Example:

```
export KUBECONFIG_PATH=~/.kube/config
```
   
## Running the integration tests

To run these tests:

* Make sure you have a kubeconfig that can point to your cluster, and have permissions to create/modify a namespace called "test"

* Connect to your the prometheus kubecost emits to on localhost:9003: kubectl port-forward --namespace kubecost service/kubecost-prometheus-server 9003:80

* Temporary workaround: Copy the default.json file in this project at cloud/default.json to /models/default.json on the machine your test is running on. TODO: fix this and inject the cloud/default.json path into provider.go.

* Navigate to cost-model/test

* Run go test -timeout 700s from the testing directory. The tests right now take about 10 minutes (600s) to run because they bring up and down pods and wait for Prometheus to scrape data about them.

## Certification of origin

By contributing to this project you certify that your contribution was created in whole or in part by you and that you have the right to submit it under the open source license indicated in the project. In other words, please confirm that you, as a contributor, have the legal right to make the contribution.

## Committing

Please write a commit message with Fixes Issue # if there is an outstanding issue that is fixed. It’s okay to submit a PR without a corresponding issue, just please try to be detailed in the description about the problem you’re addressing.

Please run `go fmt` on the project directory. Lint can be okay (for example, comments on exported functions are nice but not required on the server).

### Where can I go for help?

If you need help, you can ask questions on our mailing list, Slack community , or GitHub issues.

### What does the code of conduct mean for me?

Our code of conduct means that you are responsible for treating everyone on the project with respect and courtesy regardless of their identity. If you are the victim of any inappropriate behavior or comments as described in our code of conduct, we are here for you and will do the best to ensure that the abuser is reprimanded appropriately, per our code. Please report any incidents here: [team@kubecost.com](mailto:team@kubecost.com)
