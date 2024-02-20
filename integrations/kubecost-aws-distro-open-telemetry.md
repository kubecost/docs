# # Kubecost with AWS Distro for OpenTelemetry (ADOT)

## Overview

This guide will walk you through the steps to deploy Kubecost with [AWS Distro for Open Telemetry (ADOT)](https://aws-otel.github.io/) to collect metrics from your Kubernetes cluster.

![Architecture Diagram](/images/adot-architecture.png)

## Prerequisites

Before following this guide, make sure you've reviewed AWS' doc on [installing the ADOT daemonset](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-OpenTelemetry.html). Update all configuration files in this folder that contain `YOUR_*` with your values.

This guide assumes that the Kubecost Helm release name and the Kubecost namespace have the same value (usually this will be `kubecost`), which allows a global find and replace on `YOUR_NAMESPACE`.

## Configuration

Update all configuration files with your cluster name (replace all instances of `YOUR_CLUSTER_NAME_HERE`). The examples use `cluster` for the cluster name. You can use any key you want, but you will need to update the ConfigMap and deployment files to match. A simplified version of the ADOT DS installation is below.

### ADOT configuration

There are many options for deploying the ADOT daemonSet. At a minimum, Kubecost needs the provided scrape config to be added to the ADOT Prometheus ConfigMap. This sample ConfigMap also contains cAdvisor metrics, which is required by Kubecost.

```bash
kubectl apply -f example-configs/prometheus-daemonset.yaml
```

Alternatively, you can add these items to your [existing ConfigMap](example-configs/kubecost-adot-scrape-config.yaml).

### Kubecost Agent installation

1. Create the Kubecost namespace:

    ```bash
    kubectl create ns YOUR_NAMESPACE
    ```

1. Create the AWS IAM policy to allow Kubecost to query metrics from AMP:

    ```bash
    aws iam create-policy --policy-name kubecost-read-amp-metrics --policy-document file://iam-read-amp-metrics.json
    ```

1. Create the AWS IAM policy to allow Kubecost to write to the `federated-store` S3 bucket:

    ```bash
    aws iam create-policy --policy-name kubecost-bucket-policy --policy-document file://iam-kubecost-metrics-s3-policy.json
    ```

1. Configure the Kubecost Service Account:

    ```bash
    eksctl create iamserviceaccount \
    --name kubecost-sa \
    --namespace YOUR_NAMESPACE \
    --cluster qa-serverless2 --region YOUR_REGION \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-read-amp-metrics \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-bucket-policy \
    --override-existing-serviceaccounts --approve --profile admin
    ```

1. Create the Kubecost federated S3 object store secret.

    Copy the output from:

    ```bash
    base64 federated-store.yaml|tr -d '\n'
    ```

    And replace the place holder in `values-kubecost-s3-federated-store.yaml`

1. Deploy the Kubecost agent:

    ```bash
    helm install YOUR_NAMESPACE \
        kubecost/cost-analyzer \
        -f values-kubecost-agent.yaml \
        -f values-kubecost-s3-federated-store.yaml
    ```

### Kubecost primary installation

This assumes you have created the policies above. If using multiple AWS accounts, you will need to create the policies in each account.

1. Create the Kubecost namespace:

    ```bash
    kubectl create ns YOUR_NAMESPACE
    ```

1. Configure the Kubecost Service Account:

    ```bash
    eksctl create iamserviceaccount \
        --name kubecost-sa \
        --namespace YOUR_NAMESPACE \
        --cluster YOUR_PRIMARY_CLUSTER_NAME --region YOUR_REGION \
        --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-read-amp-metrics \
        --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-bucket-policy \
        --override-existing-serviceaccounts --approve --profile admin
    ```

1. Install Kubecost Primary:

    ```bash
    helm install YOUR_NAMESPACE -n YOUR_NAMESPACE \
        kubecost/cost-analyzer \
        -f values-kubecost-primary.yaml \
        -f values-kubecost-s3-federated-store.yaml
    ```

## ADOT Daemonset quick install

See this [example .yaml file](example-configs/prometheus-daemonset.yaml) for an all-in-one ADOT DS config.