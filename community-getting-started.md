# Welcome

Have you ever wanted to contribute to an open source project and community? This guide will help you understand the overall organization of the Kubecost project, and direct you to the best places to get started contributing. You’ll be able to share ideas, pick up issues, write code to fix them, and get your work reviewed and merged.

This document is the single source of truth for how to contribute to the code base. Feel free to browse the [open issues](https://github.com/kubecost/cost-model/issues) and file new ones, all feedback is welcome!

This is your guide and roadmap to getting started as a Kubecost community member. The contributor guide outlines a list of prerequisites that need to be completed before you are able to start contributing, for example we ask all community members to review the Code of Conduct prior to jumping in. 

## Join our community 

Kubecost is a growing, lively, friendly open-source community. As many open source projects often do, it depends on new people becoming members and regular contributors of new ideas and implementation. Please consider joining the discussion around Kubecost, and making your first contribution to our community today. We ask our members to join the following channels of communication so we can better support you through your onboarding journey.

Communication

* [Slack community](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) - check out #support for any help you may need & drop your introduction in the #general channel
* [Kubecost Documentation](https://www.docs.kubecost.com/)
* Social media & blog
    * [Twitter ](https://twitter.com/kubecost)
    * [LinkedIn](https://www.linkedin.com/company/stackwatch/)
    * [Youtube](https://www.youtube.com/channel/UChIoMpeXm85T-kPCW1p9_PA)
    * [Blog](https://blog.kubecost.com/)

If you have any questions please reach out: [team@kubecost.com](mailto:team@kubecost.com)

# Contributor guide

Welcome to Kubecost! This guide is broken up into the following sections. It is recommended that you follow these steps in order: 

* Prerequisites: these tasks are required and need to be completed before you can start contributing to Kubecost
* Your First Contribution: things you need to know before making your first contribution
* Contributing: the main reference guide to contributing to Kubecost

# Prerequisites

Before submitting code to Kubecost, you should first complete the following prerequisites. 

## Code of conduct

Please make sure to read and observe the [code of conduct](https://github.com/kubecost/cost-model/blob/develop/CODE_OF_CONDUCT.md) and Community Values.

## Setting up your development environment

[https://github.com/kubecost/cost-model/blob/develop/CONTRIBUTING.md](https://github.com/kubecost/cost-model/blob/develop/CONTRIBUTING.md) 

# Contributing to our project

Thanks for your help improving the project!

## Getting help

If you have a question about Kubecost or have encountered problems using it, you can start by asking a question on [Slack](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) or via email at [support@kubecost.com](mailto:support@kubecost.com). You can also visit [https://docs.kubecost.com/](https://docs.kubecost.com/)

## Contribution workflow

This repository's contribution workflow follows a typical open-source model:

* [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repository
* Work on the forked repository
* Open a pull request to [merge the fork back into this repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)

## Building Kubecost

Follow these steps to build from source and deploy:

1. docker build --rm -f "Dockerfile" -t <repo>/kubecost-cost-model:<tag> .

2. Edit the [pulled image](https://github.com/kubecost/cost-model/blob/master/kubernetes/deployment.yaml#L25) in the deployment.yaml to /kubecost-cost-model:

3. Set [this environment variable](https://github.com/kubecost/cost-model/blob/master/kubernetes/deployment.yaml#L33) to the address of your prometheus server

4. kubectl create namespace cost-model

5. kubectl apply -f kubernetes/ --namespace cost-model

6. kubectl port-forward --namespace cost-model service/cost-model 9003

To test, build the cost-model docker container and then push it to a Kubernetes cluster with a running Prometheus.

To confirm that the server is running, you can hit [http://localhost:9003/costDataModel?timeWindow=1d](http://localhost:9003/costDataModel?timeWindow=1d)

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

Please run go fmt on the project directory. Lint can be okay (for example, comments on exported functions are nice but not required on the server).

Please email us (support@kubecost.com) or reach out to us on [Slack](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) if you need help or have any questions!

Thanks for your help improving the project!

### Where can I go for help?

If you need help, you can ask questions on our mailing list, Slack community , or Github issues [list any other communication platforms that your project uses].

### What does the code of conduct mean for me?

Our code of conduct means that you are responsible for treating everyone on the project with respect and courtesy regardless of their identity. If you are the victim of any inappropriate behavior or comments as described in our code of conduct, we are here for you and will do the best to ensure that the abuser is reprimanded appropriately, per our code. Please report any incidents here: [team@kubecost.com](mailto:team@kubecost.com)

<!--- {"article":"4442565953943","section":"1500002777682","permissiongroup":"1500001277122"} --->
