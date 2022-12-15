# CSV Pricing

> **Note**: This feature is only officially supported on Kubecost Enterprise plans.

The following steps allow Kubecost to use custom prices with a CSV pipeline. This feature allows for individual assets (e.g. nodes) to be supplied at unique prices. Common uses are for on-premise clusters, service-providers, or for external enterprise discounts.


## Pricing File

1. Create a CSV in this [format](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/custom-pricing.csv) (also in the below table). CSV changes are picked up hourly by default.
    1. EndTimeStamp: currently unused
    2. InstanceID: identifier used to match asset
    3. Region filter match based on topology.kubernetes.io/region
    4. AssetClass: node pv, gpu are supported
    5. InstanceIDField: field in spec or metadata that will contain the relevant InstanceID. For nodes, often spec.providerID , for pv’s often metadata.name
    6. InstanceType: optional field to define the asset type, e.g. m5.12xlarge
    7. MarketPriceHourly: hourly price to charge this asset
    8. Version: field for schema version, currently unused

    If the node label topology.kubernetes.io/region is present, it must also be in the CSV Region column.

![Pricing table](https://raw.githubusercontent.com/kubecost/docs/main/images/pricing.png)

## GPU pricing

Only required for nodes with GPUs

1. The node the GPU is attached to must be matched by a CSV node price. Typically this will be matched on instance type (node.kubernetes.io/instance-type)
2. Supported GPU labels are currently:
    * gpu.nvidia.com/class
    * nvidia.com/gpu_type
3. Verification:
    1. Connect to the Kubecost Prometheus: `kubectl port-forward --namespace kubecost services/kubecost-cost-analyzer 9090:9090`
    2. Run the following query: `curl localhost:9090/model/prometheusQuery?query=node_gpu_hourly_cost`
        1. You should see output similar to this: `{instance="ip-192-168-34-166.us-east-2.compute.internal",instance_type="test.xlarge",node="ip-192-168-34-166.us-east-2.compute.internal",provider_id="aws:///us-east-2b/i-055274d3576800444",region="us-east-2"} 10 | YOUR_HOURLY_COST`


## Kubecost Configuration

Provide a file path for your CSV pricing data in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-custom-pricing.yaml). This path can reference a local PV or an S3 bucket.

``` yaml
pricingCsv:
  enabled: true
  location:
    provider: "AWS|GCP"
    region: "us-east-1"
    URI: s3://YOUR_BUCKET/path/custom-pricing.csv
    csvAccessCredentials: pricing-schema-access-secret
```

Alternatively, mount a configmap with the CSV:

``` sh
kubectl create configmap csv-pricing --from-file custom-pricing.csv
```

Helm values:

``` yaml
pricingCsv:
  enabled: true
  location:
    URI: /var/kubecost-csv/custom-pricing.csv

extraVolumes:
- name: kubecost-csv
  configMap:
    name: csv-pricing

extraVolumeMounts:
- name: kubecost-csv
  mountPath: /var/kubecost-csv
```

For S3 locations, provide file access. Required IAM permissions:

``` json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::<your-bucket-name>/*",
                "arn:aws:s3:::<your-bucket-name>"
            ]
        }
    ]
}
```

There are two options for adding the credentials to the Kubecost pod:

1. Service key: Create an S3 service key with the permissions above, then add its ID and access key as a K8s secret:
   1. `kubectl create secret generic pricing-schema-access-secret -n kubecost --from-literal=AWS_ACCESS_KEY_ID=id --from-literal=AWS_SECRET_ACCESS_KEY=key`
   2. The name of this secret should be the same as csvAccessCredentials in values.yaml above


2. AWS IAM (IRSA) [service account annotation](https://docs.aws.amazon.com/eks/latest/userguide/adot-iam.html)

## Pricing discounts

Negotiated discounts are applied after cost metrics are written to Prometheus. Discounts will apply to all node pricing data, including pricing data read directly from the custom provider CSV pipeline. Additionally, all discounts can be updated at any time and changes are applied retroactively.

## Pricing inference

The following logic is used to match node prices accurately:

* First, search for an exact match in CSV pipeline
* If exact match not available, search for an existing CSV data point that matches region, instanceType, and AssetClass
* If neither available, fallback to pricing estimates

You can check a summary of the number of nodes that have matched with the CSV by visiting /model/pricingSourceCounts. The response is a JSON object of the form:

``` jsonc
{
    "code": 200,
    "status": "success",
    "data": {
        "TotalNodes": 10,
        "PricingType": {
            "csvExact": 5, // exact matches by the providerID field
            "csvClass": 4, // matches where the region and instanceType match
            "": 1 // matches that use our default pricing
        }
    }
}
```
