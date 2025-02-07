# CSV Pricing

{% hint style="info" %}
CSV pricing is a Kubecost Enterprise only feature.
{% endhint %}

Kubecost allows users to apply custom prices to individual assets (e.g. nodes) via a CSV pipeline. Common uses are for on-premise clusters, service-providers, or for external enterprise discounts. This feature allows for greater resource specification than is provided by [Custom Pricing](/architecture/pricing-sources-matrix.md#custom-pricing). This doc shows how to create and configure a CSV pricing file.

## Creating a pricing file

1.  Create a CSV file in this [format](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/custom-pricing.csv) (also in the below table). CSV changes are picked up hourly by default.

    1. `EndTimeStamp`: currently unused
    2. `InstanceID`: identifier used to match asset
    3. `Region`: filter match based on topology.kubernetes.io/region
    4. `AssetClass`: node pv, gpu are supported
    5. `InstanceIDField`: field in spec or metadata that will contain the relevant InstanceID. For nodes, often spec.providerID , for pv’s often metadata.name
    6. `InstanceType`: optional field to define the asset type, e.g. m5.12xlarge
    7. `MarketPriceHourly`: hourly price to charge this asset
    8. `Version`: field for schema version, currently unused

If the node label topology.kubernetes.io/region is present, it must also be in the `Region` column.

![Pricing table](/images/pricing.png)

## GPU pricing

{% hint style="info" %}
This section is only required for nodes with GPUs.
{% endhint %}

1. The node the GPU is attached to must be matched by a CSV node price. Typically this will be matched on instance type (node.kubernetes.io/instance-type)
2. Supported GPU labels are currently:
   * gpu.nvidia.com/class
   * nvidia.com/gpu\_type
3. Verification:
   1. Connect to the Kubecost Prometheus: `kubectl port-forward --namespace kubecost services/kubecost-cost-analyzer 9090:9090`
   2. Run the following query: `curl localhost:9090/model/prometheusQuery?query=node_gpu_hourly_cost`
      1. You should see output similar to this: `{instance="ip-192-168-34-166.us-east-2.compute.internal",instance_type="test.xlarge",node="ip-192-168-34-166.us-east-2.compute.internal",provider_id="aws:///us-east-2b/i-055274d3576800444",region="us-east-2"} 10 | YOUR_HOURLY_COST`

## Kubecost configuration

Provide a file path for your CSV pricing data in your [*values.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-custom-pricing.yaml). This path can reference a local PV or an S3 bucket.

```yaml
pricingCsv:
  enabled: true
  location:
    provider: "AWS|GCP"
    region: "us-east-1"
    URI: s3://YOUR_BUCKET/path/custom-pricing.csv
    csvAccessCredentials: pricing-schema-access-secret
```

Alternatively, mount a ConfigMap with the CSV:

```
kubectl create configmap csv-pricing --from-file custom-pricing.csv
```

Then set the following Helm values:

```yaml
pricingCsv:
  enabled: true
  location:
    URI: /var/kubecost-csv/custom-pricing.csv
    csvAccessCredentials: ""

extraVolumes:
- name: kubecost-csv
  configMap:
    name: csv-pricing

extraVolumeMounts:
- name: kubecost-csv
  mountPath: /var/kubecost-csv
```

For S3 locations, provide file access. Required IAM permissions:

```json
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
   2. The name of this secret should be the same as `csvAccessCredentials` in _values.yaml_ above
2. AWS IAM (IRSA) [service account annotation](https://docs.aws.amazon.com/eks/latest/userguide/adot-iam.html)

## Pricing discounts

Negotiated discounts are applied after cost metrics are written to Prometheus. Discounts will apply to all node pricing data, including pricing data read directly from the custom provider CSV pipeline. Additionally, all discounts can be updated at any time and changes are applied retroactively.

## Pricing inference

The following logic is used to match node prices accurately:

* First, search for an exact match in the CSV pipeline
* If an exact match is not available, search for an existing CSV data point that matches region, instanceType, and AssetClass
* If neither is available, fall back to pricing estimates

You can check a summary of the number of nodes that have matched with the CSV by visiting /model/pricingSourceCounts. The response is a JSON object of the form:

```
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
